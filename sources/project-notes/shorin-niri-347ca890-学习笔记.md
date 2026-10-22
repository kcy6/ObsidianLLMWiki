# shorin-niri 源码学习指南

分析日期：2026-10-22。仓库：`https://github.com/SHORiN-KiWATA/shorin-niri`。
本地目录：`<来源工作区>/shorin-niri`。
分析基线：`347ca890cacf818989984171792fbe5602f1ca69`，提交日期 2026-10-21。

本文中的相对源码路径均以该仓库为根。此次只克隆、阅读与测试，没有执行 init/update/remove，没有部署配置或安装软件。笔记放在仓库外，便于保持上游工作树干净。

## 1. 先建立项目地图

这是一个以 Niri 和 Waybar 为核心的桌面预设与部署工具仓库。Niri 合成器本身的实现代码不在这里；这里描述如何配置它，以及如何把外部程序组合成完整桌面。当前 Git 跟踪 250 个文件，包含图片、主题素材和脚本，不能把文件数量直接当作业务代码量。

| 路径 | 职责 | 阅读优先级 |
|---|---|---|
| `README.md` | 安装入口和预览 | 首先看 |
| `README-Niri.md` | 用户功能说明，涉及其他仓库提供的命令 | 对照源码看 |
| `shorinniri` | 软件依赖、配置部署、保护规则、系统设置、清理 | 高 |
| `tests/test-protection.sh` | 临时 HOME 下验证保护与更新逻辑 | 高 |
| `dotfiles/.config/niri/` | 合成器、输入、布局、窗口规则、快捷键 | 高 |
| `dotfiles/.config/waybar/` | 状态栏结构、行为、样式、辅助脚本 | 高 |
| `dotfiles/.config/scripts/` | 配色、壁纸处理等跨组件工具 | 高 |
| `dotfiles/.config/matugen/` | 配色模板、输出位置与刷新钩子 | 高 |
| `dotfiles/.config/waypaper/` | 壁纸目录、后端与换图后命令 | 高 |
| `dotfiles/.local/bin/` | 安装到用户 PATH 的工具 | 中 |
| `dotfiles/.config/kitty/`、`fish/` | 终端、交互 Shell 与命令便利功能 | 中 |
| GTK、fcitx5、fuzzel、mako 等配置 | 视觉风格、输入法、启动器、通知 | 按需 |
| `Wallpapers/`、`pics/`、主题 assets | 默认资源和演示素材 | 最后 |

配置流可以这样读：

```text
软件包安装阶段（本仓库没有 PKGBUILD，具体打包映射需另查）
  → /usr/share/shorin-niri 中的模板
  → shorinniri init/update
  → HOME 下的 .config 与 .local 文件

Niri 会话启动
  → config.kdl → include 分散配置
  → 启动 Waybar / mako / awww / 剪贴板等进程
  → 快捷键和状态栏事件调用外部命令、脚本

waypaper 换壁纸
  → awww 显示壁纸
  → post_command 调用 matugen-update.sh
  → Matugen 渲染模板 → 多应用颜色文件 → post_hook 刷新
  → 概览背景脚本生成模糊、暗化的背景
```

## 2. 第一课：读懂配置入口

从 `dotfiles/.config/niri/config.kdl:8` 开始。KDL 使用节点、属性与花括号子节点描述配置；不要按 Bash 解释它。

```kdl
include "binds.kdl"
include optional=true "rule.kdl"
include optional=true "output.kdl"
```

`include` 引入同目录文件；这里给 binds 使用必需加载，给后两者使用可选加载。阅读时先把分散文件拼成逻辑整体：

- `binds.kdl`：按键触发什么动作。
- `layout.kdl`：窗口间距、默认列宽、边框与阴影。
- `rule.kdl`：按 app-id、标题、窗口状态匹配行为；例如全局透明度 0.97。
- `output.kdl`：当前仓库中为空；显示器设置示例另在 `output-example.kdl`。
- `animations.kdl`：动画；`blur.kdl`：模糊与相应规则；`debug.kdl`：当前主要是被注释的示例。
- `colors.kdl`：在入口末尾 include，承担生成颜色的接入点。

入口还有环境变量、输入设备、光标、启动程序和 `agent` 相关节点。`agent.kdl` 虽然存在，但本版本入口没有 include 它；agent 配置直接写在 config.kdl 末尾。**文件存在和配置生效是两件事，要追踪实际入口。**

