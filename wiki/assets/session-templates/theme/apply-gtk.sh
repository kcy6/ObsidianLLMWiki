#!/usr/bin/env bash
set -euo pipefail
if [[ ${1:-} != --apply ]]; then
  echo '预览：设置 color-scheme=prefer-dark，gtk-theme=Adwaita-dark；--apply 才应用。'
  exit 0
fi
((EUID != 0)) || { echo '请以桌面普通用户运行。' >&2; exit 1; }
command -v gsettings >/dev/null
umask 077
backup=$(mktemp -d "${TMPDIR:-/tmp}/wiki-gtk-before-XXXXXXXX")
gsettings get org.gnome.desktop.interface color-scheme > "$backup/color-scheme.txt"
gsettings get org.gnome.desktop.interface gtk-theme > "$backup/gtk-theme.txt"
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
echo "旧值：$backup；Qt/Fuzzel/Mako 仍需分别合并。"
