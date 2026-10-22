---
type: guide
status: needs-verification
updated: 2026-10-22
sources:
  - sources/project-notes/shorin-niri-347ca890-学习笔记.md
  - sources/codex-sessions/拉取并逐步学习 shorin-niri-2026-10-22会话摘录.md
---

# shorin-niri 源码学习与配置迁移路线

适用条件与来源日期在正文中分别列明；占位路径、设备名与版本须按目标环境调整。以下是知识收录，不代表已在新机器完成部署。

来源：[拉取并逐步学习 shorin-niri](../../sources/codex-sessions/%E6%8B%89%E5%8F%96%E5%B9%B6%E9%80%90%E6%AD%A5%E5%AD%A6%E4%B9%A0%20shorin-niri-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md)。

## 固定阅读基线

项目是桌面预设与集成工具，不是 Niri 合成器实现。来源学习目录的 HEAD 为 `347ca890cacf818989984171792fbe5602f1ca69`；本次只读核对这一值、入口和布局片段，并阅读来源学习笔记，不更新上游仓库、不运行 init/update/remove。

完整来源笔记保存在 [[sources/project-notes/shorin-niri-347ca890-学习笔记]]，其分析范围和历史测试声明不能当作此轮重新测试结果。[固定提交入口](https://github.com/SHORiN-KiWATA/shorin-niri/tree/347ca890cacf818989984171792fbe5602f1ca69)

## 手动阅读与练习

1. 先读 README，再看 `shorinniri` 命令入口及依赖/同步函数；不要一开始执行安装命令。仅 clone 不等于模板已部署到 `/usr/share/shorin-niri`。
2. `dotfiles/.config/niri/config.kdl` include 快捷键、布局和窗口规则；KDL 不是 SQL 或 Shell。区分必需 include 与 optional include，文件存在不等于入口引用。
3. `Mod+Z` 对应启动 fuzzel；`Mod+R` 执行列宽内部动作。`preset-column-widths` 定义循环预设约1/3、1/2、2/3；`default-column-width { proportion 0.5; }` 决定新列宽度。`gaps 10` 控制间距，修改练习仅在副本进行。
4. 从 Waybar config 的模块顺序追到 modules 行为、脚本与 CSS；截图、录屏按钮可能调用外部工程，不能只看模块名就推断实现。
5. 从 Waypaper post_command 追到 Matugen 模板、output_path 和刷新 hook。模板与生成文件分开维护；同名脚本不一定是当前实际调用入口。
6. 阅读保护机制与临时 HOME 测试，再做复制失败、目录越界、并发写入练习。来源报告 Bash 语法和保护测试通过，未验收桌面、显示器或录屏。

[配置入口](https://github.com/SHORiN-KiWATA/shorin-niri/blob/347ca890cacf818989984171792fbe5602f1ca69/dotfiles/.config/niri/config.kdl)与[布局文件](https://github.com/SHORiN-KiWATA/shorin-niri/blob/347ca890cacf818989984171792fbe5602f1ca69/dotfiles/.config/niri/layout.kdl)可对照本页学习。

## 脚本流程与迁移边界

这里已有上游 `shorinniri`，不另造一份等价安装器。其 init/update/remove 会涉及软件依赖、HOME 文件、系统设置，不是只读学习命令。来源笔记指出 init 与 update 的保护规则不同，update 可能跳过整份 Niri 目录；remove 并非所有初始化效果的逆操作。

脚本学习步骤：在单独副本固定提交 → 读 case 分支和调用链 → 在临时 HOME 中检查保护测试实现 → 明确外部命令及系统写入后才运行适用测试。**真实 HOME 中不执行 init 作为阅读练习**。本库没有提供该项目全量代码、依赖或安装包，避免复制粘贴一条命令就覆盖现有桌面。

迁移前比较已配置的 Kitty/Zsh 与项目 Fish、现有 Waybar 与项目主题、Niri 官方版/补丁版与预设所需 fork；部分 KDL 扩展不能仅凭版本号推断兼容。先逐文件确认、自有配置白名单备份，再选择模块，不默认改用整套预设。

## 后续维护与待办

上游版本变化按提交比较实际读取文件，检查依赖、保护行为和生成物；不要只看 README 的概括性备份说明。当前交互学习仅完成入口、快捷键及列宽概念，不应把七课路线图称为已完成七课。待继续学习部署、保护、主题链、IPC、录屏与失败恢复。

关联 [[wiki/questions/Arch Linux 个性化配置复用计划]] 和 [[wiki/guides/Niri 个性化 Waybar 搭建与亮度调节]]；来源笔记提及的历史 dotfiles 结构仅为上游结构，不撤销用户“不建立自用 dotfiles 仓库”的决定。

## 收录与验证范围

2026-10-22：阅读所列会话用户消息与最终答复，工具输出按相关主题抽查，未逐行重新审计全部历史执行；来源摘录不包含全部工具输出、内部推理或 Side Chat。历史截图未逐张核验。指南保持 needs-verification，实际部署、图形交互和恢复应按正文验收后补记录。所有工作区会话的归档状态保持不变。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]] · [[wiki/sources]]

公开阅读入口：[知识库导航](../index.md) · [仓库说明](../../README.md)
