---
type: guide
status: needs-verification
updated: 2026-10-26
sources:
  - wiki/guides/Kitty 与 Zsh 终端配置和复制操作.md
  - wiki/guides/Arch Linux 常用软件安装与维护.md
  - wiki/guides/Arch Linux 使用官网 rustup 配置与维护 Rust.md
  - wiki/guides/GitHub 账户对应与 SSH 私有仓库使用.md
  - wiki/guides/Niri 个性化 Waybar 搭建与亮度调节.md
  - wiki/guides/v2rayA 主代理与 v2rayN 备用配置.md
  - wiki/guides/Arch Linux KVM 虚拟机与 Fedora 文件传输.md
  - wiki/guides/Nautilus 书签与文件缓存维护.md
  - wiki/guides/Niri 文件选择器与桌面应用入口排错.md
  - wiki/guides/Niri 桌面的暗色外观与 GTK Qt 配置.md
  - wiki/guides/Fcitx5 浅色主题定制与更新维护.md
---

# Arch Linux 命令与快捷键速查

日常检索入口；命令来自下列现有指南，条件、来源和恢复流程以相应正文为准。终端命令默认按 Bash/Zsh 理解；Vim 冒号命令在 Vim 内执行。`包名`、`用户@客体IP` 和文件路径是待替换值。

## 快捷键与 Vim

| 想做什么 | 操作 | 条件或效果 |
| --- | --- | --- |
| Kitty 复制可见文字 | Shift+鼠标拖选 → Ctrl+Shift+C | Kitty 接管选择；不是复制文件全文 |
| Vim 复制全文到系统剪贴板 | `:%y+` | 依赖 clipboard 支持及可用桌面剪贴板连接 |
| 查询 Vim 剪贴板支持 | `:echo has('clipboard')` | 1表示编译支持，不保证 Wayland 已连接 |
| 搜索后定位当前行 | `zz` | 居中显示，不修改文件 |
| 下一个/上一个匹配 | `n` / `N` | 相对当前搜索方向移动 |
| 清除搜索高亮 | `:noh` | 清除当前显示，不关闭语法颜色 |
| 临时恢复语法颜色 | `:syntax on` | 当前 Vim 会话；无颜色时再检查 filetype 和启动配置 |
| 搜历史 | Ctrl+R | 已加载 fzf 集成时可搜索回填；执行前确认 |
| 回常用目录 | `z 关键词` / `zi` | 需要 zoxide 初始化和已有访问记录 |

详见 [[wiki/guides/Kitty 与 Zsh 终端配置和复制操作]]（[指南](Kitty%20与%20Zsh%20终端配置和复制操作.md)）。

## 只读检查与预览

以下不安装软件或修改配置；网络查询、日志读取和工具初始化仍可能受环境或权限影响。

| 问题 | 命令 | 如何理解 |
| --- | --- | --- |
| 包属性/安装原因 | `pacman -Qi 包名` | 当前包信息，不代表启动或功能通过 |
| 程序属于哪个包 | `pacman -Qo /usr/bin/程序` | 包外程序可能没有归属 |
| 孤立依赖候选 | `pacman -Qdt` | 候选不等于应删除；无结果可能非零退出 |
| 缓存清理预览 | `paccache -d -k 3` | 需安装该工具，只列保留三版后的候选 |
| Rust 实际工具链 | `rustup show` | 在目标项目目录查覆盖规则 |
| 提交署名 | `git var GIT_AUTHOR_IDENT` | 在目标仓库查有效身份 |
| 远程地址 | `git remote -v` | 不证明 SSH 认证账户或仓库权限 |
| 客体 NAT 网络 | `virsh -c qemu:///system net-list --all` | 需连接授权；未启动与不存在分开处理 |
| 系统暗色偏好 | `gsettings get org.gnome.desktop.interface color-scheme` | 在桌面用户会话中读取；不证明所有应用外观一致 |
| 停止代理后仍无法解析 | `cat /etc/resolv.conf` | 先核对有无基础 nameserver；与 NetworkManager 活动连接配置一起判断 |
| 代理目标 DNS | `getent ahostsv4 codex-cloud-backend.chatgpt.com` | 发起解析；成功不等于 HTTPS/代理已通 |
| 代理日志 | `journalctl -u v2raya -b --no-pager -n 80` | 可能需日志权限；分享前脱敏 |
| Portal 日志 | `journalctl --user -b -u xdg-desktop-portal --no-pager -n 80` | 服务 active 不等于弹窗成功 |

对应依据：[包与缓存](Nautilus%20书签与文件缓存维护.md)、[Rust](Arch%20Linux%20使用官网%20rustup%20配置与维护%20Rust.md)、[Git](GitHub%20账户对应与%20SSH%20私有仓库使用.md)、[虚拟机](Arch%20Linux%20KVM%20虚拟机与%20Fedora%20文件传输.md)、[主题](Niri%20桌面的暗色外观与%20GTK%20Qt%20配置.md)、[代理](v2rayA%20主代理与%20v2rayN%20备用配置.md)、[Portal](Niri%20文件选择器与桌面应用入口排错.md)。

