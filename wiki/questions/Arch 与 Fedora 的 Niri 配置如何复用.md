---
type: question
status: draft
updated: 2026-10-03
sources:
  - sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装Niri.md
  - Fedora桌面配置相关/Fedora Minimal+Niri+DMS.md
  - notes/ArchLinux.md
---

# Arch 与 Fedora 的 Niri 配置如何复用

## 目前可复用的层次

两份资料都围绕 Niri 及其用户配置。[[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装Niri#Niri 配置文件修改|Shorin 的 Niri 配置章节]]与[[Fedora桌面配置相关/Fedora Minimal+Niri+DMS#niri美化及部分效率配置|Fedora 配置记录]]都指向 `~/.config/niri/config.kdl` 一类用户级设置。布局、快捷键和窗口规则可作为对照候选，但仍要核对 Niri 版本及所调用程序是否存在。

## 不能直接照搬的部分

| 部分 | Arch 来源 | Fedora 来源 | 核对点 |
| --- | --- | --- | --- |
| 软件安装 | [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装Niri#安装|Shorin 安装章节]]使用 `pacman` | [[Fedora桌面配置相关/Fedora Minimal+Niri+DMS#中文输入法|Fedora 输入法章节]]使用 `dnf` | 包名、软件源与版本分别查证 |
| 桌面组件 | Shorin 的页面逐项配置启动器、门户、锁屏等 | Fedora 笔记侧重 Niri + DMS，另有[[Fedora桌面配置相关/Fedora Minimal+Niri+DMS#niri美化及部分效率配置|效率配置]] | 同一快捷键实际调用哪个程序 |
| 输入法 | [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装Niri#安装中文输入法|Arch 的输入法章节]] | [[Fedora桌面配置相关/Fedora Minimal+Niri+DMS#中文输入法|Fedora 的输入法章节]] | 安装包、环境变量、启动方式、Rime 用户配置 |

## 下一次实践时记录

具体记录运行的发行版、Niri 和 DMS 版本；逐项写下配置路径、依赖程序、命令是否实际测试。之后可把稳定的跨发行版配置抽到单独的 Niri 概念页，把包安装步骤留在发行版专页。

相关：[[wiki/topics/Arch Linux 与桌面环境|Arch Linux 主题]]
