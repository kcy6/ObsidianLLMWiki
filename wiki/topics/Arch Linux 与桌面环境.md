---
type: topic
status: needs-verification
updated: 2026-10-22
sources:
  - sources/Shorin-ArchLinux-Guide/README.md
  - sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux.md
  - sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装Niri.md
  - sources/Shorin-ArchLinux-Guide/wiki/archlinux/快照和系统维护.md
  - notes/ArchLinux.md
  - Fedora桌面配置相关/Fedora Minimal+Niri+DMS.md
---

# Arch Linux 与桌面环境

## 当前资料怎样分工

- [[sources/Shorin-ArchLinux-Guide/README|Shorin 教程总入口]] 是外部教程地图。其 Arch 部分按安装、桌面前准备、显卡、维护、桌面环境、输入法等主题分章。它作为子模块保留了上游目录和修订历史。
- [[notes/ArchLinux|自己的 Arch Linux 笔记]] 把安装、软件源、快照、Niri 与 DMS 等经验写在同一篇里，适合核对自己曾采用的方案和遇到的问题。
- [[Fedora桌面配置相关/Fedora Minimal+Niri+DMS|Fedora Minimal + Niri + DMS]] 记录另一套系统上的桌面实际配置。关于 Niri 的知识可以关联阅读；发行版的软件安装命令、源与系统服务须分别判断。

## 学习路线

1. 从 [[wiki/guides/Arch Linux 安装资料阅读路线|安装资料阅读路线]] 了解安装方案及风险点，再进入 Shorin 的[[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux#重要概念讲解|概念章节]]与[[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux#手动安装|操作章节]]。
2. 基础系统可启动后，阅读[[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装桌面环境前的准备|桌面前准备]]。个人笔记相同主题可能反映自己的选择，不自动视为上游教程的最新版本。
3. 若选 Btrfs 和 GRUB，再研究[[sources/Shorin-ArchLinux-Guide/wiki/archlinux/快照和系统维护|快照与维护]]。教程中的回档步骤依赖具体分区与启动布局，须先确认本机布局。
4. 桌面阶段从[[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装Niri|Shorin 的 Niri 教程]]和[[Fedora桌面配置相关/Fedora Minimal+Niri+DMS|Fedora 实践记录]]对照；跨发行版复用要看[[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用|配置复用问题]]。

## 目前的知识缺口

- 自己的 Arch 安装笔记与子模块教程有较多同类步骤；尚未逐项比对分区、ESP、引导、包来源与快照策略。
- 子模块更新后需要重新核对命令和章节位置。执行系统命令前，应以当前官方文档和本机状态为准。

相关：[[wiki/index|知识库首页]] · [[wiki/sources|来源台账]]

## Niri 对照进展

已按本地笔记与官方文档补充 [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用|Arch/Fedora 配置对照]]，区分发行版包来源、Niri 原生配置、DMS 与外部组件；目标版本和桌面实测尚待补充。Shorin 子模块正文仍未重新核验。

## 常用应用安装

[[wiki/guides/Arch Linux 常用软件安装与维护]] 提炼软件安装会话，覆盖开发编辑器、笔记与 Markdown 阅读、QQ/微信；附手动操作、默认预览的安装脚本及维护验收要求。安装与桌面功能尚待实践验证。

- [[wiki/guides/Arch Linux 使用官网 rustup 配置与维护 Rust]]：会话提炼、手动配置、默认预览脚本及后续维护，真实环境仍待验证。

- [[wiki/guides/GitHub 账户对应与 SSH 私有仓库使用]]：会话提炼、手动配置、默认预览脚本及后续维护，真实环境仍待验证。

## 来源更新复核（2026-10-21）

Shorin 已由 `d8772456749981c0de3417a84c2783578603cfc6` 更新到 `534b285e108d949e03e46fce39296ade9e1eaf1d`（上游 main）。已核对相关章节差异及本页链接目标，未逐条复核技术结论或执行命令。

| 状态 | 证据缺口与下一步 | 结论落点 |
| --- | --- | --- |
| 待验证 | 桌面前准备新增 rtkit 依赖；系统维护修改更新习惯与长期未更新处理说明。对照官方文档及目标系统核对适用条件 | 本页阅读路线与适用条件 |
| 待验证 | Niri 依赖列表移除 hyprpicker；结合目标配置核对取色入口及依赖，不直接迁移配置 | [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]] |

上述为上游差异记录，不是安装建议或实践验收；来源台账保留原处理范围。

## Waybar 与亮度组件

[[wiki/guides/Niri 个性化 Waybar 搭建与亮度调节]] 将顶栏布局、美化和背光组件统一整理。Waybar 会话尚未结束，暂不归档；模块与硬件验收缺口在指南中持续追踪。

## 应用基线与新机复用

[[wiki/guides/Arch Linux 已安装应用盘点与维护]] 维护带日期的软件与应用基线；[[wiki/questions/Arch Linux 个性化配置复用计划]] 跟踪将本机个性化配置复用到新 Arch 主机的后续目标，尚未实现完整部署工具。

### 软件方案增量（2026-10-22）

[[wiki/guides/Arch Linux 常用软件安装与维护]] 已扩充 Telegram 依赖排错、Papers/Apostrophe 替换意向、微信包辨析，以及 OBS、Fractal、Workbench、Gradia；安装方案与实际功能验收分开维护。
