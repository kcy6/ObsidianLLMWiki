# obsidian.sh
```bash
#!/usr/bin/env bash
# Fedora x86_64 / ARM64: 安装或更新 Obsidian AppImage，并添加菜单/fuzzel 图标。
# 用法：bash install-obsidian.sh
# 请先关闭 Obsidian。以普通用户运行，不要 sudo bash 本脚本。
set -euo pipefail

[[ $EUID -ne 0 ]] || { echo '请以普通用户运行；脚本仅在安装依赖时使用 sudo。' >&2; exit 1; }
architecture=$(uname -m)
case "$architecture" in
    x86_64|aarch64) ;;
    *) echo "不支持的架构：$architecture" >&2; exit 1 ;;
esac
[[ ! -e /run/ostree-booted ]] || { echo '此脚本不适用于 Fedora Atomic 系统。' >&2; exit 1; }
if [[ -n ${XDG_DATA_HOME:-} && $XDG_DATA_HOME != /* ]]; then
    echo 'XDG_DATA_HOME 必须是绝对路径。' >&2
    exit 1
fi
command -v dnf >/dev/null || { echo '此脚本适用于使用 dnf 的 Fedora 系统。' >&2; exit 1; }

sudo dnf install -y curl python3 fuse fuse-libs

app_dir="$HOME/Applications"
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}"
desktop_dir="$data_dir/applications"
icon_dir="$data_dir/icons/hicolor/scalable/apps"
mkdir -p "$app_dir" "$desktop_dir" "$icon_dir"
stage=$(mktemp -d "$app_dir/.obsidian-setup.XXXXXX")
trap 'rm -rf -- "$stage"' EXIT

echo '获取官网下载地址……'
curl -fsSL --retry 3 --connect-timeout 30 --max-time 120 \
    https://obsidian.md/download -o "$stage/download.html"
url=$(python3 - "$stage/download.html" "$architecture" <<'PY'
import re
import sys
from html.parser import HTMLParser
from pathlib import Path

class DownloadLinks(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
    def handle_starttag(self, tag, attrs):
        href = dict(attrs).get('href', '')
        if tag == 'a' and re.fullmatch(
            r'https://github\.com/obsidianmd/obsidian-releases/releases/download/[^/]+/Obsidian-[0-9.]+' + (r'-arm64' if sys.argv[2] == 'aarch64' else '') + r'\.AppImage', href
        ):
            self.links.append(href)

p = DownloadLinks()
p.feed(Path(sys.argv[1]).read_text())
if not p.links:
    raise SystemExit('未找到当前架构的 AppImage：官网链接格式可能已变化。旧程序未修改。')
print(p.links[0])
PY
)
echo "下载：$url"
curl -fL --retry 3 --connect-timeout 30 "$url" -o "$stage/Obsidian.AppImage"
python3 - "$stage/Obsidian.AppImage" "$architecture" <<'PY'
import sys
with open(sys.argv[1], 'rb') as f:
    header = f.read(20)
if header[:4] != b'\x7fELF' or header[8:11] != b'AI\x02':
    raise SystemExit('下载内容不是预期的 Type 2 AppImage，停止替换旧程序。')
expected_machine = 183 if sys.argv[2] == 'aarch64' else 62
if len(header) != 20 or header[4:6] != b'\x02\x01' or int.from_bytes(header[18:20], 'little') != expected_machine:
    raise SystemExit('下载内容的 ELF 架构不匹配，停止替换。')
PY
chmod 755 "$stage/Obsidian.AppImage"

echo '准备菜单图标……'
# 可用 OBSIDIAN_ICON 指定已验证的 SVG 备份，避免依赖官网样式。
if [[ -n ${OBSIDIAN_ICON:-} ]]; then
    cp -- "$OBSIDIAN_ICON" "$stage/source.svg"
else
curl -fsSL --retry 3 --connect-timeout 30 --max-time 120 \
    https://obsidian.md/favicon.svg -o "$stage/source.svg"
fi
python3 - "$stage/source.svg" "$stage/obsidian.svg" <<'PY'
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

source = Path(sys.argv[1]).read_text()
root = ET.fromstring(source)
ns = '{http://www.w3.org/2000/svg}'
if root.tag != ns + 'svg':
    raise SystemExit('下载内容不是 SVG，停止安装。')

# 将官网 CSS 类的基础颜色直接写入路径，兼容 NanoSVG。
# 从原图读取颜色，不固定使用某个色值。
styles = '\n'.join(e.text or '' for e in root.iter(ns + 'style'))
colors = {}
for cls, color in re.findall(r'\.([\w-]+)\s*\{[^{}]*?fill\s*:\s*(#[0-9A-Fa-f]{3,8})', styles):
    colors.setdefault(cls, color)
for element in root.iter():
    classes = element.get('class', '').split()
    for cls in classes:
        if cls not in colors:
            raise SystemExit('官网图标样式已变化，无法自动转换；旧程序未修改。')
        element.set('fill', colors[cls])
    if classes:
        del element.attrib['class']
for parent in root.iter():
    for child in list(parent):
        if child.tag == ns + 'style':
            parent.remove(child)
root.set('width', '256')
root.set('height', '256')
ET.register_namespace('', ns[1:-1])
ET.ElementTree(root).write(sys.argv[2], encoding='utf-8', xml_declaration=True)
PY

# 使用当前用户的绝对路径，避免菜单对 ~ 的解释差异。
python3 - "$app_dir/Obsidian.AppImage" "$icon_dir/obsidian.svg" "$stage/obsidian.desktop" <<'PY'
import sys
from pathlib import Path
app, icon, target = sys.argv[1:]
def value(s):
    return s.replace('\\', '\\\\').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
quoted = ''.join('\\' + c if c in '\\"`$' else c for c in app).replace('%', '%%')
Path(target).write_text(
    '[Desktop Entry]\nType=Application\nName=Obsidian\n'
    'Comment=Markdown 笔记与知识管理\n'
    f'Exec={value(chr(34) + quoted + chr(34))} %U\n'
    f'Icon={value(icon)}\nTerminal=false\nCategories=Office;\n', encoding='utf-8')
PY

# 下载及转换全部成功后才替换；已有文件保存时间戳备份。
stamp="$(date +%Y%m%d-%H%M%S)-$$"
for existing in "$app_dir/Obsidian.AppImage" "$icon_dir/obsidian.svg" "$desktop_dir/obsidian.desktop"; do
    if [[ -e "$existing" ]]; then
        cp -p -- "$existing" "$existing.backup-$stamp"
    fi
done
install -m 644 "$stage/obsidian.svg" "$icon_dir/obsidian.svg"
install -m 644 "$stage/obsidian.desktop" "$desktop_dir/obsidian.desktop"
mv -f -- "$stage/Obsidian.AppImage" "$app_dir/Obsidian.AppImage"

if command -v update-desktop-database >/dev/null; then
    update-desktop-database "$desktop_dir" || true
fi
echo '完成！关闭并重新打开应用菜单/fuzzel，搜索 Obsidian。'
echo "程序：$app_dir/Obsidian.AppImage"
echo "图标：$icon_dir/obsidian.svg"
echo 'DMS 若未刷新，可手动运行 dms restart；无需默认注销。'
echo '若 fuzzel 禁用了全部图标，可运行：fuzzel --override=icons-enabled=yes'
echo '以后先关闭 Obsidian，再运行本脚本即可更新。笔记库不受影响。'


```
