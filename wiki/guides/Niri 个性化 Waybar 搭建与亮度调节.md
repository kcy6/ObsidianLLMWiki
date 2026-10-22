---
type: guide
status: needs-verification
updated: 2026-10-22
sources:
  - sources/codex-sessions/搭建个性化 Waybar.md
  - sources/codex-sessions/推荐本机亮度调节组件.md
  - wiki/assets/waybar/config.jsonc
  - wiki/assets/waybar/style.css
  - scripts/archlinux/deploy-waybar.py
  - scripts/archlinux/brightness-step.sh
---

# Niri 个性化 Waybar 搭建与亮度调节

适用于 Niri/Wayland 下的 Waybar 基础布局、美化与内置屏背光接入。`nvidia_0` 是来源设备的接口名，使用前须替换为实际验证可用的设备。基础模板与正在使用的个性化配置应分开维护。

本文使用 `$HOME` 或 `~` 表示执行者的主目录；设备名、项目名及占位符须按目标环境调整。脚本命令均从本仓库根目录执行。

来源与验证基线为 **2026-10-21**，本文于 **2026-10-22** 调整公开阅读表述，未重新验收软件、硬件或远端权限。[来源记录](../../sources/codex-sessions/%E6%90%AD%E5%BB%BA%E4%B8%AA%E6%80%A7%E5%8C%96%20Waybar.md) · [知识库导航](../index.md)

## 范围与持续状态

本页统一收录“搭建个性化 Waybar”和其子问题“推荐本机亮度调节组件”，亮度不再另立一份互不关联的搭建指南。来源分别保存为 [[sources/codex-sessions/搭建个性化 Waybar]]（截至 2026-10-21 的 1 轮）和 [[sources/codex-sessions/推荐本机亮度调节组件]]（截至 2026-10-21 的 3 轮）；均为接口返回的全部完成轮次，不包括 Side Chat。

截至 2026-10-22，Waybar 主会话仍在持续，按维护约定暂不归档。本页阶段性收录基础配置与亮度子问题；后续布局和组件更新继续合并到此页。页面保持 needs-verification，尤其还缺实际滚轮调光、可见亮度变化、重登录及恢复验收。

## 已有方案与证据边界

| 阶段 | 来源观察/实际操作 | 能得出的结论 |
| --- | --- | --- |
| 基础顶栏 | Niri/Wayland，Waybar 0.15.0-3，已有 Nerd Font 与中文字体；生成配置和 CSS，备份 Niri、去重重复的 Waybar 自启动行，部署并运行 `niri validate` | 存在实际配置修改和语法验证记录 |
| 启动排错 | 首次启动报 `Bar need to run under Wayland`；执行环境 `GDK_BACKEND=x11`，显式选择 Wayland 后日志显示配置/CSS 已加载、Niri IPC 启动及输出配置完成 | 短时启动成功，不等于所有交互验收 |
| 背光选型 | 内置屏 eDP-2，2560×1600、240Hz，缩放 1.5；混合 AMD/NVIDIA，暴露 `nvidia_0` 背光；最初未发现 brightnessctl | 设备名与显示接口须分别检查；存在接口不保证控制可见面板 |
| 后续亮度配置 | 查询已能找到 brightnessctl，读取亮度为 20/100；备份后写入 backlight 配置并发 SIGUSR2，配置 JSON 检查通过 | 配置已写入、重载信号发送成功；没有滚轮操作和实际变暗的验收记录 |

上述历史证据均见两份来源快照。最初“100%”与后来的“20%”是不同时间读数；无法据此确定亮度变化的原因。2026-10-21 的整理未调整亮度或重启 Waybar。

## 文件职责与基础布局

