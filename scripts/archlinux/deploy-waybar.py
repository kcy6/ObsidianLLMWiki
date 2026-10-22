#!/usr/bin/env python3
"""生成完整 Waybar 基础配置；默认预览，显式写入目标目录；不会重启或修改亮度。"""
import argparse
import datetime
import json
import re
import shlex
import shutil
import tempfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', type=Path, required=True)
    parser.add_argument('--device', help='可选，实际确认可用的背光接口名')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--replace', action='store_true', help='允许备份后替换已有目标文件')
    args = parser.parse_args()
    if args.device and not re.fullmatch(r'[A-Za-z0-9_-]+', args.device):
        parser.error('背光设备名只允许字母、数字、下划线和连字符')
    root = Path(__file__).resolve().parents[2]
    target = args.target.expanduser().resolve()
    data = json.loads((root / 'wiki/assets/waybar/config.jsonc').read_text())
    files = ['config.jsonc', 'style.css']
    if args.device:
        files.append('brightness-step.sh')
        modules = data['modules-right']
        modules.insert(modules.index('wireplumber'), 'backlight')
        helper = shlex.quote(str(target / 'brightness-step.sh'))
        data['backlight'] = {
            'device': args.device, 'format': '☀ {percent}%',
            'tooltip-format': '屏幕亮度：{percent}%',
            'on-scroll-up': f'bash {helper} up {args.device}',
            'on-scroll-down': f'bash {helper} down {args.device}',
        }
    print(f'目标：{target}；生成：{", ".join(files)}')
    if not args.apply:
        print('仅预览；--apply 才写入，已有文件需 --replace；不更改亮度、不重载 Waybar。')
        return
    target.mkdir(parents=True, exist_ok=True)
    existing = [target / name for name in files if (target / name).exists() or (target / name).is_symlink()]
    if any(p.is_symlink() or not p.is_file() for p in existing):
        parser.error('目标含符号链接或非普通文件，请手动处理')
    if existing and not args.replace:
        parser.error('已有目标文件；先比较差异，确认后使用 --replace')
    if existing:
        backup = Path(tempfile.mkdtemp(prefix='backup-' + datetime.date.today().isoformat() + '-', dir=target))
        backup.chmod(0o700)
        for path in existing:
            shutil.copy2(path, backup / path.name)
        print(f'备份：{backup}')
    (target / 'config.jsonc').write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    shutil.copy2(root / 'wiki/assets/waybar/style.css', target / 'style.css')
    if args.device:
        shutil.copy2(root / 'scripts/archlinux/brightness-step.sh', target / 'brightness-step.sh')
    print('已生成。先检查差异与语法，再手动重载；不会合并或保留被替换文件中的自定义配置。')


if __name__ == '__main__':
    main()
