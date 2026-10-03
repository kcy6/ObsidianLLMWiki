

### nmcli
[[Linux nmcli 命令]]
==nmcli 是 NetworkManager 的命令行工具，用于在 Linux 系统中配置和管理网络连接。它是 NetworkManager 的官方客户端，提供了比图形界面更强大和灵活的网络管理能力。==

让 NetworkManager 尝试启用并连接名为 `enp0s31f6` 的网络设备（网卡）。
```shell
nmcli device connect enp0s31f6 #enp0s31f6网卡名
```

### ip
[[Linux ip 命令]]

**判断 Linux 网卡有没有 IP，以及系统的数据包会往哪里走**。
```shell
ip addr
ip -br addr #-br brief，简洁模式
```
查看 Linux 内核当前的路由表。
```shell
ip route
```
