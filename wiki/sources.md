---
type: sources
status: draft
updated: 2026-10-22
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

## Codex 工作区会话来源规划（2026-10-21）

目标工作区：`/home/y/Documents/ChatGPT/archlinux环境搭建`。当前仅查询过项目和会话列表，未读取正文，未计为已收录；归档与历史覆盖尚未核查。用户在本次对话提出持续收录需求，尚无本地导出或内容指纹。流程草案见 [[wiki/questions/Codex 会话如何持续补充 Arch Linux Wiki]]。

### Waybar 会话样本读取（2026-10-21）

会话 `01a1596c-2611-7f63-bbf9-3cef95d90191`（搭建个性化 Waybar）：读取接口返回的唯一完成轮次，分页无更多内容；全文阅读工作区指南、JSONC、CSS 和备份路径文件。已用于收录方法评估，尚未形成正式配置指南；来源正文未导出，技术内容未全面复核。文件指纹、证据边界及下一步见 [[wiki/questions/Codex 会话如何持续补充 Arch Linux Wiki#Waybar 样本核对（2026-10-21）]]。其余会话仍未读取，归档范围未核查。

### 首次会话清单与归档覆盖（2026-10-21）

已从项目列表确认目标项目 ID 为 `9b6ccd92-8cb8-4f3e-b4f0-008a45725122`。未归档列表本次最多返回 50 条，缺少分页能力，因此以下是已发现清单，不宣称全部历史已枚举。另查询本机 Codex 归档列表，返回 1 条目标工作区记录，`nextCursor` 为空。按工作区路径补充项目 ID 为空的归档会话，按 ID 去重；同名会话不合并。

| 会话 ID | 原始标题 | 范围 | 处理状态 |
| --- | --- | --- | --- |
| `01a159b5-727a-7d32-a62d-4d7b1716a193` | 分析终端与 Shell 配置 | 未归档 | 待处理，正文未读 |
| `01a15c19-dde1-79e0-aaab-714f45b2f674` | 排查 Codex Add 无响应 | 未归档 | 部分处理，已读 4 轮对话消息；命令输出有截断，截图未读 |
| `01a159f8-a21e-72c1-bd37-f0dcb7a8b025` | 分析本机虚拟机安装方式 | 未归档 | 待处理，正文未读 |
| `01a15c21-3697-75a3-890e-2e60a9f7b2c2` | 创建醍醐骑车动画 HTML | 未归档 | 待处理，正文未读，主题归属待判断 |
| `01a159f9-4695-7d93-882f-732719197200` | 分析本机与 GitHub 账户配置 | 已归档 | 已处理本次快照 3 轮，真实账户操作待验证 |
| `01a159d0-78c4-79b0-8b8e-6fda1df0d3a0` | 制定软件安装方案 | 未归档 | 已处理本次快照的 6 轮消息与命令；安装与 GUI 待实践 |
| `01a1598a-f5c7-7531-abc0-5e6ec73e749d` | 查找 Rust 环境配置教程 | 已归档 | 已处理本次快照 3 轮，配置实践待验证 |
| `01a15993-3da8-7c62-9919-826beb922a33` | 推荐本机亮度调节组件 | 已归档 | 已处理当前 3 轮，作为 Waybar 子问题并入指南；硬件待验收 |
| `01a1596c-2611-7f63-bbf9-3cef95d90191` | 搭建个性化 Waybar | 未归档，用户要求保留 | 当前 1 轮已收录，会话持续中，后续内容待增量处理 |
| `01a1597d-e6fd-7882-8a1e-a70bedde4edf` | 创建醍醐骑车动画 HTML | 已归档，项目 ID 为空，工作区路径匹配 | 待处理，正文未读，主题归属待判断 |

清单不固定未来收录数量。后续应重新枚举更新状态；不能将本清单视为已经存在自动监听。

### 排错会话样本读取（2026-10-21）

“排查 Codex Add 无响应”已读取接口返回的 4 轮用户及助手消息，无下一页；带命令输出返回存在截断，截图未查看。仅用于收录方法评估，未独立复核根因或修复建议，未实施系统修改。需求演变、验收缺口与下一步见 [[wiki/questions/Codex 会话如何持续补充 Arch Linux Wiki#排错样本对收录规则的补充（2026-10-21）]]；正式收录前补读关键输出及核对上游证据。

## 软件安装会话收录（2026-10-21）

- 来源：[[sources/codex-sessions/制定软件安装方案]]，会话 ID `01a159d0-78c4-79b0-8b8e-6fda1df0d3a0`，工作区 `/home/y/Documents/ChatGPT/archlinux环境搭建`。读取接口返回 6 个完成轮次，hasMore=false；已读全部用户/助手消息和命令输出（未标记截断），不保存内部推理及搜索事件。此处理范围已完成，不代表未来追加内容自动收录。
- 来源快照 SHA-256：`f11bb054cb4cb4e6b0c646e71aff54a1b159f4b62478f707f59247d23cf402f6`。核对日期 2026-10-21；原会话更新时间字段为 `1792573172`，用于后续比较，不作为文件内容指纹。
- 关联：[[wiki/guides/Arch Linux 常用软件安装与维护]]，新增 `scripts/archlinux/install-desktop-apps.sh`。原会话仅给出安装方案；未据此声明安装完成。
- 外部核对：Arch Obsidian/ghostwriter 软件包页、微软 Linux 安装文档、Typora 商店授权说明及 AUR RPC 四包元数据；具体链接见指南。AUR/ArchWiki HTML 受防护拦截，未读 PKGBUILD；外部资料未固定版本。
- 下一步：会话追加时复查；安装前审核配方及目标环境，补软件功能与脚本实际部署结果。

## 查找 Rust 环境配置教程收录（2026-10-21）

- 来源：[[sources/codex-sessions/查找 Rust 环境配置教程]]，会话 ID `01a1598a-f5c7-7531-abc0-5e6ec73e749d`。已读接口返回全部 3 轮用户/助手消息及未标记截断的命令输出，hasMore=false；不包含 Side Chat。已处理本次快照，未来追加需复查。
- 来源 SHA-256：`08718238b5c3d8289eb260eb751f8f94e9312986d2adf3a40c6bad72dbf10029`。
- 结论落点：[[wiki/guides/Arch Linux 使用官网 rustup 配置与维护 Rust]]。整理阶段新增脚本，核对的外部官方资料及具体链接见指南；未固定外部资料版本。未执行真实安装、认证、克隆或推送。
- 下一步：按指南在实际环境验收，补齐实践证据；归档仅表示会话整理完成，不表示技术流程已实测。

## 分析本机与 GitHub 账户配置收录（2026-10-21）

- 来源：[[sources/codex-sessions/分析本机与 GitHub 账户配置]]，会话 ID `01a159f9-4695-7d93-882f-732719197200`。已读接口返回全部 3 轮用户/助手消息及未标记截断的命令输出，hasMore=false；不包含 Side Chat。已处理本次快照，未来追加需复查。
- 来源 SHA-256：`dfcbc22143c0bda2b7dbc231ed82c94ecd709cac2e1895b5043df5d68b08b544`。
- 结论落点：[[wiki/guides/GitHub 账户对应与 SSH 私有仓库使用]]。整理阶段新增脚本，核对的外部官方资料及具体链接见指南；未固定外部资料版本。未执行真实安装、认证、克隆或推送。
- 下一步：按指南在实际环境验收，补齐实践证据；归档仅表示会话整理完成，不表示技术流程已实测。

2026-10-21 收录后归档确认：Rust 与 GitHub 两个会话最新轮次均为已处理的完成轮次，归档工具确认 archived=true；未因归档将指南升级为 reviewed。

## LLM Wiki 设计参考（2026-10-21）

| 来源 | 已处理范围 | 关联 Wiki | 状态 | 核对日期 | 版本与下一步 |
| --- | --- | --- | --- | --- | --- |
| [[sources/Karpathy-LLM-Wiki]]（含原文链接） | 原文正文全部章节，不含评论；本地仅保存中文阅读卡 | [[wiki/guides/LLM Wiki 收录与维护流程]]、[[wiki/questions/仓库结构评估与优化方向]] | 已处理 | 2026-10-21 | 网页未固定上游修订号；规则调整时复核原文与本库需求 |

阅读卡 SHA-256：`fb6117d2870b092e52e30a640f57f157e591a158520a8337ec85e0a928267a13`。此指纹标识本地摘要，不是原文快照指纹；2026-10-04 的历史阅读记录继续保留。

## Shorin 初始化及更新（2026-10-21）

用户明确要求初始化并更新至上游最新状态。本次完成初始化、fetch origin main，并以 detached HEAD 检出上游默认分支 main 的 `534b285e108d949e03e46fce39296ade9e1eaf1d`（提交日期 2026-10-20）。旧基线为 `d8772456749981c0de3417a84c2783578603cfc6`；子模块工作区干净，主仓库 gitlink 工作区已变化，尚未提交。

- 当前可用性：已恢复，Wiki 引用文件与锚点检查通过；不能据此视为正文已重新收录。
- 范围：核对两个提交间的文件变动清单，阅读安装 Niri、桌面前准备、快照和系统维护三章的差异；README 与安装 Arch Linux 在这两个版本间无变化。新增 issues 正文未收录，其他上游内容未完整复核。
- 处理状态：安装 Niri、桌面前准备、快照和系统维护标为“需复查”，覆盖上方历史状态；其余条目保留原范围与内容核对日期。今天仅记录版本和差异检查，不覆盖历史正文核对日期。
- 关联页面：[[wiki/topics/Arch Linux 与桌面环境]] 与 [[wiki/guides/Arch Linux 安装资料阅读路线]] 已标 needs-verification；[[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]] 原有待验证状态不变，其 Shorin 来源对照仍待补充。
- 下一步：按关联页面复核表补文献及目标机证据，特别核对音频依赖、Niri 取色依赖、系统更新与 keyring 流程；未执行这些命令。

## Waybar 与背光联合收录（2026-10-21）

本节更新早期样本评估的最新状态，不改写历史记录。主指南：[[wiki/guides/Niri 个性化 Waybar 搭建与亮度调节]]；亮度属于 Waybar 的子问题，来源保持分开。Waybar 按用户明确要求不归档。

- [[sources/codex-sessions/搭建个性化 Waybar]]：ID `01a1596c-2611-7f63-bbf9-3cef95d90191`，读取当前 1 个完成轮次，hasMore=false；已读所有用户/助手消息及命令输出（未标记截断），不含 Side Chat。SHA-256：`25ac7210cb96b390468e8d4315737d49a263af545ffd44ee1588edf7bbefa394`。处理日期 2026-10-21；后续追加需重新核对。

- [[sources/codex-sessions/推荐本机亮度调节组件]]：ID `01a15993-3da8-7c62-9919-826beb922a33`，读取当前 3 个完成轮次，hasMore=false；已读所有用户/助手消息及命令输出（未标记截断），不含 Side Chat。SHA-256：`7e9ef8db3b62fe00a9ef2db48ef405beb45d1ea035690ab136a7192a5e40dc91`。处理日期 2026-10-21；后续追加需重新核对。

### 本次资产与外部文件指纹

提取原工作区初始配置为严格 JSON，本库样式补 backlight 规则；并未将当前用户样式当作原始模板。下列指纹只代表本次读取/生成，不替代历史版本。

| 文件 | SHA-256 |
| --- | --- |
| `wiki/assets/waybar/config.jsonc` | `a2e316235975cdd007420a80f1051cac5b79d26ed212a7ed22ab62cc26161886` |
| `wiki/assets/waybar/style.css` | `1a3419a8c0b1be89864ef16e7484c6b4f89c397f3a69a1a599535b04a139bca6` |
| `/home/y/Documents/ChatGPT/archlinux环境搭建/Waybar搭建指南.md` | `70a05375bccfe2bd9f6a4119f36d8b05fcf0ca3d021442548677de14f52a2f62` |
| `/home/y/Documents/ChatGPT/archlinux环境搭建/waybar/config.jsonc` | `f43b73661fc403c50475b808085bc1b97b54d2931a2c6790c8b19ddd1eedaa7a` |
| `/home/y/Documents/ChatGPT/archlinux环境搭建/waybar/style.css` | `1503ddda10193c73805e30bfc8a58f93855a6d69abe5546c1a8fb4b9dfc20aba` |
| `/home/y/.config/waybar/config.jsonc` | `747e05e2aca1d3f452b41784ad2916cf39c9621d2aa8305795e2674dbcd6b72b` |
| `/home/y/.config/waybar/style.css` | `19226765b34cc5595b7aa942480216505fef7c69ad3b3d956ba110a6529d57fe` |

外部文献范围：Waybar Configuration 的模块/信号/样式重载、Styling、backlight 手册、brightnessctl README 权限及命令手册；链接见指南。未审查第三方主题脚本。下一步补硬件及交互验收，按持续会话增量更新。

联合收录后状态：归档工具确认亮度子会话 archived=true。尝试明确设置 Waybar 未归档时，工具提示会话有 active writer，未执行该操作；随后只读查询本机会话库确认 Waybar archived=0，仍保持未归档。仅亮度当前快照整理完毕，Waybar 持续对话的后续内容仍待同步。

## 发布编辑版本（2026-10-22）

五份 codex-sessions 快照增加历史资料说明，本地文件超链接改为历史路径文本；原命令输出及对话内容保留原意。上列 SHA-256 更新为发布编辑后的文件指纹，不作为首次未编辑导出的指纹。四篇配置指南仅调整公开阅读表述与导航，技术核对日期仍为 2026-10-21。

## 本机应用分类清单（2026-10-22）

- 来源：[[sources/host-inventory/2026-10-22-本机应用分类清单]]；从用户指定的工作区文件原样复制，不修改原文件。原路径为 `/home/y/Documents/ChatGPT/archlinux环境搭建/软件清单/本机应用分类清单.md`。
- SHA-256：`849cb85fd013fb34c0380451e445e9513e45901c5bd769c06d43992067a1c160`；对应收录时完整文件字节。
- 已处理范围：总览、桌面入口、显式安装分类、包外用户工具与统计；程序核对完整明细 1062 个唯一包、146 显式及 916 依赖。未逐项核验底层包描述、实时状态或采集脚本。处理状态：部分处理；核对日期：2026-10-22。
- 配套 CSV、TXT、TSV 和生成脚本未收录或作为事实证据，原文文件名引用仅为历史上下文；不声称当前仓库包含这些文件。
- 关联：[[wiki/guides/Arch Linux 已安装应用盘点与维护]]、[[wiki/questions/Arch Linux 个性化配置复用计划]]。下一步：审阅采集材料、选择迁移模块并补生效配置与服务证据。