本配置使用一些与 Shorin fork 有关的扩展。源码中也明确提到 fork；不要仅凭上游 Niri 的版本号推断兼容性，具体语法需由实际安装的二进制验证。本文没有启动 Niri 或完成 KDL 运行验证。

第一条调用链读 `binds.kdl:57`：

```kdl
Mod+T hotkey-overlay-title="共享终端 Terminal" {
    spawn "kitty" "--single-instance";
}
```

1. 按键匹配后，Niri 执行 spawn。
2. `kitty` 与 `--single-instance` 是程序及独立参数，不是一整串 Shell 代码。
3. Kitty 的 `kitty.conf` 指定 `shell fish`。
4. Fish 配置加入 `~/.local/bin`，初始化 Starship 与 zoxide。
5. Kitty 又 include Matugen 颜色文件，因此终端外观接到统一主题链。

遇到 `spawn-sh "命令1 | 命令2"` 时，才需要考虑 Shell 管道、重定向和条件执行。例如 `thunar || ... nautilus` 表示前一个命令失败时使用后者。

练习：只在源码中定位 `Mod+Z` 和 `Mod+R`。前者启动 fuzzel，后者执行合成器内部的列宽切换；在 layout.kdl 找到三种比例 0.33333、0.5、0.66667。目标是区分“启动外部进程”和“改变合成器状态”。

## 3. 第二课：部署脚本的控制流

先看 `shorinniri:820` 的 case 入口，再倒着追函数，比从颜色变量开始逐行读更容易理解。

```text
init
  ask_for_sudo
  manage_software
  sync_dotfiles init
  setup_system_environment
  apply_user_configs

update
  ask_for_sudo
  manage_software
  sync_dotfiles update
```

`TEMPLATE_DIR` 写死为 `/usr/share/shorin-niri`。因此仅克隆仓库后直接运行 init，并不会自动把当前仓库的 dotfiles 当作模板。

`manage_software` 使用数组列出目标软件，逐项调用 pacman 检测，选择 yay 或 paru 补齐缺失项。安装后再次检查，失败则退出；成功的软件会标记为显式安装并写入缓存。历史缓存中已不在目标列表的软件只给出移除建议。这个缓存记录的是当时存在的目标软件，不能当作“全由本脚本首次安装”的清单。

`sync_dotfiles` 用 `find . -type f -print0` 枚举普通文件，用 `read -r -d ''` 接收，避免空格和换行拆坏文件名。它按模板相对路径映射到 HOME：

```text
/usr/share/shorin-niri/.config/niri/binds.kdl
→ ~/.config/niri/binds.kdl
```

`backup_and_copy` 为已有目标做 `cp -a` 备份，删除原目标后再复制模板。这里是逐文件复制，不是创建指向仓库的配置符号链接，也不是按内容做合并。模板中的符号链接不会被 `find -type f` 当作普通文件枚举。

`init` 是全量路径；`update` 先加载保护列表，只覆盖未保护路径。`update` 也会同步软件依赖，所以它有超出“更新文本配置”的效果。

练习：在纸上写出从 `case update` 到 `cp -a` 的函数链，再回答：为什么编辑源码仓库的 binds.kdl 不会立即改变当前桌面？答案：运行中的桌面通常读 HOME 配置，仓库与部署后的文件是两套文件。

## 4. 第三课：配置保护与测试

保护机制主要在 `shorinniri:219–564`。分成三步理解：

1. `normalize_protected_path` 把相对路径、`~/...` 和 HOME 内绝对路径统一成 HOME 相对路径；拒绝 HOME 本身、越界路径、其他用户的波浪线路径等。这里 realpath 使用 `-m -s`，是词法规范化，不解析符号链接目标。
2. `build_ignore_list` 合并内置和用户规则，去重，记录无效项。用户列表不是可读普通文件或保护目录不可访问时，更新中止；单条无效规则则被报告并跳过。这两种失败行为不同。
3. `is_ignored` 匹配完全相同的路径，或以“规则加斜杠”开头的子路径，避免把 `.config/niri-other` 当作 `.config/niri` 的孩子。

关键行为：内置列表已经保护整个 `.config/niri`，不只是 output.kdl。`unprotect` 仅移除用户列表中的条目，不能取消这条内置规则。`init` 不使用这套更新保护。

规则维护用目录文件描述符加 `flock -x` 锁，防止多个 protect 同时写丢；先写临时文件，再 `mv -fT` 替换列表，避免写到一半留下半个文件。读规则使用 mapfile，支持最后一行没有换行符。

