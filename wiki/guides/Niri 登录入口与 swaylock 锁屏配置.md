---
type: guide
status: needs-verification
updated: 2026-10-27
sources:
  - sources/codex-sessions/GDM 依赖与启动器入口-2026-10-27摘录.md
  - sources/project-notes/Arch模块范围盘点-2026-10-26.md
  - sources/codex-sessions/登录管理器与 swaylock 锁屏-2026-10-26摘录.md
  - scripts/archlinux/stage-session-config.py
---

# Niri 登录入口与 swaylock 锁屏配置

## 快速判断

开机/注销登录入口与当前桌面锁屏分开维护。现有TTY启动能满足使用时，不必仅为外观安装登录管理器；Win+Alt+L继续用于锁当前会话，不改成注销或裸切换登录页。

```bash
command -v swaylock
swaylock --help
```

只查看入口和可用选项，不实际锁屏。来源设备记录为Niri、无display-manager.service、swaylock-effects 1.7.0.0；这些是会话时点观察，不是本轮系统盘点。

## 登录、锁屏与注销的区别

| 需求 | 方案/动作 | 对当前程序的影响 |
| --- | --- | --- |
| 开机/注销后认证并进桌面 | TTY，或greetd + tuigreet/ReGreet | 启动桌面会话 |
| 暂离后回到原窗口 | swaylock/effects | 保留原会话与任务，需验证真实锁定及解锁 |
| 注销返回登录页 | 结束当前会话 | 程序通常随会话关闭，不作为锁屏替代 |
| 切换到登录页面 | 依赖完整会话集成 | 单纯切换不证明旧会话被锁定 |

来源比较：tuigreet偏键盘文本界面，ReGreet偏图形交互；SDDM适合另有图形主题需求，GDM随GNOME场景再评估。尚未选定或部署登录管理器，不生成默认启用服务脚本，避免把选型写成已安装。

## 最新偏好与实施范围

2026-10-26追加会话用户表示喜欢GDM的美化风格，助手据此提出GDM登录＋现有swaylock-effects锁屏的组合；这是偏好与建议，尚无GDM部署证据。本机只读包查询未找到gdm，display-manager.service为not-found；swaylock配置已存在模糊、时钟和圆环，但未进行解锁测试。此前tuigreet/ReGreet推荐不再视为默认选定方案。来源及读取限制见 [[sources/project-notes/Arch模块范围盘点-2026-10-26]]。首版工程先实现lockscreen，login-manager独立后续处理，见 [[wiki/questions/Arch Linux 个性化配置复用计划]]。

## GDM依赖与菜单入口

后续来源助手报告已检查“一次GDM安装”的日志，提到gnome-shell、mutter、gnome-session、gnome-settings-daemon、IBus等依赖；这比前一时点“未安装”的记录更晚，但本轮未读取完整安装事务或复查系统，不能由该报告推断GDM服务已启用、默认会话正确或登录验收完成。旧未安装状态仅保留为历史。

包安装与启动器可见入口不是同一清单。来源判断普通新增入口可能是IBus Preferences，其他部分组件入口NoDisplay=true；已有Nautilus等应用不能仅凭GNOME名称就归因本次GDM安装。具体依赖和desktop可见性按当前包、用户覆盖、NoDisplay及OnlyShowIn/NotShowIn复核，不做跨版本数量保证。

如只想减少Fuzzel入口，先核对desktop文件归属，再采用用户级同名Hidden=true覆盖，回退仅移除自己创建的覆盖；不为隐藏入口强制卸载GDM所需组件。隐藏不会卸载包或停用服务。通用入口诊断见 [[wiki/guides/Arch Linux 已安装应用盘点与维护]]。来源 [[sources/codex-sessions/GDM 依赖与启动器入口-2026-10-27摘录]]，无新增部署脚本，不修改真实启动器。

## swaylock与effects

[swaylock](https://github.com/swaywm/swaylock)是Wayland锁屏器；effects分支增加截图背景、模糊、时钟等视觉选项，安装后命令仍可能叫swaylock。先用本机help确认，不照搬另一分支选项。

[jirutka/swaylock-effects](https://github.com/jirutka/swaylock-effects)当前标为unmaintained，可作为历史配置参考，不能当作积极维护保证。来源提到effect-compose等参数未在设备help中出现；不存在的选项不可直接合并。不要从effects版本字符串推断所有分支功能一致。

## 文件位置与自定义范围

配置入口为 `~/.config/swaylock/config`，命令行形式去掉--，有值写为键=值。来源Niri按键直接执行swaylock；实际机器仍须追踪快捷键/脚本是否另传配置路径。

| 项目 | 可复用起点 | 调整时核对 |
| --- | --- | --- |
| 背景 | screenshots或image=/绝对路径 | 图片可读；截图也可能保留桌面私密内容于屏幕 |
| 特效 | effect-blur=7x5、effect-vignette=0.5:0.5 | 本机支持、性能与多显示器 |
| 时钟 | clock、timestr=%H:%M、datestr=%Y-%m-%d | 字体与缩放 |
| 圆环/反馈 | indicator、半径/粗细及状态配色 | 密码错误、验证中、Caps Lock等状态可辨认 |
| 颜色 | RRGGBB或RRGGBBAA，不加# | 透明度与背景对比 |
| 空闲/休眠 | swayidle等会话机制另配 | 不是仅改锁屏外观就自动覆盖所有触发场景 |

来源grace表示免密码宽限时间，不是自动锁屏等待；下方模板不加入宽限配置。来源的Catppuccin/niri-setup等预设仅作历史参考入口，本轮未下载、运行脚本或逐张审核截图。

## 模板生成与手动合并

仓库根目录执行，只预览：

```bash
python3 scripts/archlinux/stage-session-config.py lockscreen --output /tmp/lockscreen-review
```

同命令加--apply只生成新目录的配置示例，不安装包、不锁屏、不改快捷键或服务。模板为整理阶段新增，参考来源已列参数；适用swaylock-effects，不直接给基础swaylock全量使用。

备份已有config后逐项合并，按help删去不支持选项。先在能恢复的本地环境验证密码解锁、错误密码、截图/图片、显示器与缩放，再绑定快捷键及空闲/休眠事件；真正调用swaylock会锁住桌面，本轮未执行。回退只恢复本次配置/绑定，保留原来可用的锁屏入口；不能把外观正常当作认证和休眠链路已验收。

## 验证范围与后续

2026-10-26全文读取来源5轮用户/最终答复，核对swaylock与effects项目范围；未审计认证实现、登录管理器配置或实际解锁链。选型未定、真实锁屏与回退未测，保留needs-verification。

来源：[[sources/codex-sessions/登录管理器与 swaylock 锁屏-2026-10-26摘录]]（[公开摘录](../../sources/codex-sessions/登录管理器与 swaylock 锁屏-2026-10-26摘录.md)）。相关 [[wiki/guides/Niri 桌面的暗色外观与 GTK Qt 配置]] · [[wiki/index]] · [[wiki/sources]]。