## 有副作用的日常操作

每项独立选择执行，不把整段当作部署脚本。目标进程、客体、项目或用户需先确认。

| 目的 | 命令 | 影响与前提 |
| --- | --- | --- |
| 重载 Waybar | `pkill -USR2 -u "$(id -u)" -x waybar` | 影响当前用户全部匹配实例；信号动作可被配置更改 |
| 宿主机发文件到客体 | `scp 文件 用户@客体IP:~/` | 写入客体目录；先确认 SSH 主机指纹与地址，可能覆盖同名文件 |
| 更新 Rust 工具链 | `rustup update` | 更新已安装发布通道；不是升级 Cargo.lock 的命令 |
| 更新项目依赖锁文件 | `cargo update` | 在项目目录执行，审阅 Cargo.lock 差异并测试 |

操作与恢复：[Waybar](Niri%20个性化%20Waybar%20搭建与亮度调节.md)、[SFTP/scp](Arch%20Linux%20KVM%20虚拟机与%20Fedora%20文件传输.md)、[Rust 维护](Arch%20Linux%20使用官网%20rustup%20配置与维护%20Rust.md)。安装、卸载、清理、网络重启及配置覆盖命令回相应指南确认条件后再用。

## Bash 语法与失败处理入口

查引号、参数边界、数组、重定向、进程、锁及复制模板：[[wiki/guides/Bash 脚本语法速通与 shorinniri 阅读练习]]（[速查指南](Bash%20脚本语法速通与%20shorinniri%20阅读练习.md)）。仅检查练习语法用 `bash -n /实际路径/练习.sh`；source会执行整份文件，不能当作只读语法检查。基础课程已结束，自测卡片仅供按需复习。

## 配置与脚本复用入口

所有仓库脚本从仓库根目录执行；预览不等于安装。先选一个目标模块，再生成、比较、合并和验收。

| 复用目标 | 预览命令 | 应用边界 |
| --- | --- | --- |
| 安装选定软件 | `bash scripts/archlinux/install-desktop-apps.sh papers apostrophe` | --apply 才执行安装/升级；包清单不是配置备份 |
| 官网 Rust | `bash scripts/archlinux/setup-rust-official.sh` | --apply 会安装/更新用户工具链；Shell 入口另配置 |
| 终端模板 | `python3 scripts/archlinux/stage-session-config.py terminal --output /tmp/terminal-review` | --apply 只生成新目录，不部署 HOME |
| 主题/代理/Portal/虚拟机/文件脚本 | 将上一行 terminal 替换为 `theme`、`proxy`、`portal`、`vm`、`nautilus`，同时更换 output | 仅生成待审阅资料；部分生成脚本执行时还有独立 --apply |
| Waybar 基础配置 | `python3 scripts/archlinux/deploy-waybar.py --target /tmp/waybar-review` | --apply 写目标；真实替换另需 --replace 和备份审阅 |

Fcitx5 个人主题复制入口见 [主题维护](Fcitx5%20浅色主题定制与更新维护.md)，Git 身份脚本参数见 [Git 配置](GitHub%20账户对应与%20SSH%20私有仓库使用.md)。输出目录已存在时先检查已有内容，不为了重跑命令直接删除。复用前记录目标机依赖、配置路径、主机参数、期望结果和回退文件；总体计划见 [[wiki/questions/Arch Linux 个性化配置复用计划]]。

## 核对范围

2026-10-24：从已有指南摘取并交叉核对命令及作用边界，未重新执行安装、网络操作或 GUI 验收。原指南的 needs-verification 状态和历史来源范围继续适用。本页只集中短命令，不复制整套配置，后续优先修订原指南，再同步此表。

相关：[[wiki/index]] · [[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/guides/LLM Wiki 收录与维护流程]]

## 找到实际生效配置

| 目的 | 只读或交互查询 | 详细知识落点 |
| --- | --- | --- |
| 窗口标识/匹配不生效 | `niri msg pick-window` | [[wiki/guides/Niri 中 Kitty 常驻与浮动终端配置]] |
| Niri配置是否可加载 | `niri validate` | 校验当前入口，不等于窗口视觉验收 |
| GTK明暗与主题名 | `gsettings get org.gnome.desktop.interface gtk-theme`；color-scheme同查 | [[wiki/guides/Niri 桌面的暗色外观与 GTK Qt 配置]] |
| Qt为何不跟随GTK | 分别核对平台主题与应用自己的样式 | GTK主题名不能代表Qt实际调色板 |

透明不明显先查规则顺序，主题不统一先查工具包层次，窗口启动慢区分Kitty与Zsh初始化。先确定生效入口，再修改配置，不把目录里存在的文件都当作当前使用。

普通浮动与跨工作区固定不是同一功能；panel试验及其回退范围见 [[wiki/guides/Niri 中 Kitty 常驻与浮动终端配置#普通浮动、跟随与屏幕图层]]，不将已撤销脚本当作快捷命令。