`tests/test-protection.sh` 是很好的学习材料：它创建临时 HOME，调用真实命令，再检查结果。覆盖路径规范化、重复条目、越界、并发添加 20 项、旧锁路径符号链接、只读列表、更新跳过受保护文件、无法读取规则时阻止复制等场景。临时目录由 trap 清理。

本次验证：`bash -n shorinniri` 通过；`bash tests/test-protection.sh` 输出 `Protection tests passed.`。这只支持保护功能测试和主脚本语法层面的结论，不代表安装、录屏、显示器或桌面会话均已测试。

练习：读测试中 `.config/unprotected/config.ini` 的断言，说明它为什么既要检查“保护的没改”，又要检查“未保护的确实改了”。这可以发现把所有文件都跳过而导致的假通过。

## 5. 第四课：Waybar 的结构、行为、样式

按三层阅读：`config.jsonc` 决定模块摆放；`modules.jsonc` 定义模块行为；`style.css` 定义视觉样式并 import `colors.css`。分隔图案另在 `modules-dividers.jsonc`。JSONC 带注释，不能直接假定 Python 标准 json 解析器能读取。

以截图按钮为例：

```text
config.jsonc 的 modules-center 放入 custom/screenshot
→ modules.jsonc 定义 on-click
→ scripts/screenshot.sh
→ slurp 选择区域
→ grim -g 区域 - 输出图像
→ wl-copy 接收标准输入
```

脚本没有选择区域时直接退出；相机音效在后台播放。截图快捷键则有另一条 Niri 内置截图路径，因此按钮和快捷键不一定共用实现。

录屏是稍复杂的例子：`custom/wfrec` 的 `exec` 调本仓库 `screenrec status-json` 获取 JSON；`signal: 9` 表示信号刷新。脚本中的 `signal_waybar` 发实时信号，让 Waybar 重新查询，ticker 在录制期间每秒触发。状态文件保存在 XDG_RUNTIME_DIR 下，偏好在缓存目录下。

注意：按钮点击调用外部 `shorin-screenrec-menu`，状态读取却调用本仓库脚本。是否完全兼容，要结合该外部程序实现验证，不能仅靠这里证明。录屏脚本包含 wl-screenrec/wf-recorder 两种引擎、声音选择和 GIF 转换，是后期练习状态管理的合适材料。

练习：追踪 network 模块的 on-click → select-network-tui.sh → 后端选择，理解菜单显示、终端容器和实际网络工具是不同层次。

## 6. 第五课：壁纸到全桌面主题

从 `binds.kdl:23` 的 `Mod+F10` 追踪：

```text
waypaper --random
→ waypaper/config.ini 的 backend=awww
→ post_command:
  ~/.config/scripts/matugen-update.sh
  && sleep 0.8
  && ~/.config/scripts/niri_set_overview_blur_dark_bg.sh
```

实际脚本首先尝试按 Niri 聚焦显示器查询 awww 壁纸，失败再读 Waypaper 配置；验证路径后更新当前壁纸链接。它读取策略、深浅模式与颜色索引模式，并根据缓存决定是否跳过重复任务；支持 `-f` 强制生成和 `-n` 交互选择。

WebP 图片可转换成缩小 PNG 后交给 Matugen；缓存名按壁纸路径哈希。颜色索引随机模式会探测有效索引并缓存，后续可轮换。路径哈希没有包含文件内容，因此同路径图片被替换时需注意缓存失效策略。

Matugen 的核心是 `config.toml` 中的三项：

```toml
[templates.niri]
input_path = '~/.config/matugen/templates/niri-colors.kdl'
output_path = '~/.config/niri/colors.kdl'
```

模板里放颜色占位符，渲染后才是应用实际配置。需要主动刷新时配置 post_hook：例如 makoctl reload、Kitty 重载主题、通过 D-Bus 重载输入法 classicui。Waybar 启用了样式变更重载。不是所有应用都使用同一种刷新机制。

另一个脚本给概览背景做图片模糊、暗化和缓存，再交给背景后端。这与 `blur.kdl` 指定的窗口背景效果是两套机制：一个生成背景图片，一个控制合成器如何显示窗口背景。

特别留意 `.local/bin/matugen-update`：它与实际 post_command 调用的 `.config/scripts/matugen-update.sh` 内容不同。排查颜色问题时，应从调用位置找实现，不能只按同名关键词选第一个文件。

练习：追踪一次 Waybar 颜色更新，依次找到 Matugen 模板 → output_path → style.css 的 import → config.jsonc 的 reload_style_on_change。

## 7. 第六课：其他组件怎样连接

