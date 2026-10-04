---
type: sources
status: draft
updated: 2026-10-04
sources: []
---

# 来源台账

“已处理范围”仅表示本次实际阅读并写入的章节，不代表原文件已完整消化。子模块属于独立仓库，页面引用时用主仓库内的相对路径。

| 来源 | 类型 | 已处理范围 | 关联 Wiki | 处理状态 | 内容核对日期 | 下一步 |
| --- | --- | --- | --- | --- | --- | --- |
| [[sources/Shorin-ArchLinux-Guide/README|Shorin 教程总入口]] | Git 子模块，提交 `d8772456749981c0de3417a84c2783578603cfc6`（2026-10-03 记录） | 目录与 Arch Linux 章节索引 | [[wiki/topics/Arch Linux 与桌面环境]] | 部分处理 | 2026-10-03（沿用日志记录） | 来源恢复后核对版本，再续读正文 |
| [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux|Shorin：安装 Arch Linux]] | 子模块教程 | 概念、方案简述、手动安装步骤标题 | [[wiki/guides/Arch Linux 安装资料阅读路线]] | 部分处理 | 2026-10-03（沿用日志记录） | 来源恢复后核对版本，再续读正文 |
| [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装桌面环境前的准备|Shorin：桌面前准备]] | 子模块教程 | 目录、用户与软件源章节 | [[wiki/guides/Arch Linux 安装资料阅读路线]] | 部分处理 | 2026-10-03（沿用日志记录） | 来源恢复后核对版本，再续读正文 |
| [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/快照和系统维护|Shorin：快照和系统维护]] | 子模块教程 | 目录与 Snapper 起始部分 | [[wiki/topics/Arch Linux 与桌面环境]] | 部分处理 | 2026-10-03（沿用日志记录） | 来源恢复后核对版本，再续读正文 |
| [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装Niri|Shorin：安装 Niri]] | 子模块教程 | 目录、Niri 介绍、安装入口 | [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]] | 部分处理 | 2026-10-03（沿用日志记录） | 来源恢复后核对版本，再续读正文 |
| [[notes/ArchLinux|自己的 Arch Linux 笔记]] | 个人笔记（默认只读） | 安装与桌面章节结构，部分步骤 | [[wiki/guides/Arch Linux 安装资料阅读路线]] | 部分处理 | 2026-10-03（沿用日志记录） | 续读未处理章节并更新关联页面 |
| [[Fedora桌面配置相关/Fedora Minimal+Niri+DMS|Fedora Minimal + Niri + DMS]] | 个人笔记（默认只读） | 输入法、DMS 与 Niri 配置相关章节 | [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]] | 部分处理 | 2026-10-03（沿用日志记录） | 续读未处理章节并更新关联页面 |
| [[角度传感器-姿态解算MPU6050/MPU6050汇总|MPU6050 汇总]] | 个人笔记（默认只读） | 全文 | [[wiki/topics/姿态解算与 MPU6050]] | 已处理 | 2026-10-03（沿用日志记录） | 随关联问题补充实践证据 |
| [[notes/姿态解算|姿态解算]] | 个人笔记（默认只读） | 全文；其中“9 轴”说法待查 | [[wiki/concepts/MPU6050 的姿态数据从哪里来]] | 已处理 | 2026-10-03（沿用日志记录） | 核对芯片与驱动证据；已读完不代表说法已验证 |
| [[角度传感器-姿态解算MPU6050/MPU6050姿态解算方式1-DMP|MPU6050 DMP 剪藏]] | 网页剪藏 | 基础、DMP、四元数转欧拉角章节 | [[wiki/concepts/MPU6050 的姿态数据从哪里来]] | 部分处理 | 2026-10-03（沿用日志记录） | 续读未处理章节并更新关联页面 |
| [[角度传感器-姿态解算MPU6050/MPU6050姿态解算2-欧拉角&旋转矩阵|MPU6050 软件解算剪藏]] | 网页剪藏 | IMU、旋转约定、加速度计章节 | [[wiki/concepts/MPU6050 的姿态数据从哪里来]] | 部分处理 | 2026-10-03（沿用日志记录） | 续读未处理章节并更新关联页面 |
| [[notes/移植DMP库|移植 DMP 库]] | 个人笔记（默认只读） | 标题结构；代码尚未逐段核验 | [[wiki/topics/姿态解算与 MPU6050]] | 部分处理 | 2026-10-03（沿用日志记录） | 按目标 SDK 核对代码与 I²C 实现 |

## 结构评估参考与环境观察

- [Karpathy：LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)：2026-10-04 阅读正文全部章节，不含评论区；用于 [[wiki/questions/仓库结构评估与优化方向]]。
- 2026-10-04 当前工作树的 Shorin 子模块未初始化，gitlink 仍为 `d8772456749981c0de3417a84c2783578603cfc6`。2026-10-03 日志中的未提交改动是历史观察，不代表当前工作树状态。本次只核验来源可用性，未重新核对内容。

