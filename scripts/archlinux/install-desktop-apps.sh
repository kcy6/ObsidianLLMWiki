#!/usr/bin/env bash
# 整理阶段新增；默认预览。使用方法见 Wiki 指南。
set -euo pipefail
apply=0
helper=''
repo=()
aur=()
flatpak_apps=()
usage() {
  echo '用法: bash install-desktop-apps.sh [--apply] [--helper yay|paru] obsidian|markdown|vscode|code-oss|chat|telegram|telegram-webview|papers|apostrophe|obs|fractal|gradia|workbench|wps|pacseek|serial ...'
  echo '默认只打印计划；--apply 执行所选渠道安装（pacman 阶段完整升级），保留交互确认。'
  echo 'workbench 指 GNOME Workbench，使用已有 flathub remote；不自动添加远端。'
}
while (($#)); do
  case "$1" in
    --apply) apply=1 ;;
    --helper)
      shift
      (($#)) || { usage >&2; exit 2; }
      case "$1" in yay|paru) helper=$1 ;; *) usage >&2; exit 2 ;; esac ;;
    obsidian) repo+=(obsidian) ;;
    markdown) repo+=(ghostwriter cmark-gfm) ;;
    vscode) aur+=(visual-studio-code-bin) ;;
    code-oss) repo+=(code) ;;
    chat) aur+=(linuxqq wechat-bin) ;;
    telegram) repo+=(telegram-desktop) ;;
    telegram-webview) repo+=(telegram-desktop webkitgtk-6.0) ;;
    papers) repo+=(papers) ;;
    apostrophe) repo+=(apostrophe) ;;
    obs) repo+=(obs-studio) ;;
    fractal) repo+=(fractal) ;;
    gradia) repo+=(gradia) ;;
    workbench) flatpak_apps+=(re.sonny.Workbench) ;;
    wps) aur+=(wps-office-cn wps-office-mui-zh-cn) ;;
    pacseek) aur+=(pacseek) ;;
    serial) repo+=(minicom); aur+=(tabby-bin cutecom) ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知选项：$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done
((${#repo[@]} + ${#aur[@]} + ${#flatpak_apps[@]})) || { usage >&2; exit 2; }
# 防止用户在同一计划里选择相互冲突的两个编辑器发行版。
if [[ " ${repo[*]} " == *' code '* && " ${aur[*]} " == *' visual-studio-code-bin '* ]]; then
  echo 'vscode 与 code-oss 请只选择一个。' >&2; exit 2
fi
if ((${#aur[@]})); then
  if [[ -z "$helper" ]]; then
    if command -v yay >/dev/null; then helper=yay
    elif command -v paru >/dev/null; then helper=paru
    else helper=yay; fi
  fi
  repo+=(base-devel git)
fi
# 去重，保留参数顺序。
dedupe() {
  local item
  local -A seen=()
  for item in "$@"; do
    if [[ -z "${seen[$item]+x}" ]]; then printf '%s\n' "$item"; seen[$item]=1; fi
  done
}
if ((${#repo[@]})); then mapfile -t repo < <(dedupe "${repo[@]}"); fi
if ((${#aur[@]})); then mapfile -t aur < <(dedupe "${aur[@]}"); fi
if ((${#flatpak_apps[@]})); then mapfile -t flatpak_apps < <(dedupe "${flatpak_apps[@]}"); fi
show() { printf '  '; printf '%q ' "$@"; printf '\n'; }
echo '计划（pacman 阶段包含完整系统升级；AUR 配方需在交互流程中自行审阅）：'
if ((${#repo[@]})); then show sudo pacman -Syu --needed "${repo[@]}"; fi
if ((${#aur[@]})); then show "$helper" -S --needed "${aur[@]}"; fi
if ((${#flatpak_apps[@]})); then show flatpak install flathub "${flatpak_apps[@]}"; fi
((apply)) || { echo '仅预览；增加 --apply 才执行。'; exit 0; }
((EUID != 0)) || { echo '请以普通用户运行，勿 sudo 整个脚本。' >&2; exit 1; }
[[ -r /etc/os-release ]] || { echo '缺少系统标识。' >&2; exit 1; }
# 不把用户提供的环境文件作为可执行 shell 加载。
grep -Eq '^ID=(arch|"arch")$' /etc/os-release || { echo '仅支持 Arch Linux。' >&2; exit 1; }
for tool in pacman sudo mktemp; do command -v "$tool" >/dev/null || { echo "缺少 $tool" >&2; exit 1; }; done
if ((${#aur[@]})); then command -v "$helper" >/dev/null || { echo "缺少 $helper，请先按其官方说明安装辅助工具。" >&2; exit 1; }; fi
if ((${#flatpak_apps[@]})); then
  command -v flatpak >/dev/null || { echo '缺少 flatpak；请先准备安装渠道。' >&2; exit 1; }
  remotes=$(flatpak remotes --columns=name)
  grep -Fxq flathub <<< "$remotes" || { echo '未找到 flathub remote；请先核对并配置远端及安装范围。' >&2; exit 1; }
fi
if [[ " ${aur[*]} " == *' wechat-bin '* ]] && pacman -Q wechat-appimage >/dev/null 2>&1; then
  echo '检测到 wechat-appimage；请按指南处理渠道选择，不自动替换。' >&2; exit 1
fi
# 避免在未留意的情况下接受已安装发行版的替换。
if [[ " ${aur[*]} " == *' visual-studio-code-bin '* ]] && pacman -Q code >/dev/null 2>&1; then
  echo '检测到 code；请先按指南备份并处理发行版切换。' >&2; exit 1
fi
if [[ " ${repo[*]} " == *' code '* ]] && pacman -Q visual-studio-code-bin >/dev/null 2>&1; then
  echo '检测到微软版 VS Code；请先按指南备份并处理发行版切换。' >&2; exit 1
fi
umask 077
state_root=${XDG_STATE_HOME:-$HOME/.local/state}/wiki-desktop-apps
mkdir -p -- "$state_root"
state_dir=$(mktemp -d "$state_root/run-XXXXXXXX")
pacman -Q > "$state_dir/packages-before.txt"
pacman -Qqe > "$state_dir/explicit-before.txt"
printf '%s\n' "${repo[@]}" "${aur[@]}" "${flatpak_apps[@]}" > "$state_dir/requested.txt"
echo "执行记录：$state_dir（包清单不是数据备份或系统快照）"
trap 'code=$?; printf "%s\n" "$code" > "$state_dir/exit-code.txt"; exit "$code"' EXIT
if ((${#repo[@]})); then sudo pacman -Syu --needed "${repo[@]}"; fi
if ((${#aur[@]})); then "$helper" -S --needed "${aur[@]}"; fi
if ((${#repo[@]} + ${#aur[@]})); then pacman -Q "${repo[@]}" "${aur[@]}" > "$state_dir/selected-after.txt"; fi
if ((${#flatpak_apps[@]})); then
  flatpak list --app > "$state_dir/flatpak-before.txt"
  flatpak install flathub "${flatpak_apps[@]}"
  flatpak list --app > "$state_dir/flatpak-after.txt"
fi
echo '安装事务完成；请按 Wiki 完成图形界面、输入法、文件和通知验收。'