| 功能 | 入口与代码 | 需要理解的接口 |
|---|---|---|
| 应用菜单 | binds 的 Mod+Z → fuzzel.ini | 外部程序配置 |
| 窗口选择 | Alt+Tab → niri-quick-switch-fuzzel.py | niri msg JSON → 过滤排序 → fuzzel → Niri 动作 |
| 剪贴板历史 | config.kdl 的 wl-paste --watch cliphist store；快捷键打开 cliphist-tui | 监视进程、历史存储与交互前端 |
| 通知 | 启动 mako，其他脚本使用 notify-send | 通知服务与发送客户端 |
| 音量 | 快捷键/Waybar → swayosd-client 或 wpctl | OSD 与音频控制 |
| 输入法 | environment、XDG 自启动、fcitx5/rime 配置 | 环境、协议与单实例启动 |
| 文件选择对话框 | xdg-desktop-portal/niri-portals.conf | 按接口选择 portal 后端 |
| 维护菜单 | custom/actions → command-center.sh | 探测当前环境，再展示适用功能 |

Python 窗口选择器适合练习过程式代码：`get_active_output_workspace_ids` 找当前显示器的工作区；`get_window_sort_key` 排序；main 循环重新查询窗口列表，再处理菜单动作。`run_cmd` 使用 shell=True 并吞掉异常，读代码时要区分“没有窗口”和“查询出错”都可能表现为空结果。

文档出现的 Miyu、rime-llm-translator、linuxqq-wayland-fix、shorin、快照工具等依赖外部工程；当前仓库可以解释集成入口，不能解释其全部内部实现。

## 8. 第七课：带着审查意识读源码

下面是源码可见的行为或待验证风险，不是已在真实桌面复现的故障：

- 主脚本没有全局严格错误处理，backup_and_copy 的 mkdir/cp/rm 多处没有显式检查；复制失败后同步计数仍可能增加。备份成功前应不应该删除原文件，是一个值得练习的改进点。
- 同步按文件逐个完成，没有事务式回滚；中途失败可能留下部分新配置和部分旧配置。
- cleanup_old_backups 只保留最近两组备份；使用 ls 输出再做 Shell 分词，对带空白的路径不够稳健。备份目录时间精度为秒，也需考虑同时运行。
- remove 按模板路径删除 HOME 文件，不比较内容，也不使用更新保护列表；没有在这个函数中创建卸载前备份。README 的概括性备份说明不能替代对具体分支的检查。
- init 写入系统 Firefox policies.json，remove 删除该文件；已有独立策略可能受影响。系统服务、用户组、Flatpak 权限等初始化效果也不是 remove 的完整逆操作。
- 配色脚本存在“同壁纸跳过”逻辑，策略或模式变化时是否传入 -f，需要追踪调用者；不要只看函数注释推断缓存总能正确失效。
- Fish 配置残留 `/home/shorin/.lmstudio/bin`，属于作者机器的绝对路径；移植时应核实。
- blur.kdl 注释声称某种模式“完全没有性能消耗”，这不是本次验证过的性能结论。
- 不能因 Bash 语法通过就认定外部命令版本、KDL 扩展、字体、显示器和显卡均兼容。

## 9. 建议的学习节奏与验收

每次学习只闭合一条调用链，不要一口气修改整个桌面：

1. 配置入口与 Mod+T：能解释 Niri、Kitty、Fish 各做什么。
2. 部署脚本：能解释 init/update 差异，以及源码与 HOME 的路径映射。
3. 保护机制：能用一个测试说明规范化、目录匹配和失败时停止更新。
4. Waybar：能独立追踪一个模块的布局、行为、样式。
5. 配色：能指出哪个文件是模板，哪个是生成产物，以及如何刷新。
6. IPC 与状态：能解释窗口查询 JSON、录屏 PID/开始时间和信号刷新。
7. 小改进练习：在单独副本实现“复制失败不删除旧文件”，为它添加失败场景测试。

第一轮以阅读和临时目录测试为主。后续要实际应用配置时，再结合你现有的 niri-patched、Waybar 配置做差异分析，逐项迁移；本笔记没有把旁边的 niri-patched 自动认定为这个预设所需的同一 fork。

当前完成：克隆、核心路径分析、源码学习路线、第一课及各课练习、主脚本语法检查、现有保护测试。后续互动可从第一课练习答案继续，按理解程度逐节展开。

发布说明（2026-10-22）：来源工作区路径以占位符代替。此为来源笔记，不表示收录时重跑安装或逐文件审计。
