#!/usr/bin/env python3
"""从仓库生成待审阅配置；默认仅预览，不安装、不写实际桌面配置。"""
import argparse
import shutil
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('module', choices=['terminal', 'theme', 'proxy', 'portal', 'vm', 'nautilus', 'lockscreen'])
    parser.add_argument('--output', type=Path, required=True, help='必须是尚不存在的新目录')
    parser.add_argument('--apply', action='store_true', help='仅授权生成到 output，不部署到 HOME 或系统目录')
    args = parser.parse_args()
    source = Path(__file__).resolve().parents[2] / 'wiki/assets/session-templates' / args.module
    target = args.output.expanduser().absolute()
    if target.exists() or target.is_symlink():
        parser.error('输出已存在；请换一个新目录，禁止覆盖')
    files = sorted(source.iterdir())
    print(f'{args.module} → {target}')
    for path in files:
        print(f'  {path.name}')
    if not args.apply:
        print('仅预览；--apply 才生成文件；生成后仍需按指南审阅和合并。')
        return
    target.mkdir(parents=True, exist_ok=False, mode=0o700)
    for path in files:
        shutil.copy2(path, target / path.name)
    print('已生成；未安装软件或执行配置脚本。')


if __name__ == '__main__':
    main()