## 状态与版本记录

- 待处理：尚未阅读；部分处理：只完成列出的章节；已处理：已读完并整合约定范围；需复查：来源变更或新证据可能影响既有结论。
- 处理状态描述收录进度，与 Wiki 页面的审核状态独立。来源不可用也不抹去历史收录进度。
- 后续收录时记录来源提交或 SHA-256、内容核对日期和影响页面。现有个人笔记没有收录时的指纹，标记为“未记录”；不以今天的哈希冒充历史版本。Shorin 条目共用上表提交基线。
- 优先顺序：核对 MPU6050 的“9 轴”证据 → 明确 DMP 目标工程与验证材料 → 来源可用后补 Niri 版本和依赖对照。证据不足时保留问题，不补写未经验证的结论。

## 待处理来源

- Shorin 子模块中其余 Arch Linux 章节，以及已列文件的未处理正文；更新子模块后要复查相关页面。
- `Clippings/` 的 Kalman 滤波剪藏、MPU6050 其他教程和附件图示。
- `notes/` 中嵌入式、Linux、网络和电赛等主题资料。

## Niri 对照收录（2026-10-04）

本节更新对应来源的最新处理范围；其他旧条目的核对日期不变。下列指纹针对本次读取的完整文件字节，收录范围仍限于所列章节。关联页面：[[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]]。

| 来源 | 本次已处理范围 | 状态 | 下一步 |
| --- | --- | --- | --- |
| [[notes/ArchLinux]] | 从“niri+自行搭建其他组件”到文末的桌面与登录管理器内容 | 部分处理 | 补目标机器版本与实际启动方式 |
| [[notes/niri配置文件config.kdl]] | 全文：验证、终端、显示器、鼠标、通知与语言入口 | 已处理 | 用目标配置验证路径、设备参数和组件依赖 |
| [[notes/Linux中文环境及中文输入法]] | 全文已阅读；整合 Niri/Fcitx 环境与启动差异，未验证第三方词库或模型 | 部分处理 | 检查目标应用的工具包、运行后端和输入表现 |
| [[Fedora桌面配置相关/Fedora Minimal+Niri+DMS]] | 中文环境/输入法；截图方式表与基础截图至 Swappy 绑定；Niri 美化及效率配置至锁屏 | 部分处理 | 提供实际版本与运行配置，实测输入、门户和锁屏 |

本次没有修改或初始化 Shorin 子模块，也没有将未读子模块正文视为新增证据。脚本文档仅查看开头以确认其为 Obsidian 安装脚本，未作为 Niri 对照依据。

### 本次文件指纹（SHA-256）
- notes/ArchLinux.md：`C53A6C662934A0F1EBC6BAB776924B9B57675670C0E6CF20BA3F689140A8B6D6`
- notes/niri配置文件config.kdl.md：`A2339C7EF477FC343FDEBDD8F4E35318E82E50D7AA75DE0F40C8D3CEFF23D5D7`
- notes/Linux中文环境及中文输入法.md：`EADE5223E68C553099A14F253F325B4DF3F4404513E8CE3BB52CA06091BDC1FB`
- Fedora桌面配置相关/Fedora Minimal+Niri+DMS.md：`0EE40DB64A8D58D72CF4FACAF3AFD064953CD5D979D82A366469927A1A327CB4`

### 外部文献核对范围

访问日期均为 2026-10-04；采用网页当时内容，未固定到上游提交。只核对相关段落，不标记整站或整页完整收录。

- [Niri 配置入口](https://niri-wm.github.io/niri/Configuration%3A-Introduction.html)：路径、验证、热重载、块合并。
- [Niri Layout](https://niri-wm.github.io/niri/Configuration%3A-Layout.html) 和 [Window Rules](https://niri-wm.github.io/niri/Configuration%3A-Window-Rules.html)：焦点环层级与圆角。
- [Niri Miscellaneous](https://niri-wm.github.io/niri/Configuration%3A-Miscellaneous.html)：prefer-no-csd 与 screenshot-path。
- [Niri 配套软件](https://niri-wm.github.io/niri/Important-Software.html)：门户、认证代理与会话条件。
- [Niri Xwayland](https://niri-wm.github.io/niri/Xwayland.html)：自动集成的版本条件。
- [DMS 安装](https://danklinux.com/docs/dankmaterialshell/installation)：会话集成和重复启动；[DMS IPC](https://danklinux.com/docs/dankmaterialshell/keybinds-ipc)：锁屏接口。
- [Fcitx Wayland](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland/en)：应用后端与输入法变量；不采纳其已声明可能过时的 Chromium 默认行为作为本次结论。
