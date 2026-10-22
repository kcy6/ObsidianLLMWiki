---
type: guide
status: needs-verification
updated: 2026-10-22
sources:
  - sources/codex-sessions/为什么当前桌面主题默认是亮色，怎么配置为暗色-2026-10-22会话摘录.md
  - scripts/archlinux/stage-session-config.py
---

# Niri 桌面的暗色外观与 GTK Qt 配置

适用条件与来源日期在正文中分别列明；占位路径、设备名与版本须按目标环境调整。以下是知识收录，不代表已在新机器完成部署。

来源：[为什么当前桌面主题默认是亮色，怎么配置为暗色](../../sources/codex-sessions/%E4%B8%BA%E4%BB%80%E4%B9%88%E5%BD%93%E5%89%8D%E6%A1%8C%E9%9D%A2%E4%B8%BB%E9%A2%98%E9%BB%98%E8%AE%A4%E6%98%AF%E4%BA%AE%E8%89%B2%EF%BC%8C%E6%80%8E%E4%B9%88%E9%85%8D%E7%BD%AE%E4%B8%BA%E6%9A%97%E8%89%B2-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md)。

## 分层理解

来源环境是 Niri，而不是因使用 Nautilus 就存在完整 GNOME 会话。GTK3、GTK4/libadwaita、Qt、终端、Waybar和应用自身主题分别管理；设置一个 GTK 主题不能让所有应用同时变暗。来源只检查并给方案，未执行暗色设置。

## 手动设置

先记录旧值：

```bash
gsettings get org.gnome.desktop.interface color-scheme
gsettings get org.gnome.desktop.interface gtk-theme
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
```

第一项声明暗色偏好，后一项主要面向传统 GTK；应用是否响应仍需检查。不要把 `GTK_THEME` 作为全局长期覆盖。Portal 对颜色偏好的接口说明见 [Settings 文档](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Settings.html)。

Qt6 可按需安装 `sudo pacman -Syu --needed qt6ct`。在已有 Niri environment 块核对后合并 `QT_QPA_PLATFORMTHEME "qt6ct"`，保留输入法配置，不叠加互相冲突的主题变量；运行 `QT_QPA_PLATFORMTHEME=qt6ct qt6ct` 选择 Fusion 与暗色方案，注销登录再检查。[qt6ct README](https://github.com/trialuser02/qt6ct/blob/master/README)。Qt5/特定 KDE 应用另按实际需求配置，不自动装全套桌面。

Kitty 可用 `kitten themes`；Waybar 来源已是暗色，关联 [[wiki/guides/Niri 个性化 Waybar 搭建与亮度调节]]。Fuzzel 修改现有 `[colors]` 段，Mako 修改全局色彩并 `makoctl reload`；局部规则可能覆盖全局。VS Code/Obsidian/浏览器及网页需要分别选择或启用跟随系统。

## 脚本流程

```bash
python3 scripts/archlinux/stage-session-config.py theme --output /tmp/theme-review
python3 scripts/archlinux/stage-session-config.py theme --output /tmp/theme-review --apply
bash /tmp/theme-review/apply-gtk.sh
# 审阅后，以下才修改当前桌面用户的 gsettings：
bash /tmp/theme-review/apply-gtk.sh --apply
```

第一阶段仅生成待合并的 Fuzzel/Mako 片段和 GTK 脚本。GTK 脚本保存两项旧值到私有临时目录，不重写 Qt 或 Niri；失败可能只应用部分设置。旧值需另存持久备份，系统清理临时目录后不能依赖它恢复。Fuzzel/Mako 片段只手动合并，不整文件覆盖。

## 验收、维护及回退

```bash
gdbus call --session --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.portal.Settings.Read org.freedesktop.appearance color-scheme
```

颜色偏好 1 表示暗色；仅证明信号值，不保证每个应用渲染正确。分别重开 GTK、Qt、终端、启动器与通知检查；升级后复查环境变量和应用自有主题。按保存的 gsettings 值恢复，Qt/Niri/Fuzzel/Mako 按各自备份恢复；不把本页脚本称为全桌面一键主题切换工具。

## 收录与验证范围

2026-10-22：阅读所列会话用户消息与最终答复，工具输出按相关主题抽查，未逐行重新审计全部历史执行；来源摘录不包含全部工具输出、内部推理或 Side Chat。历史截图未逐张核验。指南保持 needs-verification，实际部署、图形交互和恢复应按正文验收后补记录。所有工作区会话的归档状态保持不变。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]] · [[wiki/sources]]

公开阅读入口：[知识库导航](../index.md) · [仓库说明](../../README.md)
