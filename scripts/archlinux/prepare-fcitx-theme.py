#!/usr/bin/env python3
"""预览或创建独立 Fcitx5 主题副本；不覆盖、不切换主题。"""
import argparse
import re
import shutil
from pathlib import Path


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--target', type=Path, required=True)
    p.add_argument('--apply', action='store_true')
    a = p.parse_args()
    source = a.source.expanduser().resolve()
    target = a.target.expanduser().absolute()
    if target.exists() or target.is_symlink():
        p.error('目标已存在，拒绝覆盖')
    if not source.is_dir() or not (source / 'theme.conf').is_file():
        p.error('来源必须包含 theme.conf')
    if source == target.resolve() or source in target.resolve().parents:
        p.error('目标不能在来源内部')
    if not re.fullmatch(r'[A-Za-z0-9_-]+', target.name):
        p.error('目标目录名只接受字母、数字、下划线和连字符')
    text = (source / 'theme.conf').read_text()
    match = re.search(r'(?ms)^\[Metadata\]\s*\n(.*?)(?=^\[|\Z)', text)
    if not match or not re.search(r'^Name=', match[1], flags=re.M):
        p.error('未找到 Metadata/Name，请人工检查主题格式')
    content = re.sub(r'^Name=.*$', 'Name=' + target.name, match[1], count=1, flags=re.M)
    content = re.sub(r'^Name\[[^\]]+\]=.*\n?', '', content, flags=re.M)
    text = text[:match.start(1)] + content + text[match.end(1):]
    print(f'{source} → {target}')
    if not a.apply:
        print('仅预览；--apply 创建副本，不修改输入法配置')
        return
    shutil.copytree(source, target, symlinks=False)
    (target / 'theme.conf').write_text(text)
    print('已创建个人副本；请手动编辑并选择主题')


if __name__ == '__main__':
    main()
