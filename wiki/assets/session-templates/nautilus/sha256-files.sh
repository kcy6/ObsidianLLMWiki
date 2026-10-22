#!/usr/bin/env bash
# Nautilus 脚本示例：仅打印所选参数文件的校验值，不批量删除或改写文件。
set -euo pipefail
(($#)) || { echo '请选择文件。'; exit 2; }
sha256sum -- "$@"
