---
type: index
status: draft
updated: 2026-10-27
sources: []
---

# 知识库

按要完成的任务查指南，按具体操作查命令。历史会话与原文在来源台账中追溯。

- **查命令与快捷键**：[[wiki/guides/Arch Linux 命令与快捷键速查]]（[公开阅读](guides/Arch%20Linux%20命令与快捷键速查.md)）。
- **准备新机复用**：[[wiki/questions/Arch Linux 个性化配置复用计划]]（Shell＋Git首版六模块与实施批次）。
- **查看主题路线**：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/topics/姿态解算与 MPU6050]]。

## 桌面、输入与文件管理

- [[wiki/guides/Niri 个性化 Waybar 搭建与亮度调节]]：模块/点击行为、CSS选择器与圆角排错、亮度设备。
- [[wiki/guides/Niri 桌面的暗色外观与 GTK Qt 配置]]：按 GTK、Qt、终端、状态栏和应用分别设置主题。
- [[wiki/guides/Niri 文件选择器与桌面应用入口排错]]：按启动器、应用、Portal、面板顺序缩小问题范围。
- [[wiki/guides/Nautilus 书签与文件缓存维护]]：书签用 UI 管理；缓存先看候选再决定是否清理。
- [[wiki/guides/Fcitx5 浅色主题定制与更新维护]]：复制出独立主题再定制，避免上游同名更新覆盖。

## 终端、开发与配置语法

- [[wiki/guides/Niri 中 Kitty 常驻与浮动终端配置]]：app-id、规则顺序、背景透明、窗口尺寸位置及进程复用。

- [[wiki/guides/Arch Linux 使用官网 rustup 配置与维护 Rust]]：区分工具链、项目依赖与 Shell PATH。
- [[wiki/guides/GitHub 账户对应与 SSH 私有仓库使用]]：分别检查提交署名、仓库地址和 SSH 认证。
- [[wiki/guides/Kitty 与 Zsh 终端配置和复制操作]]：终端外观、交互 Shell、提示符与 Vim 分开查。
- [[wiki/guides/shorin-niri 源码学习与配置迁移路线]]：按调用链阅读，区分源码、系统模板与 HOME 生效配置。
- [[wiki/guides/Bash 脚本语法速通与 shorinniri 阅读练习]]：按知识点查 Bash、失败处理和复制模板；基础速通已结束。
- [[wiki/guides/JSON TOML KDL 配置文件的学习与排错]]：先辨格式，再查应用支持的键和版本。

## 软件、网络与虚拟机

- [[wiki/guides/Arch Linux 常用软件安装与维护]]：按用途选安装渠道，再安装或排查应用。
- [[wiki/guides/Arch Linux 已安装应用盘点与维护]]：查应用清单、安装原因和入口故障；历史总数不代表实时状态。
- [[wiki/guides/Arch Linux KVM 虚拟机与 Fedora 文件传输]]：宿主机管理 KVM，客体提供 SSH，文件通过 SFTP/scp 传输。
- [[wiki/guides/v2rayA 主代理与 v2rayN 备用配置]]：主备用切换、DNS复发诊断、基础解析与重连恢复。

## 安装与跨机器复用

- [[wiki/guides/Arch Linux 安装资料阅读路线]]：按安装阶段定位资料，先确定硬件、分区和引导方案。
- [[wiki/questions/Arch Linux 个性化配置复用计划]]：Wiki与配置工程分工、工具比较、SHORiN仓库借鉴及新机复用路线。
- [[wiki/questions/Fedora 日用系统检查与跨系统交接]]：本机审计与交接范围。
- [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]]：配置分层和验证步骤。

## 示例与其他专题

- [[wiki/topics/姿态解算与 MPU6050]]：DMP、软件解算与移植资料。
- [[wiki/concepts/MPU6050 的姿态数据从哪里来]]：传感器、DMP 与姿态表示。
- [[wiki/questions/姿态解算待验证问题]]：证据缺口与验证计划。
- [[wiki/guides/离线 SVG 骑车动画示例与维护]]：下载仓库后打开 HTML，按 SVG/CSS/按钮脚本分层修改。

## 仓库维护

- [[wiki/guides/LLM Wiki 收录与维护流程]]：按知识点组织来源综合，维护索引、台账和检查结果。
- [[sources/Karpathy-LLM-Wiki]]：设计参考文章的原文链接与中文阅读卡。
- [[wiki/AGENTS]]：AI 执行规则。
- [[wiki/sources]]：来源范围、状态、版本与下一步。
- [[wiki/log]]：维护历史。
- [[wiki/questions/仓库结构评估与优化方向]]：持续优化记录。
- [[wiki/questions/LLM Wiki 仓库结构评估]]：2026-10-04 历史评估快照。
- [[wiki/questions/Codex 会话如何持续补充 Arch Linux Wiki]]：经用户确认的会话收录约定及样本分析。


[GitHub 指南列表](../README.md#arch-linux-配置指南) · [[wiki/sources|来源与覆盖范围]] · [[wiki/log|维护记录]]

- [[wiki/guides/Niri 登录入口与 swaylock 锁屏配置]]：开机登录与锁屏区别、外观参数、模板与回退。
