---
type: guide
status: needs-verification
updated: 2026-10-26
sources:
  - sources/codex-sessions/Kitty panel 试验与回退-2026-10-26摘录.md
  - sources/codex-sessions/Kitty 浮动终端与窗口规则-2026-10-26摘录.md
---

# Niri 中 Kitty 常驻与浮动终端配置

## 快速使用

先按窗口用途指定app-id，再由Niri规则决定平铺、浮动、大小和位置。普通终端与浮动终端各有独立Shell；复用Kitty进程不会复用Zsh初始化状态。

```bash
niri msg pick-window
niri validate
```

第一条交互选窗口查看实际标识，第二条校验当前Niri配置；均不部署配置。快捷键示例会新开窗口，不实现同一窗口显示/隐藏切换。

按需跳转：[配置位置](#配置位置) · [快捷键与窗口规则](#快捷键与窗口规则) · [透明度排错](#透明度排错) · [尺寸与位置](#尺寸与位置) · [单实例与Shell继承](#单实例与shell继承) · [普通浮动、跟随与屏幕图层](#普通浮动跟随与屏幕图层) · [复用与回退](#复用与回退)。

## 配置位置

| 内容 | 位置与职责 |
| --- | --- |
| 启动快捷键 | 现有Niri的binds块，或入口实际include的按键文件 |
| 平铺/浮动、整窗透明、初始位置 | Niri的window-rule；检查展开include后的规则顺序 |
| 背景透明、字体与终端外观 | ~/.config/kitty/kitty.conf；单次启动可用-o覆盖 |
| Zsh插件与提示符 | ~/.zshrc及引用文件；不由Niri窗口规则控制 |

关联 [[wiki/guides/Kitty 与 Zsh 终端配置和复制操作]]；不要为了新增浮动终端覆盖原配置全文。

## 快捷键与窗口规则

先备份实际修改的文件，将键绑定合并到已有binds块；检查是否已占用Mod+T、Mod+Slash。

```kdl
// 合并到已有 binds { ... } 内
Mod+T { spawn "kitty" "--single-instance"; }
Mod+Slash { spawn "kitty" "--single-instance" "--class" "quickterminal" "-o" "background_opacity=0.6"; }
```

以下规则放到现有全局窗口规则之后，或相应include的后方。每个参数分别是spawn的字符串参数。

```kdl
window-rule {
    match app-id="^kitty$"
    open-floating false
}
window-rule {
    match app-id="^quickterminal$"
    open-floating true
    opacity 1.0
    default-column-width { proportion 0.7; }
    default-window-height { proportion 0.6; }
    default-floating-position x=20 y=20 relative-to="bottom-right"
}
```

--class在Wayland下设置app-id，不直接让窗口浮动；-o/--override覆盖此次启动的配置项，不改kitty.conf。--single-instance用于新顶层窗口复用同组Kitty进程。参数语义见 [Kitty启动说明](https://sw.kovidgoyal.net/kitty/invocation/)，规则含义见 [Niri窗口规则](https://niri-wm.github.io/niri/Configuration:-Window-Rules.html)。模板为来源建议，目标版本仍需niri validate及新窗口实测。

## 透明度排错

| 设置 | 影响 | 常见误判 |
| --- | --- | --- |
| Kitty background_opacity | 背景；0更透明、1不透明 | 不是Niri整窗透明度；需重开目标窗口核对启动覆盖 |
| Niri opacity | 整窗，含文字 | 0可能让窗口内容不可见；与Kitty背景透明叠加 |
| 后续匹配的窗口规则 | 可能覆盖先前同一属性 | 全局规则没有match也会匹配临时终端 |

只要透明背景、清晰文字时，先保持临时窗口Niri opacity=1，再用Kitty背景参数。来源曾发现quickterminal规则后有全局opacity=0.99，导致前面的0.0不生效；后续检查还纠正了“blur/xray造成观感”的早期猜测，不能将项目预设效果当作本机当前状态。具体历史检查见来源第4–5轮。[公开摘录](../../sources/codex-sessions/Kitty 浮动终端与窗口规则-2026-10-26摘录.md)

排查顺序：确认新窗口app-id → 追踪规则顺序和include → 区分整窗/背景层 → 重开验证 → 再考虑实际启用的背景效果。透明度乘积仅是简单合成直觉，实际显示还受背景及渲染影响，不用它代替观感验收。

## 尺寸与位置

proportion是比例，浮动窗口示例按可用工作区域理解；fixed为逻辑像素，不等于物理像素。宽高0.7/0.6只是起点，可以改为fixed 900/550等明确需求值。default-floating-position以工作区可用区域为基准，bottom-right的x/y向内留边；默认位置不是永远锁死位置，之后可移动并记忆位置。参见 [Niri初始位置](https://niri-wm.github.io/niri/Configuration:-Window-Rules.html#default-floating-position)。

## 单实例与Shell继承

| 对象 | 会复用或继承什么 |
| --- | --- |
| Kitty同实例组 | 复用主进程和GPU字形缓存，有助资源和窗口启动；新建顶层窗口 |
| 不同app-id | 可由Niri区分用途；不等同不同instance-group |
| 新Zsh | 独立进程，仍读取交互启动配置、初始化插件 |
| 原终端滚动记录、变量、函数、别名 | 不自动复制；历史共享另由Zsh设置决定 |
| 当前工作目录 | 单靠single-instance不自动跟随原窗口；需要时另行指定启动目录 |

验证可在两个窗口分别运行 `printf 'Shell=%s Parent=%s\n' "$$" "$PPID"`，结合进程树观察；父PID本身不是所有启动包装方式下的完整证据。只有首个实例也使用单实例机制、组相同且仍存在时才适用；不要把窗口出现速度当作Zsh插件已初始化的证据。[Kitty单实例说明](https://sw.kovidgoyal.net/kitty/invocation/#cmdoption-kitty-single-instance)

## 普通浮动、跟随与屏幕图层

| 需求 | 机制 | 边界 |
| --- | --- | --- |
| 临时窗口脱离平铺 | 普通Kitty + Niri open-floating | 仍属于工作区，不能由浮动属性推断固定在屏幕上 |
| 切换后移到当前工作区 | IPC跟随工具 | 搬运窗口，不保证切换动画期间原位不动 |
| 类似贴图，工作区动画期间仍固定 | layer-shell屏幕图层，例如kitten panel | 不再由普通window-rule决定位置；输入焦点与尺寸另配 |

来源以Niri26.04为设备观察，未查到当时普通窗口原生sticky支持；不将该版本判断写成永久限制。后续mark-shot源码分析启发了layer-shell方案，纠正“必须修改合成器才能固定终端”的过强结论。mark-shot固定提交分析来自会话，未在本轮重新审计其代码。

[Kitty panel官方说明](https://sw.kovidgoyal.net/kitty/kittens/panel/)提供屏幕面板方式。来源记录Kitty0.49.2的最小overlay试验获用户“能用”确认，但随后落地的快捷键/显示隐藏脚本未获完整验收就被要求回退。**最终保留的是回退后的普通浮动终端**；quickterminal-panel脚本及当次备份已由来源助手报告删除，Mod+/恢复旧启动命令。完整演变见 [panel试验与回退来源](../../sources/codex-sessions/Kitty panel 试验与回退-2026-10-26摘录.md)。

本页不重新部署已撤销方案，不将其脚本路径作为依赖；若以后再选择panel，须先明确显示器、尺寸、焦点、隐藏后Shell是否保留及关闭方式，再独立测试。普通spawn不等于单窗口切换，panel与普通窗口配置也不应混用。

## 是否需要单实例

single-instance是可选优化，浮动、透明和位置不依赖它。共享主进程有缓存/启动收益，也可能扩大同一进程故障的影响范围；后者是进程共享的推论。若耗时主要在Zsh插件，收益可能不明显，可去掉示例中的--single-instance；是否采用按实测决定，不把来源“可以去掉”的建议写成已修改当前配置。panel曾用单实例配合toggle-visibility实现保留状态切换，但该部署最终已撤销。

## 复用与回退

配套 [待合并KDL片段](../assets/session-templates/terminal/niri-kitty.kdl.example)是整理阶段新增，生成器terminal模块只复制到新目录，不部署、启动或选择窗口。手动合并后先校验，分别新开普通/浮动终端检查匹配、文字与背景、尺寸、位置；多显示器/缩放也需验证。回退只恢复本次键绑定与规则，不覆盖后续其他Niri设置。

2026-10-26：已读来源七轮增量，核对Kitty/Niri官方相应说明；未重新审计全部上游或运行目标桌面。来源语法通过声明不是本轮部署测试，实际新窗口效果与恢复仍待验收。

相关：[[wiki/guides/shorin-niri 源码学习与配置迁移路线]] · [[wiki/index]] · [[wiki/sources]]
