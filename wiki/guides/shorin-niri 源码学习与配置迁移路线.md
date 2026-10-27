---
type: guide
status: needs-verification
updated: 2026-10-27
sources:
  - sources/codex-sessions/项目功能链学习路线调整-2026-10-27摘录.md
  - sources/codex-sessions/同步失败传播与计数练习-2026-10-26摘录.md
  - sources/codex-sessions/Kitty 浮动终端与窗口规则-2026-10-26摘录.md
  - sources/codex-sessions/shorin-niri 学习增量-2026-10-23摘录.md
  - sources/project-notes/shorin-niri-347ca890-学习笔记.md
  - sources/codex-sessions/拉取并逐步学习 shorin-niri-2026-10-22会话摘录.md
---

# shorin-niri 源码学习与配置迁移路线

## 快速使用

按调用链阅读，区分源码、系统模板与 HOME 生效配置。

执行范围：纯阅读；不以 init/update/remove 作为入门练习。

复用要点：固定阅读提交，逐模块比较现有配置；更新保护不等于初始化或卸载保护。

操作细节：[[wiki/guides/shorin-niri 源码学习与配置迁移路线#脚本流程与迁移边界]]。

按需跳转：[固定阅读基线](#%E5%9B%BA%E5%AE%9A%E9%98%85%E8%AF%BB%E5%9F%BA%E7%BA%BF) · [手动阅读与练习](#%E6%89%8B%E5%8A%A8%E9%98%85%E8%AF%BB%E4%B8%8E%E7%BB%83%E4%B9%A0) · [脚本流程与迁移边界](#%E8%84%9A%E6%9C%AC%E6%B5%81%E7%A8%8B%E4%B8%8E%E8%BF%81%E7%A7%BB%E8%BE%B9%E7%95%8C) · [后续维护与待办](#%E5%90%8E%E7%BB%AD%E7%BB%B4%E6%8A%A4%E4%B8%8E%E5%BE%85%E5%8A%9E) · [Bash 语法学习入口](#bash-%E8%AF%AD%E6%B3%95%E5%AD%A6%E4%B9%A0%E5%85%A5%E5%8F%A3) · [源码学习进度](#%E6%BA%90%E7%A0%81%E5%AD%A6%E4%B9%A0%E8%BF%9B%E5%BA%A6) · [收录与验证范围](#%E6%94%B6%E5%BD%95%E4%B8%8E%E9%AA%8C%E8%AF%81%E8%8C%83%E5%9B%B4)。

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

## Bash 语法学习入口

新增 [[wiki/guides/Bash 脚本语法速通与 shorinniri 阅读练习]]（[阅读指南](Bash%20脚本语法速通与%20shorinniri%20阅读练习.md)），依据2026-10-24完成稿，覆盖基础语法、进程、锁、错误传播及复制模板；本轮基础学习已结束，不再自动安排练习。这不表示原七课路线或源码迁移已完成。

## 源码学习进度

新增八轮已覆盖 layout 参数练习、普通 Kitty 与 quickterminal 的 app-id 区别、`niri msg pick-window` 查询与 --class 指定标识的不同用途，以及源码目录→系统模板→HOME 配置的路径关系。保护匹配判断已练习：相同路径或“规则加斜杠”的子路径匹配；仅 update 调用保护判断，init 不受此保护。

2026-10-23的主会话曾停在 backup_and_copy 路径推导；2026-10-24的Shell完成稿已补复制、同步与失败传播读码，旧待答位置不再作为当前任务。其他项目课程与实际部署仍未完成。脚本语法学习另有持续更新笔记，见 [[wiki/guides/Bash 脚本语法速通与 shorinniri 阅读练习]]；新增配置语言路线见 [[wiki/guides/JSON TOML KDL 配置文件的学习与排错]]。

## 终端窗口调用链

2026-10-26新增七轮学习已转向常驻/浮动Kitty：路径推导完成，随后学习app-id、透明度层次、规则覆盖、尺寸位置与单实例。可复用配置统一维护于 [[wiki/guides/Niri 中 Kitty 常驻与浮动终端配置]]。后续七轮又覆盖单实例取舍、sticky与layer-shell区别、panel试验及回退；最终恢复普通浮动终端，并回到backup_and_copy备份失败的代码分析。项目课程与部署验收未完成，不以会话下一题安排自动启动本次学习任务。

## 同步错误处理的三层检查

备份cp失败不自动停止下一条rm；backup_and_copy必须检查并返回失败，外层同步函数必须处理它，最外层init/update入口也须检查。来源四轮练习已区分return只退出函数、continue进入下一项、exit结束脚本。

| 策略 | 循环内 | 循环后/最外层 |
| --- | --- | --- |
| 首次失败即停 | 检查复制状态后return非零 | 最外层检查同步状态并exit，阻止后续系统设置 |
| 失败后继续 | 记录失败数并continue，成功分支才计成功 | fail_count大于0返回1，否则0；最外层仍检查 |

继续处理不代表全成功，停止也不会回滚此前成功文件。以上仅教学修改，未写回项目。完整语法和模板见 [[wiki/guides/Bash 脚本语法速通与 shorinniri 阅读练习#失败处理]]；避免再次在本页复制整套函数。依据 [[sources/codex-sessions/同步失败传播与计数练习-2026-10-26摘录]]。

## 按完整功能链学习

2026-10-26后续三轮收束exit/return区别和NUL枚举，用户认为碎片语法题过慢，路线改为四个功能模块：Waybar按钮→壁纸配色→窗口/录屏IPC→部署定制。25%–30%仅是来源教学覆盖估计，不作为能力或验收百分比。

| 模块 | 要找的调用链 | 交付或检查 |
| --- | --- | --- |
| Waybar截图 | 布局引用→modules定义→截图脚本→CSS | 指出模块移动、事件交换与字号分别改何处 |
| 壁纸配色 | Waypaper→Matugen模板/输出→应用刷新 | 区分生成物与模板 |
| 动态工具 | Niri IPC/JSON→进程状态→信号更新 | 解释状态与刷新接口 |
| 部署定制 | 依赖→保护→备份复制→失败传播 | 模块选择、验收及回退 |

截图例子的关键知识：slurp选区，grim输出图像到stdout，wl-copy接收，通知另发；这条链没有写截图文件。右键wl-longshot-menu是外部依赖，不能只由本仓库解释其完整行为；没有pipefail的管道也不能只由末端成功证明全部阶段成功。模块名custom/screenshot对应CSS ID #custom-screenshot；实际点击路径指向HOME部署副本，直接启动仓库JSONC不自动改为仓库脚本路径。

依据 [[sources/codex-sessions/项目功能链学习路线调整-2026-10-27摘录]]；本轮只整理读码与任务，不运行截图、不覆盖桌面配置。语法知识继续回链 [[wiki/guides/Bash 脚本语法速通与 shorinniri 阅读练习]]，避免重复逐题教学。


## 收录与验证范围

2026-10-22：阅读所列会话用户消息与最终答复，工具输出按相关主题抽查，未逐行重新审计全部历史执行；来源摘录不包含全部工具输出、内部推理或 Side Chat。历史截图未逐张核验。指南保持 needs-verification，实际部署、图形交互和恢复应按正文验收后补记录。所有工作区会话的归档状态保持不变。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]] · [[wiki/sources]]

公开阅读入口：[知识库导航](../index.md) · [仓库说明](../../README.md)
