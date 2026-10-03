---
type: guide
status: draft
updated: 2026-10-03
sources:
  - sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux.md
  - sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装桌面环境前的准备.md
  - sources/Shorin-ArchLinux-Guide/wiki/archlinux/快照和系统维护.md
  - notes/ArchLinux.md
---

# Arch Linux 安装资料阅读路线

这页是阅读与核对清单，**不是可直接复制执行的安装脚本**。安装涉及磁盘分区与引导，需先确认机器状态和你选择的方案。

## 先定方案

[[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux#安装方案简述|Shorin 的方案简述]]采用 UEFI、独立 ESP、Btrfs 的 `@` 与 `@home` 子卷、GRUB、ZRAM 加硬盘 Swap、NetworkManager。这是一套相互关联的选择。[[notes/ArchLinux#Arch Linux手动安装|自己的安装笔记]]也覆盖 UEFI、分区、Swap、GRUB 和网络；再次安装时，要先标出哪些步骤属于自己目前的电脑，而不是混合两份教程的命令。

## 按阶段查资料

| 阶段 | 查看位置 | 需要记录的本机信息 |
| --- | --- | --- |
| 启动与联网 | [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux#手动安装|手动安装]]；[[notes/ArchLinux#live环境|自己的 live 环境记录]] | 启动模式、网络接口、目标磁盘 |
| 分区与挂载 | [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux#硬盘分区|硬盘分区]]、[[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux#正式挂载|正式挂载]] | 哪些分区已有数据、ESP 挂载点、子卷布局 |
| 基础系统与引导 | [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux#安装系统|安装系统]]、[[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux#安装引导程序|安装引导程序]] | CPU、内核、引导器及实际挂载结果 |
| 首次启动后的账户与软件 | [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装桌面环境前的准备|桌面前准备]]；[[notes/ArchLinux#安装桌面环境前准备|个人记录]] | 普通用户、软件源、显卡与桌面选择 |
| 快照与维护 | [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/快照和系统维护|快照和系统维护]] | Btrfs 子卷、`/boot` 和 ESP 的位置、回档目标 |

[[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux#ESP 挂载点|ESP 章节]]特别讨论了 Btrfs 快照与内核文件放置位置的关系。这一判断依赖引导与挂载布局；采用别的文件系统、加密或多系统方案时应重新核对。涉及磁盘改动的具体命令以教程当前版本、Arch 官方安装指南和本机设备信息为准。

相关：[[wiki/topics/Arch Linux 与桌面环境|Arch Linux 主题]] · [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用|桌面配置复用]]
