---
type: guide
status: needs-verification
updated: 2026-10-23
sources:
  - sources/codex-sessions/Fcitx5 浅色主题维护-2026-10-23摘录.md
---

# Fcitx5 浅色主题定制与更新维护

适用 Fcitx5 经典用户界面；会话检查记录为 Niri/Wayland、Rime、macOS-light 和 Noto Sans CJK SC 13，属于历史设备观察，未重新盘点。用户最终偏好为**浅色主题**，不因 Waybar 深色而改成深色。

## 手动配置

先复制上游主题到独立命名的 `~/.local/share/fcitx5/themes/my-macos-light`，目标已存在时停止，不再次覆盖。随后只编辑个人副本：在 theme.conf 的 Metadata 中改名称，在经典用户界面配置工具选择个人主题。保留字体13作为起点，需要更紧凑时再试12。

来源建议文字边距左右12、上下6，高亮边距左右10、上下6，背景边距8；背景 #fafafa、边框 #d4d4d4、高亮 #3478f6。它们是待目测验收的起点，修改对应已有段落，不重复追加。背景与高亮图片需结合主题当前引用检查，不应仅因目录有 SVG 就认为正在使用。

主题边距和背景图片缩放机制见 [Fcitx5 官方主题说明](https://fcitx-im.org/wiki/Fcitx_5_Theme)。该页用于核对布局机制，不代表本套 SVG、配置键和 Niri 模糊效果均已验证；EnableBlur 字段不能证明合成器已提供模糊。

## 脚本与回退

整理阶段新增 `scripts/archlinux/prepare-fcitx-theme.py`：默认预览；加 --apply 只创建独立主题副本并改 Metadata/Name，不选择主题、不重启输入法。先预览：

```bash
python3 scripts/archlinux/prepare-fcitx-theme.py --source "$HOME/.local/share/fcitx5/themes/macOS-light" --target "$HOME/.local/share/fcitx5/themes/my-macos-light"
```

确认后同一命令加 --apply，再手动编辑副本并在配置工具应用。原主题和 classicui.conf 应单独备份。验收中文预编辑、横排长候选、高亮边缘和不同缩放比例；回退时重新选择原主题，必要时恢复已备份的界面配置。

上游更新只更新上游目录；个人主题不会自动吸收改进，用 diff 审阅后手动移植。重复 cp 同名文件可能覆盖个性修改；独立副本也不能防止人为选择同名目标覆盖。当前仅有方案，无已部署或恢复验收证据。

相关：[[wiki/guides/Niri 桌面的暗色外观与 GTK Qt 配置]]；本页浅色偏好与桌面其他组件深色可分别选择。

来源：[[sources/codex-sessions/Fcitx5 浅色主题维护-2026-10-23摘录]]（[公开摘录](../../sources/codex-sessions/Fcitx5 浅色主题维护-2026-10-23摘录.md)）。2026-10-23 核对会话文本；未执行实际配置或图形验收。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]] · [[wiki/sources]]
