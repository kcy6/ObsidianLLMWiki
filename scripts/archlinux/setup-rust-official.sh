#!/usr/bin/env bash
# 整理阶段新增；默认预览，不改 shell 启动文件。
set -euo pipefail
apply=0
case "${1:-}" in '') ;; --apply) apply=1 ;; -h|--help) echo '用法: bash setup-rust-official.sh [--apply]'; exit 0 ;; *) echo '仅支持 --apply 或 --help' >&2; exit 2 ;; esac
(($# <= 1)) || exit 2
echo '计划：官网 rustup，stable + default profile + rust-analyzer/rust-src；保留已有默认工具链；不修改 shell 配置。'
echo '新安装将下载 https://sh.rustup.rs 并运行官方安装器；已有用户级 rustup 时补齐 stable 和组件。'
((apply)) || { echo '仅预览；使用 --apply 执行。'; exit 0; }
((EUID != 0)) || { echo '请以普通用户运行。' >&2; exit 1; }
[[ -z ${CARGO_HOME:-} || $CARGO_HOME == "$HOME/.cargo" ]] || { echo '自定义 CARGO_HOME 请改用手动流程。' >&2; exit 1; }
[[ -z ${RUSTUP_HOME:-} || $RUSTUP_HOME == "$HOME/.rustup" ]] || { echo '自定义 RUSTUP_HOME 请改用手动流程。' >&2; exit 1; }
command -v cc >/dev/null || { echo '缺少系统链接器 cc；先准备编译依赖。' >&2; exit 1; }
if command -v pacman >/dev/null; then
  for package in rust rustup; do
    if pacman -Q "$package" >/dev/null 2>&1; then echo "检测到 pacman 包 $package；先手动选择迁移方案，脚本不覆盖。" >&2; exit 1; fi
  done
fi
rustup_bin=$HOME/.cargo/bin/rustup
if [[ ! -x $rustup_bin ]]; then
  for tool in rustup rustc cargo; do
    if command -v "$tool" >/dev/null; then echo "已有 $tool 入口，请先核对来源，停止自动安装。" >&2; exit 1; fi
  done
  command -v curl >/dev/null || { echo '缺少 curl。' >&2; exit 1; }
  temp_dir=$(mktemp -d)
  trap 'rm -rf -- "$temp_dir"' EXIT
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "$temp_dir/rustup-init.sh"
  sh "$temp_dir/rustup-init.sh" -y --no-modify-path --profile default --default-toolchain stable
fi
"$rustup_bin" toolchain install stable --profile default --component rust-analyzer --component rust-src
"$rustup_bin" show
"$HOME/.cargo/bin/rustc" +stable --version
"$HOME/.cargo/bin/cargo" +stable --version
echo '工具链命令检查完成；仍需编译项目验证。当前父 shell 未改变，请 source "$HOME/.cargo/env" 或新开已配置环境的终端。'
