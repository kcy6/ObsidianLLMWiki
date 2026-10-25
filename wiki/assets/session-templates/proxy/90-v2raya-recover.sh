#!/bin/sh
# 待审阅模板：先替换接口名，再人工安装。仅处理 Wi-Fi up，不修改 DNS。
# 整理阶段新增；未在真实重连/开机环境验收。
interface='WIFI_INTERFACE'
[ "$interface" != 'WIFI_INTERFACE' ] || exit 0
[ "${1:-}" = "$interface" ] || exit 0
[ "${2:-}" = 'up' ] || exit 0
/usr/bin/systemctl is-active --quiet v2raya.service || exit 0
/usr/bin/logger -t v2raya-recover 'Wi-Fi up; requesting active v2rayA restart'
/usr/bin/systemctl --no-block try-restart v2raya.service
