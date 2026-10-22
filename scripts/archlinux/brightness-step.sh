#!/usr/bin/env bash
# 运行时辅助脚本；按最大原始值计算 5% 下限，不把原始值 5 误作通用 5%。
set -euo pipefail
[[ $# == 2 && ( $1 == up || $1 == down ) && $2 =~ ^[A-Za-z0-9_-]+$ ]] || { echo '用法: brightness-step.sh up|down 背光设备' >&2; exit 2; }
direction=$1; device=$2
current=$(brightnessctl -d "$device" get)
maximum=$(brightnessctl -d "$device" max)
[[ $current =~ ^[0-9]+$ && $maximum =~ ^[0-9]+$ ]] || exit 1
current=$((10#$current));maximum=$((10#$maximum))
((maximum > 0 && current <= maximum)) || exit 1
minimum=$(((maximum * 5 + 99) / 100))
step=$minimum
if [[ $direction == up ]]; then next=$((current + step)); else next=$((current - step)); fi
((next < minimum)) && next=$minimum
((next > maximum)) && next=$maximum
brightnessctl -d "$device" set "$next"
