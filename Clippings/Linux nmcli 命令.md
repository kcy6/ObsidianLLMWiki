---
title: "Linux nmcli 命令"
source: "https://www.runoob.com/linux/linux-comm-nmcli.html"
author:
published:
created: 2026-09-14
description: "Linux nmcli 命令  Linux 命令大全  什么是 nmcli nmcli 是 NetworkManager 的命令行工具，用于在 Linux 系统中配置和管理网络连接。它是 NetworkManager 的官方客户端，提供了比图形界面更强大和灵活的网络管理能力。 nmcli 的主要特点  全功能支持：几乎涵盖所有 NetworkManager 的功能 脚本友好：适合自动化脚本和远程管理 无依赖：不需要图形界面，纯命令行操作.."
tags:
  - "clippings"
---
[Linux 命令大全](https://www.runoob.com/linux/linux-command-manual.html)

---

## 什么是 nmcli

nmcli 是 NetworkManager 的命令行工具，用于在 Linux 系统中配置和管理网络连接。它是 NetworkManager 的官方客户端，提供了比图形界面更强大和灵活的网络管理能力。

### nmcli 的主要特点

- **全功能支持** ：几乎涵盖所有 NetworkManager 的功能
- **脚本友好** ：适合自动化脚本和远程管理
- **无依赖** ：不需要图形界面，纯命令行操作
- **实时反馈** ：立即显示命令执行结果

---

## nmcli 基础语法

nmcli 的基本命令格式如下：

```
nmcli [OPTIONS] OBJECT { COMMAND | help }
```

### 常用 OBJECT 类型

- `general` ：NetworkManager 常规状态和操作
- `networking` ：整体网络控制
- `radio` ：无线网络开关
- `connection` ：网络连接配置
- `device` ：网络设备管理

### 常用 OPTIONS 选项

| 选项 | 说明 |
| --- | --- |
| `-t` | 简洁输出（适合脚本处理） |
| `-p` | 漂亮输出（更易读） |
| `-h` | 显示帮助信息 |
| `-v` | 显示版本信息 |

---

## 常用 nmcli 命令详解

### 1\. 查看网络状态

查看 NetworkManager 整体状态：

## 实例

nmcli general status

输出示例：

```
STATE      CONNECTIVITY  WIFI-HW  WIFI     WWAN-HW  WWAN    
connected  full          enabled  enabled  enabled  enabled
```

### 2\. 管理网络连接

列出所有网络连接：

## 实例

nmcli connection show

激活/停用连接：

## 实例

nmcli connection up "连接名"  
nmcli connection down "连接名"

### 3\. 管理网络设备

列出所有网络设备：

## 实例

nmcli device status

输出示例：

```
DEVICE  TYPE      STATE      CONNECTION 
eth0    ethernet  已连接    有线连接 1 
wlan0   wifi      已断开    --         
lo      loopback  未托管    --
```

查看设备详细信息：

## 实例

nmcli device show eth0

---

## 无线网络管理

### 扫描可用 WiFi 网络

## 实例

nmcli device wifi list

### 连接到 WiFi 网络

## 实例

nmcli device wifi connect "SSID名称" password "密码"

### 创建新的 WiFi 连接配置

## 实例

nmcli connection add type wifi ifname wlan0 con-name "我的WiFi" ssid "SSID名称"  
nmcli connection modify "我的WiFi" wifi-sec.key-mgmt wpa-psk  
nmcli connection modify "我的WiFi" wifi-sec.psk "密码"

---

## 有线网络配置

### 创建静态 IP 连接

## 实例

nmcli connection add type ethernet ifname eth0 con-name "静态连接" \\  
ip4 192.168.1.100/24 gw4 192.168.1.1  
nmcli connection modify "静态连接" ipv4.dns "8.8.8.8,8.8.4.4"

### 修改现有连接为 DHCP

## 实例

nmcli connection modify "连接名" ipv4.method auto

---

## 高级用法

### 创建 VPN 连接

## 实例

nmcli connection add type vpn vpn-type openvpn \\  
con-name "我的VPN" ifname tun0 \\  
vpn.data "remote=vpn.example.com, username=user, password=pass"

### 创建网桥

## 实例

nmcli connection add type bridge ifname br0 con-name "我的网桥"  
nmcli connection add type bridge-slave ifname eth0 master br0

### 创建 VLAN

## 实例

nmcli connection add type vlan ifname eth0.100 con-name "VLAN100" \\  
dev eth0 id 100 ip4 192.168.100.100/24

---

## 常见问题解决

### 1\. 网络设备显示"未托管"

## 实例

\# 检查 NetworkManager.conf  
cat /etc/NetworkManager/NetworkManager.conf  
  
\# 如果看到 unmanaged-devices 配置，可以注释掉相关行  
\# 然后重启 NetworkManager  
systemctl restart NetworkManager

### 2\. 忘记连接密码

## 实例

nmcli connection show "连接名" | grep psk

### 3\. 重置网络配置

## 实例

nmcli connection reload

---

## 实践练习

1. 使用 nmcli 连接到你的 WiFi 网络
2. 创建一个静态 IP 的有线连接
3. 扫描并列出所有可用的 WiFi 网络
4. 查看当前活跃连接的详细信息

---

## 总结

nmcli 是 Linux 系统网络管理的强大工具，通过本文的学习，你应该能够：

- 理解 nmcli 的基本概念和语法结构
- 使用 nmcli 管理有线和无线网络连接
- 配置静态 IP 和 DHCP 连接
- 处理常见的网络连接问题

掌握 nmcli 可以让你在没有图形界面的服务器环境中高效管理网络，也是 Linux 系统管理员的重要技能之一。

[Linux 命令大全](https://www.runoob.com/linux/linux-command-manual.html)