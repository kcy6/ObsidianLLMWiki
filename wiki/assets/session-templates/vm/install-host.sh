#!/usr/bin/env bash
set -euo pipefail
if [[ ${1:-} != --apply ]]; then
  echo '预览：sudo pacman -Syu --needed qemu-desktop libvirt virt-manager edk2-ovmf dnsmasq swtpm'
  echo '仅安装软件；服务模式、用户组、NAT、虚拟机创建仍需按指南操作。'
  exit 0
fi
sudo pacman -Syu --needed qemu-desktop libvirt virt-manager edk2-ovmf dnsmasq swtpm
