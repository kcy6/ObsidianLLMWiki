---
type: question
status: needs-verification
updated: 2026-10-04
sources:
  - notes/ArchLinux.md
  - notes/niri配置文件config.kdl.md
  - notes/Linux中文环境及中文输入法.md
  - Fedora桌面配置相关/Fedora Minimal+Niri+DMS.md
---

# Arch 与 Fedora 的 Niri 配置如何复用

## 结论与范围

可以优先迁移 Niri 的布局、外观和原生操作快捷键；包安装、桌面组件、自启动、输入法环境及显示器参数须单独核对。本库目前比较的是“Arch 自行搭配组件”和“Fedora 使用 DMS”的笔记，不能把组件选择误认为发行版限制。Arch 笔记的 DMS 安装章节只有外部入口，Fedora 笔记也不是完整的基础安装记录。依据：[[notes/ArchLinux#niri+自行搭建其他组件]]、[[notes/ArchLinux#niri+dms桌面安装]]、[[Fedora桌面配置相关/Fedora Minimal+Niri+DMS#niri美化及部分效率配置]]。

本次为 2026-10-04 的文献对照，未取得目标机器的发行版、Niri、DMS、Qt 版本或实际配置，未运行桌面测试。Shorin 子模块仍未初始化，本次不将其正文作为新核验证据；旧引用的后续核对见 [[wiki/sources]]。

## 按配置层对照

| 配置层 | Arch 笔记 | Fedora 笔记 | 综合判断与迁移条件 |
| --- | --- | --- | --- |
| 包和软件源 | pacman；另涉及 AUR/archlinuxcn | dnf；雾凇通过 Plum 安装 | 保留软件功能清单，分别核对包来源；不直接替换命令中的包管理器名字 |
| 原生 Niri 配置 | 终端、鼠标、output 示例 | 圆角、焦点环、鼠标聚焦、截图动作 | 目标版本支持对应语法时可复用；块必须合并到正确层级 |
| 外部程序快捷键 | alacritty 或 kitty + fish | DMS 剪贴板、锁屏；wl-paste + Swappy | 依赖可执行程序、运行中的服务及 IPC 接口；不是 Niri 原生功能 |
| 自启动与通知 | mako、polkit-gnome 的绝对路径 | 已有 DMS 使用记录，未给出完整启动配置 | 先确认由哪个组件提供功能；服务与 spawn-at-startup 不重复启动同一进程 |
| 输入法 | fcitx5-im、Rime；Niri environment 中的 XMODIFIERS | fcitx5、Rime；environment.d 中的 XMODIFIERS、Qt/SDL 变量 | 用户词典与补丁是迁移候选，框架模块、环境变量和启动入口分别验证 |
| 屏幕与硬件 | eDP-1、DP-2、指定模式和缩放 | 本次范围未提供相同硬件参数 | 按目标机 outputs 重建，不把笔记里的接口和坐标当默认值 |
| 用户路径 | 多用用户目录简写 | 多处含 /home/y | 替换为目标用户路径；KDL spawn 参数不要假定按 shell 方式展开 |

来源：[[notes/niri配置文件config.kdl]]（全文）、[[notes/Linux中文环境及中文输入法]]（全文）、[[notes/ArchLinux#安装niri及部分工具]]、[[Fedora桌面配置相关/Fedora Minimal+Niri+DMS#中文输入法]]、[[Fedora桌面配置相关/Fedora Minimal+Niri+DMS#基础截图]]。

## 配置片段的正确放置

Fedora 笔记中的普通 `focus-ring` 设置应放在 `layout` 下；窗口圆角写为顶层 `window-rule`。原笔记片段缺少上下文，迁移时补全层级。`prefer-no-csd` 是向应用请求省略客户端装饰，不保证所有应用隐藏标题栏，部分效果需重启应用。依据：[Layout](https://niri-wm.github.io/niri/Configuration%3A-Layout.html)、[Window Rules](https://niri-wm.github.io/niri/Configuration%3A-Window-Rules.html)、[Miscellaneous](https://niri-wm.github.io/niri/Configuration%3A-Miscellaneous.html)。

以下只展示合并位置，不是完整 config.kdl，也未在目标机器测试；已有同名块时合并内容，不重复粘贴整个块。

```kdl
layout {
    focus-ring {
        width 2
        active-color "#b4befe"
        inactive-color "#3b4261"
    }
}
window-rule {
    geometry-corner-radius 12
    clip-to-geometry true
}
input {
    focus-follows-mouse max-scroll-amount="0%"
}
binds {
    Mod+Shift+S { screenshot; }
}
```

配置可能热重载；在独立候选文件完成合并并验证后再应用，避免直接覆盖正在使用的配置。[配置加载与语法说明](https://niri-wm.github.io/niri/Configuration%3A-Introduction.html)

## DMS 与独立组件的分界

- Fedora 笔记把 `dms ipc call lock lock` 描述为使用 DMS greeter 的锁屏。官方将它列为 DMS 的会话内锁屏 IPC，不能据此推导必须更换登录管理器。需要确认 DMS 正在运行，并实测锁定与解锁。[DMS IPC](https://danklinux.com/docs/dankmaterialshell/keybinds-ipc)
- DMS 的 systemd 启动与配置中的 `dms run` 是替代方案，不应同时启用。多桌面共存时还要区分全局用户自启动与绑定到 Niri 会话；官方提供绑定 `niri.service` 的方法。先查现状再更改，不重复执行安装器或覆盖配置。[DMS 安装与会话集成](https://danklinux.com/docs/dankmaterialshell/installation)
- 原 Arch 笔记的 mako 和 polkit 路径属于选定组件的配置。迁移后需核对实际通知服务和认证代理；不能因 DMS 可锁屏，就认定权限弹窗、门户和输入法也已配置。
- Niri 门户依赖正确会话启动；官方区分 GTK 回退门户与 GNOME 屏幕分享门户。原 Arch 笔记仅列 GNOME 门户的安装行，不足以证明目标机门户完整可用。[Niri 配套软件](https://niri-wm.github.io/niri/Important-Software.html)
- 对 Niri >= 25.08 且 xwayland-satellite >= 0.7、程序可在 PATH 找到的组合，官方支持自动集成；从旧配置迁移时应核对是否残留手动启动 satellite 和设置 DISPLAY 的配置。[Xwayland](https://niri-wm.github.io/niri/Xwayland.html)

## 输入法与截图的条件

两份输入法笔记中的 `XMODIFIERS`、`QT_IM_MODULE` 和 `QT_IM_MODULES` 不能作为两套发行版的固定差异。Fcitx 文档将它们与应用工具包及运行后端关联：XWayland 应用需要关注 XMODIFIERS；QT_IM_MODULES 是 Qt 6.7 起的回退机制，老 Qt 仍须单独处理。不要因为 Fedora 笔记同时写了两种 Qt 变量，就认定所有应用都按同一种回退顺序工作；逐个检查 Qt、GTK、Electron 应用的实际输入表现。[Fcitx Wayland 文档](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland/en)

同一 Fcitx5/Rime 前端下，两份笔记都使用 `~/.local/share/fcitx5/rime/`。迁移 `.custom.yaml` 与个人词典前核对引用的方案、词库和模型是否存在，并合并已有 `patch:`；本次未逐项核验第三方词库或模型。依据：[[notes/Linux中文环境及中文输入法#Fcitx5相关配置总结]]、[[Fedora桌面配置相关/Fedora Minimal+Niri+DMS#配置]]。

Fedora 的 `screenshot` 等是 Niri 原生动作，而 DMS 剪贴板与截图编辑链依赖额外程序。`screenshot-path null` 仅取消 Niri 的默认文件保存路径，不应扩大为任何截图工具都不落盘的保证。依据：[[Fedora桌面配置相关/Fedora Minimal+Niri+DMS#基础截图]]与 [Niri screenshot-path](https://niri-wm.github.io/niri/Configuration%3A-Miscellaneous.html#screenshot-path)。

## 目标机验证顺序

以下为在目标 Linux 主机上运行的只读诊断示例；当前 Windows 工作区未执行。配置路径使用默认 XDG 位置；若会话设置了 NIRI_CONFIG 或使用 --config，则改为实际路径。

```sh
cat /etc/os-release
niri --version
command -v dms fcitx5 xwayland-satellite wl-paste swappy
niri --config "${XDG_CONFIG_HOME:-$HOME/.config}/niri/config.kdl" validate
# 以下 IPC 命令要求正在运行 Niri 会话
niri msg outputs
# 以下仅适用于以 systemd 用户服务运行的会话
systemctl --user status niri.service dms.service --no-pager
```

1. 记录上述结果及 DMS 的包版本、安装来源。另存当前配置备份和候选文件，不把教程片段当完整配置。
2. 在候选文件中先合并原生外观与快捷键，再按目标硬件补 output；用目标版本的 `niri --config 候选文件路径 validate` 检查。
3. 核对 DMS、Fcitx、通知和认证代理的启动入口，再试外部程序快捷键。配置语法通过不等于外部程序存在或服务可用。
4. 应用后分别测试显示器、中文输入、通知、权限弹窗、文件选择、屏幕分享、截图与锁屏解锁；记录失败应用、工具包版本和错误信息。

## 验证跟踪

| 问题 | 状态 | 证据缺口或结果 | 结论落点 |
| --- | --- | --- | --- |
| 发行版差异是否等同于 DMS 与独立组件差异？ | 已解决（文献范围） | 本库来源比较的是两种组件组合，不能推广成发行版限制 | 本页按配置层对照 |
| focus-ring 层级与 prefer-no-csd 含义 | 已解决（文献范围） | 已对照 Niri 官方文档；未测试具体应用表现 | 本页配置片段 |
| DMS 锁屏是否必须使用 DMS greeter？ | 已解决（接口含义） | 官方定义为会话锁屏 IPC；目标机认证行为待实测 | 本页 DMS 分界 |
| 两台机器的版本和配置能否直接兼容？ | 待验证 | 缺发行版、Niri、DMS、Qt 版本及完整 config.kdl | 目标机诊断后更新本页 |
| 输入、门户、通知和锁屏能否完整工作？ | 待实践 | 缺目标会话测试；子模块旧引用未重新核验 | 实测后记录环境、结果与下一步 |

核对方式：2026-10-04 阅读本地指定章节与上列官方网页相关段落。状态保持 needs-verification，原因是目标版本与运行验证仍缺失。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/sources]]
