---
type: guide
status: needs-verification
updated: 2026-10-24
sources:
  - sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux.md
  - sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装桌面环境前的准备.md
  - sources/Shorin-ArchLinux-Guide/wiki/archlinux/快照和系统维护.md
  - notes/ArchLinux.md
---

# Arch Linux 安装资料阅读路线

## 快速使用

按安装阶段定位资料，先确定硬件、分区和引导方案。

执行范围：阅读路线不提供通用一键安装命令。

复用要点：复用决策顺序；分区、ESP、设备名及引导必须按目标机器重新确认。

操作细节：[[wiki/guides/Arch Linux 安装资料阅读路线#按阶段查资料]]。

按需跳转：[先定方案](#%E5%85%88%E5%AE%9A%E6%96%B9%E6%A1%88) · [按阶段查资料](#%E6%8C%89%E9%98%B6%E6%AE%B5%E6%9F%A5%E8%B5%84%E6%96%99) · [来源更新复核（2026-10-21）](#%E6%9D%A5%E6%BA%90%E6%9B%B4%E6%96%B0%E5%A4%8D%E6%A0%B8%EF%BC%882026-10-21%EF%BC%89)。

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

## 来源更新复核（2026-10-21）

Shorin 已由 `d8772456749981c0de3417a84c2783578603cfc6` 更新到 `534b285e108d949e03e46fce39296ade9e1eaf1d`（上游 main）。已核对相关章节差异及本页链接目标，未逐条复核技术结论或执行命令。

| 状态 | 证据缺口与下一步 | 结论落点 |
| --- | --- | --- |
| 待验证 | 桌面前准备新增 rtkit 依赖；系统维护修改更新习惯与长期未更新处理说明。对照官方文档及目标系统核对适用条件 | 本页阅读路线与适用条件 |
| 待验证 | Niri 依赖列表移除 hyprpicker；结合目标配置核对取色入口及依赖，不直接迁移配置 | [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]] |

上述为上游差异记录，不是安装建议或实践验收；来源台账保留原处理范围。
