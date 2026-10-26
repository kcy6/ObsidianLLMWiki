---
type: guide
status: needs-verification
updated: 2026-10-26
sources:
  - sources/codex-sessions/终端开发环境分层方案-2026-10-26摘录.md
  - sources/codex-sessions/Vim 搜索与高亮增量-2026-10-23摘录.md
  - sources/codex-sessions/分析终端与 Shell 配置-2026-10-22会话摘录.md
  - sources/codex-sessions/查找 Kitty 中复制 Vim 内容的方法-2026-10-22会话摘录.md
  - scripts/archlinux/stage-session-config.py
---

# Kitty 与 Zsh 终端配置和复制操作

## 快速使用

终端外观、交互 Shell、提示符与 Vim 分开查。

```vim
:echo has('clipboard')
:syntax on
```

执行范围：在 Vim 命令模式执行；前者只读，后者仅启用当前会话语法颜色。

复用要点：Kitty、Zsh、Starship 分文件合并；插件来自系统包，个人配置保留普通文件。

操作细节：[[wiki/guides/Kitty 与 Zsh 终端配置和复制操作#日常效率与 Vim 复制]]。

按需跳转：[最终方案与不再采用的方案](#%E6%9C%80%E7%BB%88%E6%96%B9%E6%A1%88%E4%B8%8E%E4%B8%8D%E5%86%8D%E9%87%87%E7%94%A8%E7%9A%84%E6%96%B9%E6%A1%88) · [手动配置](#%E6%89%8B%E5%8A%A8%E9%85%8D%E7%BD%AE) · [脚本配置与生效](#%E8%84%9A%E6%9C%AC%E9%85%8D%E7%BD%AE%E4%B8%8E%E7%94%9F%E6%95%88) · [日常效率与 Vim 复制](#%E6%97%A5%E5%B8%B8%E6%95%88%E7%8E%87%E4%B8%8E-vim-%E5%A4%8D%E5%88%B6) · [后续维护与待办](#%E5%90%8E%E7%BB%AD%E7%BB%B4%E6%8A%A4%E4%B8%8E%E5%BE%85%E5%8A%9E) · [Vim 搜索定位与空 vimrc](#vim-%E6%90%9C%E7%B4%A2%E5%AE%9A%E4%BD%8D%E4%B8%8E%E7%A9%BA-vimrc) · [收录与验证范围](#%E6%94%B6%E5%BD%95%E4%B8%8E%E9%AA%8C%E8%AF%81%E8%8C%83%E5%9B%B4)。

来源：[分析终端与 Shell 配置](../../sources/codex-sessions/%E5%88%86%E6%9E%90%E7%BB%88%E7%AB%AF%E4%B8%8E%20Shell%20%E9%85%8D%E7%BD%AE-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md) · [查找 Kitty 中复制 Vim 内容的方法](../../sources/codex-sessions/%E6%9F%A5%E6%89%BE%20Kitty%20%E4%B8%AD%E5%A4%8D%E5%88%B6%20Vim%20%E5%86%85%E5%AE%B9%E7%9A%84%E6%96%B9%E6%B3%95-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md)。

## 最终方案与不再采用的方案

来源覆盖 31 轮终端配置和 1 轮 Vim 复制说明。最终方案为 Kitty + Zsh + 独立插件 + Starship，工具和插件交给 pacman，个人配置保留原位置的普通文件。早期的 Fish/Oh My Zsh/p10k 比较属于选型过程，不是同时启用的组件。

Starship 已从自定义 `starship-git.zsh` 切回原生 Git 模块；动态绿/黄背景逻辑不再维护。会话先创建 dotfiles 并推送，随后用户明确撤销，本地链接恢复为普通文件并删除该仓库；远端删除由用户负责，来源没有完成证据。本指南不重建该私有仓库、不把其旧路径作为当前依赖。

## 手动配置

```bash
sudo pacman -Syu --needed kitty zsh starship zsh-autosuggestions zsh-syntax-highlighting ttf-jetbrains-mono-nerd fzf zoxide
```

先备份 `~/.zshrc`、`~/.config/zsh/interactive.zsh`、`~/.config/starship.toml`、`~/.config/kitty/kitty.conf` 及其引用的 theme 文件。安装包不自动决定加载顺序；`.zshrc` 依次加载交互配置、自动建议、fzf/zoxide、Starship，语法高亮通常最后加载。不编辑 `/usr/share/zsh/plugins/` 的发行版文件。见 [Starship 初始化](https://starship.rs/guide/) 和 [fzf Shell 集成](https://github.com/junegunn/fzf)。

[最小终端模板](../assets/session-templates/terminal/zshrc.example)采用系统包插件和原生 Git，不复刻全部历史色块。`fzf --zsh` 要求安装版本支持该接口；旧版应按对应包的集成文件调整。配置仅在交互式 Zsh 加载，不能在 Fish 中 source Zsh 文件。试用 Fish 可运行 `fish` 后 `exit`，不必改变登录 Shell；脚本通过 shebang 或 `bash file.sh` 指定解释器，与当前交互 Shell 分开。

来源最终外观：单行紧凑提示符、左侧系统/路径/Git、右侧状态与超过 3 秒的耗时；原生 Git 以符号显示状态。Kitty 后续采用 Catppuccin Mocha、12 号 Nerd Font、12 像素留白、竖线光标、不额外透明。字体和 ANSI 调色板影响色块，不能仅比较提示符文件判断颜色完全相同。配色可用 `kitten themes` 选择；[Kitty 配置文档](https://sw.kovidgoyal.net/kitty/conf/)。

## 脚本配置与生效

```bash
python3 scripts/archlinux/stage-session-config.py terminal --output /tmp/terminal-review
python3 scripts/archlinux/stage-session-config.py terminal --output /tmp/terminal-review --apply
```

第一条只预览；第二条只生成新目录中的示例，**不会部署到主目录**。比较后把 `interactive.zsh` 放到 `~/.config/zsh/`，将 zshrc 示例按块合并至原入口，按需合并 Kitty 与 Starship 配置。文件名带 example 表示学习模板，不是原终端配置完整备份；不创建符号链接、不改登录 Shell。

```bash
zsh -n ~/.zshrc
zsh -n ~/.config/zsh/interactive.zsh
# 检查通过后，在保留一个可用终端的前提下：
exec zsh
```

Starship 通常下个提示符生效；Kitty 用默认 `Ctrl+Shift+F5` 或重开窗口。来源报告过成功/失败/耗时及 Git 多状态输出检查，但未重测所有字体、长路径和窄窗口。最小模板仅验证语法和生成，不能宣称与历史外观完全一致。

## 日常效率与 Vim 复制

| 操作 | 功能及边界 |
| --- | --- |
| fzf Ctrl+R | 搜索历史，回填后再次确认才执行 |
| Ctrl+T / Alt+C | 插入路径 / 进入当前目录下选中的子目录 |
| `z 关键词` / `zi` | 回到已访问目录 / 交互选择；记录少时先正常 cd |
| Shift+鼠标拖选，Ctrl+Shift+C | Kitty 复制终端可见文字，避免 Vim 捕获鼠标 |
| `"+yy`、可视选择后 `"+y`、`:%y+` | Vim 系统剪贴板寄存器；先查 `:echo has('clipboard')` |
| `yy` / `p` | Vim 内部寄存器，不保证进入桌面剪贴板 |

Vim 的 `+clipboard` 不等于原生 Wayland 连接已就绪；功能不可用时可选择 Kitty 复制，或用 `wl-copy < 文件` 复制完整文本（会替换剪贴板）。含私密内容时先判断是否应复制，不能把终端历史作为可公开配置。

## 后续维护与待办

软件随完整系统更新；分别维护交互、提示符、终端外观。保留源码配置，历史文件按私人数据处理，补全缓存无需迁移。`starship timings` 的小仓库耗时不能代表大型仓库。

Yazi 退出后让 Shell 跟随目录的包装函数仅在会话中提出、未获准实施，不能写成已配置。需要时单独核对上游示例。新机验收至少包括新终端启动、历史/补全/高亮、fzf 三个快捷键、z/zi、普通及 Git 目录、Vim/系统剪贴板和备份恢复。

## Vim 搜索定位与空 vimrc

会话新增五轮：用户最终希望采用简洁定位方式，没有确认应用复杂闪光函数。搜索后按 `zz` 居中；可选 `nnoremap n nzz` 与 `nnoremap N Nzz`，初次 `/` 回车后仍需手动 zz。`hlsearch` 是搜索匹配，`syntax on` 是语法颜色，二者分开排查。

历史检查发现 ~/.vimrc 为0字节；助手判断它使默认 defaults.vim 不再自动加载。用户尚未确认具体创建操作，也没有配置修改验收。建议先用 `:scriptnames`、`:set compatible?` 核对实际加载链，再决定是否在 vimrc 开头加入 `source $VIMRUNTIME/defaults.vim`；该文件可能设置多项默认值，应放个人覆盖项之前。仅临时开启颜色可用 `:syntax on`；KDL 是否识别与高亮支持另查 `:set filetype?`。完整建议及证据边界见新增来源。

## 按用途复用终端窗口

常驻平铺与临时浮动的快捷键、app-id、规则顺序、透明度和进程继承统一见 [[wiki/guides/Niri 中 Kitty 常驻与浮动终端配置]]（[配置指南](Niri%20中%20Kitty%20常驻与浮动终端配置.md)）。本页维护Shell与终端基础，避免在两处重复保存整套窗口规则。

## Rust、C与嵌入式开发分层

Kitty提供终端容器，不直接提供IDE语言服务。来源仅讨论可行方案，尚未选择Neovim为主编辑器、安装插件或完成硬件调试部署。[方案来源](../../sources/codex-sessions/终端开发环境分层方案-2026-10-26摘录.md)

| 层次 | 候选组件 | 复用时记录 |
| --- | --- | --- |
| 终端/交互 | Kitty、Zsh、现有fzf/zoxide/Git | 快捷键、Shell入口；不因编辑器方案重建终端全部配置 |
| 编辑器 | Neovim | 是否作为主编辑器、插件版本与配置 |
| 语言服务 | Rust rust-analyzer；C clangd | 项目根目录、编译参数和工具链版本 |
| 构建与调试 | Cargo、Make/CMake/Ninja；GDB/LLDB及调试适配器 | 构建命令、启动目标与调试配置 |
| 嵌入式目标 | 交叉编译器、烧录/调试服务器、串口工具 | 芯片/板卡、探针、权限和固件下载方式 |

先用一个Rust和一个C项目验证编辑、跳转、构建、格式化，再接桌面调试，最后按板卡接硬件工具；图形芯片配置工具可能仍需保留。纯选型不生成安装器、不默认加入tmux或复杂插件。现有Rust入口见 [[wiki/guides/Arch Linux 使用官网 rustup 配置与维护 Rust]]。

## 收录与验证范围

2026-10-22：阅读所列会话用户消息与最终答复，工具输出按相关主题抽查，未逐行重新审计全部历史执行；来源摘录不包含全部工具输出、内部推理或 Side Chat。历史截图未逐张核验。指南保持 needs-verification，实际部署、图形交互和恢复应按正文验收后补记录。所有工作区会话的归档状态保持不变。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]] · [[wiki/sources]]

公开阅读入口：[知识库导航](../index.md) · [仓库说明](../../README.md)