| 文件 | 用途 |
| --- | --- |
| `~/.config/waybar/config.jsonc` | 模块、显示格式、顺序及鼠标行为 |
| `~/.config/waybar/style.css` | GTK CSS：字体、颜色、圆角、内部留白 |
| `~/.config/niri/config.kdl` | 会话自启动及快捷键；避免重复启动 Waybar |
| [本库基础配置](../assets/waybar/config.jsonc) | 原工作区初始配置的严格 JSON 版本，仍以 jsonc 文件名供 Waybar 使用 |
| [本库基础样式](../assets/waybar/style.css) | 原工作区基础样式，整理阶段补 backlight 的留白及颜色 |

基础布局为 `工作区 · 窗口标题 | 日期时间 | CPU · RAM · 网络 · 音量 · 电池 · 托盘`；本页在网络和音量之间加入亮度。工作区与窗口使用 `niri/workspaces`、`niri/window`；Hyprland 主题移植时必须核对模块及参数，不能只换配色就假定完全兼容。依据：[[sources/codex-sessions/搭建个性化 Waybar]]；通用配置与样式核对 [Waybar 配置文档](https://github.com/Alexays/Waybar/wiki/Configuration) 和 [Styling](https://github.com/Alexays/Waybar/wiki/Styling)。

2026-10-21 额外只读观察：来源工作区 `waybar/` 副本尚未包含亮度模块；该日期读取的用户配置已包含 backlight，样式的 accent、字号和部分圆角也与初始副本不同。初始配置是重建起点，不能当成当前配置的完整备份。不要重新运行基础部署覆盖正在调整的栏。

## 手动搭建流程

### 1. 检查、依赖与备份

```bash
pacman -Q waybar brightnessctl
printenv XDG_CURRENT_DESKTOP XDG_SESSION_TYPE GDK_BACKEND
pgrep -a -x waybar
ls /sys/class/backlight
brightnessctl --list
```

缺包时按需使用 `sudo pacman -Syu --needed waybar brightnessctl`，查看完整升级事务。字体与音频模块还依赖实际选择的字体、WirePlumber/`wpctl` 等工具；基础模板保留这些模块，不代表新机器依赖齐全。

修改前备份实际配置，包括 Waybar 整个目录及 Niri 配置。以下在目标文件已存在时备份，不自动停止进程：

```bash
backup_dir=$(mktemp -d "$HOME/.config/waybar-backup-XXXXXXXX")
# 只执行适用于现有文件的命令；不存在时记录“原来没有”。
cp -a "$HOME/.config/waybar" "$backup_dir/waybar"
cp -a "$HOME/.config/niri/config.kdl" "$backup_dir/niri-config.kdl"
printf '%s\n' "$backup_dir"
```

来源会话曾使用 `~/.config/backups/waybar-20261020-211021` 及 `config.jsonc.bak-20261021-201925`，但截至 2026-10-21 尚无恢复验收记录；不要用历史路径代替新备份。

### 2. 从基础文件开始，或只合并需要的模块

已有个性化配置时保留它，在下一节手动补亮度即可。新配置可从本库基础文件开始：

```bash
# 当前目录为本库根目录，仅适用于新建配置或已明确备份的替换场景。
mkdir -p ~/.config/waybar
cp wiki/assets/waybar/config.jsonc ~/.config/waybar/config.jsonc
cp wiki/assets/waybar/style.css ~/.config/waybar/style.css
```

数组控制模块出现位置；CSS 的 `@define-color accent` 控制主题强调色，字号在通配规则中修改，`window#waybar` 控制整个栏，`#workspaces button.focused` 控制聚焦工作区。外边距/高度在配置中，模块内留白在 CSS 中。GTK CSS 不能直接照抄浏览器布局属性。学习步骤与自定义静态模块例子见 [[sources/codex-sessions/搭建个性化 Waybar]] 内生成指南的命令记录。

Niri 中检查所有启动入口，仅保留预期的常驻启动方式；若使用原生启动行，可为 `spawn-at-startup "waybar"`。不要与 systemd 用户服务等另一个启动机制叠加。修改后 `niri validate`，自启动效果还需重新登录验收；脚本部署不修改 Niri，需单独配置与验收。

### 3. 将亮度作为 Waybar 的模块

先读设备信息：

```bash
brightnessctl -d nvidia_0 info
brightnessctl -d nvidia_0 get
brightnessctl -d nvidia_0 max
```

这里 `nvidia_0` 只适用于来源设备，其他机器从 `/sys/class/backlight` 重新确定。需要验证实际面板时，先记录原始值，在可恢复的亮度范围内小幅调整，再恢复原值；该硬件测试尚未完成。权限失败先检查会话、logind 与软件包权限配置，不把 sudo 写进滚轮命令。上游说明可使用设备权限或 logind 等途径控制背光。[brightnessctl 项目说明](https://github.com/Hummer12007/brightnessctl)

在 `modules-right` 中加入 `"backlight"`。如果继续使用原会话写法，`brightnessctl -d nvidia_0 set +5%` 增加最大值的 5%，而 `--min-value=5 set 5%-` 的下限是原始值 5；来源设备 max=100 才恰好是 5%。**这个下限不能跨设备等同于 5%。** 语义核对 [brightnessctl 手册](https://man.archlinux.org/man/brightnessctl.1.en)。

本库补写 [步进脚本](../../scripts/archlinux/brightness-step.sh)，每次读取 get/max，以最大原始值计算约 5% 的步进和至少 5% 的下限（向上取整），并将上限限制在最大值。手动接入方式：

```bash
cp scripts/archlinux/brightness-step.sh ~/.config/waybar/brightness-step.sh
```

顶层增加下列模块块，注意与相邻字段之间的逗号：

```jsonc
"backlight": {
  "device": "nvidia_0",
  "format": "☀ {percent}%",
  "tooltip-format": "屏幕亮度：{percent}%",
  "on-scroll-up": "bash ~/.config/waybar/brightness-step.sh up nvidia_0",
  "on-scroll-down": "bash ~/.config/waybar/brightness-step.sh down nvidia_0"
}
```

显示设备与命令中的设备保持一致。自定义 on-scroll 命令会取代 Waybar 默认滚动控制行为，因此最小值由步进脚本处理。[Waybar backlight 手册](https://man.archlinux.org/man/waybar-backlight.5.en)

CSS 可添加：

```css
#backlight { color: @warning; padding: 0 8px; margin: 4px 0; border-radius: 9px; }
```

来源 Niri 快捷键曾用背光类别、每次 10% 的另一套命令；它们与此处 5% 滚轮不是同一控制入口，也没有统一下限保证。若要统一，可在核对后让快捷键调用同一脚本，再 `niri validate`；2026-10-21 收录时未修改快捷键。

### 4. 重载、前台排错与验收

配置检查后，对当前用户的常驻 Waybar 实例发送：

```bash
pkill -USR2 -u "$(id -u)" -x waybar
```

此命令会影响当前用户所有匹配实例，先核对进程；多显示器可能由一个进程产生多条栏，不能按栏数量判断重复进程。SIGUSR2 的默认动作是 reload，但可以通过配置更改。[Waybar 信号设置](https://github.com/Alexays/Waybar/wiki/Configuration)

需要前台排错时先明确停止哪个常驻实例，再使用：

```bash
GDK_BACKEND=wayland waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css -l debug
```

不停止原实例直接运行可能出现双栏；前台进程会随终端/Ctrl+C 结束。不要为解决来源中的 `GDK_BACKEND=x11` 就全局强制所有应用后端；只对 Waybar 排错命令选择 Wayland。

## 脚本生成与部署流程

[部署脚本](../../scripts/archlinux/deploy-waybar.py)为整理阶段新增，生成整套基础配置而不解析、合并任意现有 JSONC。先输出到临时预览目录：

```bash
# 以下在仓库根目录执行；第一条只打印计划，不创建目录。
python3 scripts/archlinux/deploy-waybar.py --target /tmp/waybar-preview --device nvidia_0
python3 scripts/archlinux/deploy-waybar.py --target /tmp/waybar-preview --device nvidia_0 --apply
```

不需要亮度时省略 `--device`。检查预览与现有配置差异后，若确实要整套替换：

```bash
python3 scripts/archlinux/deploy-waybar.py --target ~/.config/waybar --device nvidia_0 --apply --replace
```

已有目标文件默认拒绝覆盖；`--replace` 先在目标下建立独立私有备份目录，再替换本脚本负责的文件。它会覆盖原配置中的自定义内容，因此当前正在完善的栏优先采用手动合并。脚本不安装依赖、不改变亮度、不验证设备是否实际控制面板、不重载进程、不修改 Niri。重复生成内容相同，但替换仍会增加备份；失败时可能部分写入，需按备份检查恢复。

`brightness-step.sh` 是运行时动作，直接执行会修改指定设备亮度；生成部署时不会调用它。无亮度版本不会清理旧辅助脚本，避免误删用户文件；若不再需要可在核对引用后手动移除。

## 日后维护、恢复与继续搭建

- 主题参考保留 [Mechabar](https://github.com/sejjy/mechabar) 和 [HANCORE](https://github.com/HANCORE-linux/waybar-themes) 作为原会话提及的入口，截至 2026-10-21 未审查其安装脚本、依赖或适用性。先在参考目录看样式，逐模块移植；排查 include、exec、点击动作及 CSS import，避免运行不明脚本。
- 当前 `reload_style_on_change` 开启时可自动重载 CSS；配置模块改动按重载/重启流程检查，升级后核对模块参数与日志。内核、显卡模式或设备变化后重新核对背光接口；外接屏不自动沿用内置背光方案。
- 将实际使用配置与本库重建模板分开维护。更新指南时比较配置差异并记录收录版本，不把原工作区旧副本覆盖为“最新”。
- 恢复先比较备份与当前文件，按文件恢复所需修改。Niri 后续若有其他修改，不能直接恢复整份旧配置；仅恢复相关启动/快捷键段，再验证。
- 来源初次不存在用户 Waybar 配置，恢复该历史状态可先将新用户配置目录改名留存，再按系统默认查找规则重启测试；这不是所有机器的通用恢复步骤。已存在用户配置时按备份恢复。
- 尚待确定的扩展包括整条圆角栏、三块胶囊或极简细条，以及蓝牙、快捷键统一、音乐和通知。部署前逐项确认依赖、动作和验收标准。

## 验证与待办

| 项目 | 目前证据 | 下一步 |
| --- | --- | --- |
| 基础配置、CSS、Niri 校验 | 源会话实际启动与 validate 日志 | 更新后重新核对 |
| backlight 配置 | 源会话 JSON 校验与发信号成功 | 验证实际显示和滚轮动作 |
| 硬件可见亮度、权限和 5% 下限 | 尚无面板变化/滚轮验收证据 | 目标机记录原值后实测并恢复 |
| 配置部署、步进脚本 | 2026-10-21 的临时目录/模拟命令测试 | 真实配置合并与硬件测试另做 |
| 重登录、备份恢复 | 未实测 | 完成后更新本表 |
| 最终布局及其他组件 | 对话持续中 | 待确定布局与扩展需求后增量收录；主会话暂不归档 |

2026-10-21：已读两会话当前全部轮次与命令输出，并读取原工作区指南、基础 JSONC/CSS、当前用户 JSONC/CSS；保存会话快照，提取基础资产并补 backlight 样式，核对上述官方文档相关段落。未操作正在使用的桌面配置、重启进程或改变亮度。结构检查不能替代硬件/交互验收。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]] · [[wiki/sources]] · [[wiki/index]]

公开阅读入口：[仓库说明](../../README.md) · [Arch Linux 主题](../topics/Arch%20Linux%20与桌面环境.md) · [来源台账](../sources.md)
