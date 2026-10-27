---
type: guide
status: needs-verification
updated: 2026-10-27
sources:
  - sources/codex-sessions/Waybar 图标鼠标与上游合并-2026-10-27摘录.md
  - sources/codex-sessions/Waybar 时钟状态与 Mechabar 适配-2026-10-27摘录.md
  - sources/codex-sessions/Waybar 圆角选择器与模块阅读-2026-10-27摘录.md
  - sources/codex-sessions/搭建个性化 Waybar.md
  - sources/codex-sessions/推荐本机亮度调节组件.md
  - wiki/assets/waybar/config.jsonc
  - wiki/assets/waybar/style.css
  - scripts/archlinux/deploy-waybar.py
  - scripts/archlinux/brightness-step.sh
---

# Niri 个性化 Waybar 搭建与亮度调节

## 快速使用

修改模块看 JSONC，修改样式看 CSS，亮度先确认设备。

```bash
python3 scripts/archlinux/deploy-waybar.py --target /tmp/waybar-review
```

执行范围：仓库根目录；仅预览，无亮度设备参数。

复用要点：复用模块、样式与辅助脚本；背光设备和输出配置按新机器确认，不照抄历史设备名。

操作细节：[[wiki/guides/Niri 个性化 Waybar 搭建与亮度调节#文件职责与基础布局]]。

按需跳转：[范围与持续状态](#%E8%8C%83%E5%9B%B4%E4%B8%8E%E6%8C%81%E7%BB%AD%E7%8A%B6%E6%80%81) · [已有方案与证据边界](#%E5%B7%B2%E6%9C%89%E6%96%B9%E6%A1%88%E4%B8%8E%E8%AF%81%E6%8D%AE%E8%BE%B9%E7%95%8C) · [文件职责与基础布局](#%E6%96%87%E4%BB%B6%E8%81%8C%E8%B4%A3%E4%B8%8E%E5%9F%BA%E7%A1%80%E5%B8%83%E5%B1%80) · [手动搭建流程](#%E6%89%8B%E5%8A%A8%E6%90%AD%E5%BB%BA%E6%B5%81%E7%A8%8B) · [脚本生成与部署流程](#%E8%84%9A%E6%9C%AC%E7%94%9F%E6%88%90%E4%B8%8E%E9%83%A8%E7%BD%B2%E6%B5%81%E7%A8%8B) · [日后维护、恢复与继续搭建](#%E6%97%A5%E5%90%8E%E7%BB%B4%E6%8A%A4%E3%80%81%E6%81%A2%E5%A4%8D%E4%B8%8E%E7%BB%A7%E7%BB%AD%E6%90%AD%E5%BB%BA) · [验证与待办](#%E9%AA%8C%E8%AF%81%E4%B8%8E%E5%BE%85%E5%8A%9E)。

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

## CSS选择器与圆角不生效

先确认修改的是实际加载的style.css，而非源码初始副本。来源用户修改圆角无明显变化，助手判断更具体规则覆盖了全局值；这是对当时文件的分析，未取得修改后视觉验收。依据 [[sources/codex-sessions/Waybar 圆角选择器与模块阅读-2026-10-27摘录]]。

| 选择器/属性 | 查找对象或用途 |
| --- | --- |
| `*` | 全局基础样式，更具体的同名属性可能覆盖它 |
| `window#waybar` | 顶栏窗口背景/边框，不是单个按钮 |
| `#clock` | 时钟模块，文字、背景、内部留白 |
| `#workspaces button.focused` | 工作区内有focused类的按钮；不要与所有按钮规则混淆 |
| `button:hover` | 悬停伪类，区别于点号连接的状态类 |
| padding / margin | 内部留白 / 外部间距，不是圆角 |

排错顺序：确认生效文件 → 找目标节点 → 查更具体规则及后续覆盖 → 比较0px与16px等明显值 → 确认背景可见 → 按重载流程验证。透明背景上圆角可能看不见；接近胶囊形后增大数值变化也可能很小。圆角改变背景和边框轮廓，不改变文字字形。选择器与主题机制见 [Waybar样式说明](https://github.com/Alexays/Waybar/wiki/Styling)。

阅读按模块配对：JSONC的modules-left/center/right决定引用与顺序；模块定义决定format、tooltip和点击命令；CSS决定外观。定义存在但布局未引用，就不能据此推断模块显示。先改一个模块，记录前后差异与回退，再移植整套样式。


## 时钟内容、留白与弹窗

| 要改变什么 | 入口 | 判断效果 |
| --- | --- | --- |
| 栏上常态时间 | JSONC clock.format，例如 `{:%H:%M}` | 年月日/时分是占位格式，不是CSS |
| 点击后的另一种内容 | format-alt | 同一模块切换内容，不新建第二个时钟；按目标版本与点击配置确认 |
| 悬停提示 | tooltip-format，日历占位符calendar | 提示支持的Pango标记与CSS不同 |
| 时钟文字/背景/留白 | CSS #clock | 不控制tooltip或tooltip label |
| 左右/上下内部留白 | padding: 0 16px / 6px 16px | 内部背景变宽/高，不改变文字字号 |
| 模块外部间距 | margin: 4px 0 | 与自身背景内部留白分开 |

时钟背景透明时padding不易看出；先给背景对照，逐项比较，不重复添加多个#clock块。增大上下padding可能撑高整条栏。%Y/%m/%d为年/月/日，%H/%M/%S为时/分/秒，%A受区域设置影响。来源用户只确认顶栏0→16px圆角对照已完成；后续时钟、悬停和操作练习不能一并算验收。依据 [[sources/codex-sessions/Waybar 时钟状态与 Mechabar 适配-2026-10-27摘录]]。

## 状态样式与鼠标动作

状态→CSS类→外观，和点击→命令→实际状态，是两条链。focused与hover可以同时匹配，同优先级规则还要看顺序；需要保留聚焦按钮悬停色时，用更具体的 `#workspaces button.focused:hover`。

wireplumber的format-muted改变文字，`#wireplumber.muted`改变外观；on-click执行的wpctl才改变音频状态。`wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle`会真实切换静音，set-volume会改变音量，不当作只读诊断；设置音量不等于解除静音。来源scroll-step=2是模块滚轮步长示例，不是所有模块通用字段。复用前核对模块类型和目标设备，测试后恢复原状态。

## Mechabar适配Niri与悬浮圆角

来源用户报告已启用Mechabar，助手检查到配置仍用hyprland/workspaces、hyprland/window和hyprctl；安装依赖不会把它们自动变成Niri模块。最小移植是布局数组替换为niri/workspaces与niri/window，并按对应模块定义参数；保留所需装饰模块，审阅include与点击/滚轮外部命令。不要照搬persistent-workspaces或hyprctl命令。

工作区先用 `{index}` 检验实际动态工作区，再按目标模块支持的 `{icon}`、format-icons和字体配置图标。来源给出focused/active/default图标建议，后续答复已给出将format由index改为icon及状态图标映射的方案，仍无用户确认生效，**保留待验收**。模板字段不能仅靠预览截图推断已经生效；实际运行文件、后续覆盖和字体缺字都需检查。本轮在线Niri模块手册/预设核对未完成，不将来源示例升级为新版本保证。

来源预设的JSONC margin=0控制整条栏贴边；分项margin-top/left/right决定离屏边距离。CSS外层#waybar与内层#waybar > box可能各有背景，只给一层圆角仍可能露出另一层直角。可在副本采用外层透明、内层背景/边框/圆角的设计；角落子模块底色露出时再核对内部padding，不能假定父圆角自动裁切全部子元素。button、tooltip、menu的圆角不等于整条栏圆角。

| 状态 | 下一步 | 结论落点 |
| --- | --- | --- |
| 待实践 | 已有icon/format-icons方案，重载后核对实际模块、配置覆盖和字体，再记录图标验收 | 本节数字/图标问题 |
| 待实践 | 逐项验收时钟点击/悬停、静音反馈、Mechabar模块与背景圆角，并记录回退 | 本页模块与样式 |

本节为来源文本综合，未读取粘贴附件全文、未重新操作主机Waybar。预设改变不等于本库基础模板已同步为当前主机完整配置，避免把模板反向覆盖用户已启用的栏。

## 工作区图标与鼠标跳动

来源后续建议在已有niri/workspaces中将format改为icon，并以focused/active/default映射图标；普通●/○可先排除Nerd Font缺字，不直接把预览图字形当成已安装字体。修改后重载并切换工作区验收，当前无用户结果确认。

点击工作区后鼠标跳动，来源定位到Niri input中的warp-mouse-to-focus：焦点变化可移动指针；focus-follows-mouse则是移动指针触发焦点。要保持指针位置，可在副本中注释warp选项并校验后合并；同时影响键盘切换窗口的指针行为，不需靠重启Waybar修复。见 [Niri输入配置](https://niri-wm.github.io/niri/Configuration:-Input.html#warp-mouse-to-focus)。本轮未修改实际input设置或验证鼠标行为。

## 上游预设更新与个人配置保存

如果生效的Waybar目录本身是Git仓库，先查status、diff、remote和跟踪分支；如果只是复制目录，就不能直接把git命令套进去。来源报告config.jsonc/style.css未提交，并提出个人分支保存方案，尚无创建分支/提交验收。

| 操作 | 行为与限制 |
| --- | --- |
| git fetch origin | 更新远程引用，不直接替换工作树配置 |
| git merge origin/main | 当前分支合并上游；分支名按实际remote确认，可能冲突 |
| git pull | 按设置fetch后merge/rebase；未提交改动可能阻止整合，不是“任意本地改动永久安全”保证 |
| git merge --abort | 仅中止正在进行的merge；合并前仍需干净工作树和外部备份 |

手动步骤：仓库外备份当前可用配置→新建未存在的个人分支→仅暂存实际修改文件并commit→确认干净→fetch→审阅上游差异→merge→解决冲突→验收。commit只保存在本机，不等于远端备份；reset --hard会丢弃已跟踪本地修改，不能当作常规冲突处理。自动重载可能读到冲突标记，优先在副本审阅，不在合并中反复重载正在运行的栏。[Git合并文档](https://git-scm.com/docs/git-merge)

个人样式可集中在独立overrides.css并显式import，但具体度仍影响覆盖；Waybar JSONC include重复项按先定义者优先，不照搬CSS“后覆盖”直觉。模块数组、include顺序和外部脚本依赖须一起维护。[Waybar配置说明](https://github.com/Alexays/Waybar/wiki/Configuration)

这只是预设仓库的局部版本管理建议，不推翻既有模块化配置工程方案，也不重新创建曾被撤销的私人dotfiles仓库。依据 [[sources/codex-sessions/Waybar 图标鼠标与上游合并-2026-10-27摘录]]。

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
