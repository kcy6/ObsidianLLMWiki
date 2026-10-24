---
type: guide
status: needs-verification
updated: 2026-10-24
sources:
  - sources/codex-sessions/排查 Codex Add 无响应-2026-10-22会话摘录.md
  - sources/codex-sessions/排查 fuzzel 滚轮翻页问题-2026-10-22会话摘录.md
  - sources/codex-sessions/排查 Obsidian 大纲插件不显示-2026-10-22会话摘录.md
  - scripts/archlinux/stage-session-config.py
---

# Niri 文件选择器与桌面应用入口排错

## 快速使用

按启动器、应用、Portal、面板顺序缩小问题范围。

```bash
journalctl --user -b -u xdg-desktop-portal --no-pager -n 80
```

执行范围：只读查看当前用户日志；分享前审阅敏感信息。

复用要点：后端片段按接口合并；历史补丁先确认目标软件包是否仍需要。

操作细节：[[wiki/guides/Niri 文件选择器与桌面应用入口排错#文件选择器没有弹出]]。

按需跳转：[诊断顺序](#%E8%AF%8A%E6%96%AD%E9%A1%BA%E5%BA%8F) · [文件选择器没有弹出](#%E6%96%87%E4%BB%B6%E9%80%89%E6%8B%A9%E5%99%A8%E6%B2%A1%E6%9C%89%E5%BC%B9%E5%87%BA) · [回补补丁与恢复 Nautilus](#%E5%9B%9E%E8%A1%A5%E8%A1%A5%E4%B8%81%E4%B8%8E%E6%81%A2%E5%A4%8D-nautilus) · [Fuzzel 滚轮与终端应用](#fuzzel-%E6%BB%9A%E8%BD%AE%E4%B8%8E%E7%BB%88%E7%AB%AF%E5%BA%94%E7%94%A8) · [Quiet Outline 面板](#quiet-outline-%E9%9D%A2%E6%9D%BF) · [维护与验收](#%E7%BB%B4%E6%8A%A4%E4%B8%8E%E9%AA%8C%E6%94%B6) · [收录与验证范围](#%E6%94%B6%E5%BD%95%E4%B8%8E%E9%AA%8C%E8%AF%81%E8%8C%83%E5%9B%B4)。

来源：[排查 Codex Add 无响应](../../sources/codex-sessions/%E6%8E%92%E6%9F%A5%20Codex%20Add%20%E6%97%A0%E5%93%8D%E5%BA%94-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md) · [排查 fuzzel 滚轮翻页问题](../../sources/codex-sessions/%E6%8E%92%E6%9F%A5%20fuzzel%20%E6%BB%9A%E8%BD%AE%E7%BF%BB%E9%A1%B5%E9%97%AE%E9%A2%98-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md) · [排查 Obsidian 大纲插件不显示](../../sources/codex-sessions/%E6%8E%92%E6%9F%A5%20Obsidian%20%E5%A4%A7%E7%BA%B2%E6%8F%92%E4%BB%B6%E4%B8%8D%E6%98%BE%E7%A4%BA-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md)。

## 诊断顺序

区分启动器、应用自身、Portal 后端和 UI 面板状态。进程存在、服务 active、命令返回零、窗口可见和功能成功是不同层次的证据。来源会话含历史截图但本次未逐图核验。

## 文件选择器没有弹出

来源环境记录 Niri 26.04、Nautilus 51.1、GNOME Portal 51.0；应用走 XWayland。日志出现 `Invalid service client type`、`wl_proxy_get_version` 和 `Remote peer disconnected`，后续分析关联上游 [d054395 修复](https://github.com/niri-wm/niri/commit/d054395225560bbd39a76f958a5f612de4f284b0)。不能将这一具体版本问题外推到所有文件选择器故障。

```bash
pacman -Q niri nautilus xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-gtk
journalctl --user -b -u xdg-desktop-portal -u xdg-desktop-portal-gnome --no-pager -n 80
coredumpctl info nautilus --no-pager
```

上游提交已存在不代表已进入发行版。先核对实际软件包是否包含修复；避免照抄历史“最新版仍是26.04”的说法，也不预测发布时间。

临时绕过：先备份 `~/.config/xdg-desktop-portal/niri-portals.conf`，在已有 preferred 段只合并 `org.freedesktop.impl.portal.FileChooser=gtk;`，保留其他接口与默认后端；然后在可接受对正在使用应用影响的时机重启用户 Portal。GTK 后端服务正常并不证明用户已确认 Add 弹窗恢复。

脚本模板：`python3 scripts/archlinux/stage-session-config.py portal --output /tmp/portal-review --apply`。仅生成一个待合并片段，不能直接覆盖整份配置，也不自动重启服务。

## 回补补丁与恢复 Nautilus

来源后来选择保留 Nautilus，构建了同名 niri `26.04-1.1` 包，最终答复报告 217 项测试通过；随后让用户自行安装、重新登录 Niri，再恢复 GNOME FileChooser。该会话没有安装后 GUI 验收确认，不能标记根因修复已在桌面生效。

来源目录 `niri-patched` 的 README、install.sh、enable-nautilus.sh 在本次只读查看；本库不携带构建包或回滚包，因此不是可直接运行的发布套件。原脚本会检查包版本和正在运行的二进制后切换后端，仍需用户确认实际版本与重登录。通用流程：审阅目标 PKGBUILD与补丁、按当前依赖构建同名包、保留已验证的旧包/配置、使用 pacman 安装、重登录、恢复后端、测试弹窗及崩溃日志。

不要泛化历史 `makepkg -d` 跳过依赖检查和临时解压 clang 的构建策略；新环境先满足实际构建依赖。版本递增示例 26.04-1 → 26.04-1.1 → 26.04-2 仅说明该序列，最终由包版本比较规则决定可升级性。官方更新若不含补丁可能复现；进入正式包后停止维护本地补丁。回退使用自存的已验证包与配置，不提供不存在文件的下载保证。

## Fuzzel 滚轮与终端应用

来源 fuzzel 1.15.0 未检测到禁用鼠标；后续用户描述悬停总选回指针所在行。把指针移出结果行后滚动，或用 PageUp/PageDown 区分滚轮逐项移动与整页翻动。不要只以“新版逐行”解释全部现象。`enable-mouse=no` 会同时禁用点击/滚轮，不等同于单独关悬停。[Fuzzel 配置手册](https://man.archlinux.org/man/fuzzel.ini.5.en)

本次上游 Codeberg 页面访问失败，未核实该版本悬停逻辑源码；“悬停干扰”保留为与用户观察吻合的解释，尚缺输入事件跟踪或补丁验证。

Yazi 等 `Terminal=true` 应用还需要启动器知道用哪个终端；来源后续盘点会话报告将 Fuzzel 的 `terminal=kitty -e` 配好，并修正 xdg-terminals.list。后者应存终端 desktop ID，不能写成随意 shell 命令；详见应用盘点指南。

## Quiet Outline 面板

来源最初误判为内置 outline 关闭，用户澄清后确认第三方 Quiet Outline 0.5.20 已安装启用但无面板。最终操作为 Obsidian 命令面板 Ctrl+P 搜索 Quiet Outline 并调出；不需要为了该插件开启核心大纲，也不能批量覆盖工作区文件。[插件项目](https://github.com/guopenghui/obsidian-quiet-outline)

先查插件是否加载、命令是否存在、面板是否收起，再重开应用并检查控制台。来源只给出调出方式，没有后续用户确认。此类 UI 操作不为凑齐脚本而生成工作区 JSON 改写器。

## 维护与验收

每次升级分别测试应用启动、目录选择、保存对话框、Fuzzel 指针/翻页、Quiet Outline 打开和标题更新。保留版本、后端配置、日志片段与恢复方法；不要把临时 GTK 绕过、补丁构建成功、根因修复部署成功混写。所有来源会话继续保留现状，不在收录后自动归档。

## 收录与验证范围

2026-10-22：阅读所列会话用户消息与最终答复，工具输出按相关主题抽查，未逐行重新审计全部历史执行；来源摘录不包含全部工具输出、内部推理或 Side Chat。历史截图未逐张核验。指南保持 needs-verification，实际部署、图形交互和恢复应按正文验收后补记录。所有工作区会话的归档状态保持不变。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]] · [[wiki/sources]]

公开阅读入口：[知识库导航](../index.md) · [仓库说明](../../README.md)
