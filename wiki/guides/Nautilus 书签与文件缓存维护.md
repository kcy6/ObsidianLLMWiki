---
type: guide
status: needs-verification
updated: 2026-10-24
sources:
  - sources/codex-sessions/Nautilus相关配置-2026-10-22会话摘录.md
  - sources/codex-sessions/扫描本机文件并给出管理建议-2026-10-22会话摘录.md
  - scripts/archlinux/stage-session-config.py
---

# Nautilus 书签与文件缓存维护

## 快速使用

书签用 UI 管理；缓存先看候选再决定是否清理。

```bash
paccache -d -k 3
```

执行范围：仅列候选，需已安装 paccache；不删除缓存。

复用要点：保留目录用途、书签与便携应用入口；清理策略不复制历史待删路径。

操作细节：[[wiki/guides/Nautilus 书签与文件缓存维护#手动维护与脚本]]。

按需跳转：[Nautilus 的可配置范围](#nautilus-%E7%9A%84%E5%8F%AF%E9%85%8D%E7%BD%AE%E8%8C%83%E5%9B%B4) · [文件职责与盘点结果](#%E6%96%87%E4%BB%B6%E8%81%8C%E8%B4%A3%E4%B8%8E%E7%9B%98%E7%82%B9%E7%BB%93%E6%9E%9C) · [手动维护与脚本](#%E6%89%8B%E5%8A%A8%E7%BB%B4%E6%8A%A4%E4%B8%8E%E8%84%9A%E6%9C%AC) · [维护与验收](#%E7%BB%B4%E6%8A%A4%E4%B8%8E%E9%AA%8C%E6%94%B6) · [收录与验证范围](#%E6%94%B6%E5%BD%95%E4%B8%8E%E9%AA%8C%E8%AF%81%E8%8C%83%E5%9B%B4)。

来源：[Nautilus相关配置](../../sources/codex-sessions/Nautilus%E7%9B%B8%E5%85%B3%E9%85%8D%E7%BD%AE-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md) · [扫描本机文件并给出管理建议](../../sources/codex-sessions/%E6%89%AB%E6%8F%8F%E6%9C%AC%E6%9C%BA%E6%96%87%E4%BB%B6%E5%B9%B6%E7%BB%99%E5%87%BA%E7%AE%A1%E7%90%86%E5%BB%BA%E8%AE%AE-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md)。

## Nautilus 的可配置范围

Nautilus 是应用，使用它不能证明桌面是完整 GNOME；来源答复的“Arch+GNOME”应按实际环境重新确认。用户书签可以新增、重命名、移除和排序，Home/Recent/Starred/Trash 等内置入口不能等同普通书签随意删改，磁盘入口受标签和挂载状态影响。[GNOME 书签说明](https://help.gnome.org/gnome-help/nautilus-bookmarks-edit.html)

手动打开常用目录后添加书签，再右键或拖拽管理；先用 UI，不直接重写全部 GTK bookmarks。缩略图、搜索范围及列表列按本版本实际偏好页面逐项调整，避免承诺所有版本都有相同菜单。

按需安装 `sudo pacman -Syu --needed sushi`，再选文件按空格检验预览；不因它是 GNOME 组件就安装完整 GNOME。预览范围与性能选项见 [GNOME 文件预览设置](https://help.gnome.org/gnome-help/nautilus-preview.html)。

## 文件职责与盘点结果

建议 Documents 放文档，Projects 放源码/构建工程，Downloads 做临时收件箱，`~/.local/opt` 放长期便携程序，数据盘放大型归档。此为整理建议，不自动移动现有目录，尤其不跨系统改动 WindowsApps、WSL 等系统资料。

来源先盘点 niri 构建目录、AUR 缓存、镜像和便携程序，再经用户要求删除可重建构建产物及 Go 缓存；最终答复报告分配块合计约 14.2 GiB，但 Btrfs 快照可能仍引用数据，可用空间未明显增加。不能把缓存名等同“无用”，也不能把 du 的加总当作独占物理空间。

清理前保存源码、补丁、PKGBUILD、回滚包、配置与清单，核对是否有运行进程和打开文件。来源保留了两个内容不同的 VS Code 安装包以及个人资料；调试包卸载受 sudo 限制未执行，不应写成已卸载。

## 手动维护与脚本

```bash
# 只读先看候选和安装原因，不直接批量移除。
pacman -Qdt
paccache -d -k 3
flatpak list --app
```

paccache 默认保留最近三版，`-d` 只列候选；来源当时没有三版规则下的可清理候选，不能将全部 pacman 缓存当作垃圾。[paccache 手册](https://man.archlinux.org/man/paccache.8)。需要长期启用 timer 时先确认保留策略；系统快照不替代另一物理设备上的资料备份。

Nautilus 脚本放在 `~/.local/share/nautilus/scripts/`，先以少量测试文件验证参数与输出。脚本示例：

```bash
python3 scripts/archlinux/stage-session-config.py nautilus --output /tmp/nautilus-review --apply
bash /tmp/nautilus-review/sha256-files.sh 文件1 文件2
```

该脚本只向标准输出打印 SHA-256，不删除/移动文件；图形脚本菜单不保证展示 stdout，需要另行选择显示方式后才能作为完整菜单工具。暂不生成自动“清垃圾”脚本，避免把历史清理目标推广到其他目录。

## 维护与验收

书签移除不删除目录，移动文件则先检查快捷方式、脚本及项目引用；便携应用移动后更新 desktop Exec、Icon、Path 并保留数据。每次只处理一类缓存，记录候选与实际释放量，必要时确认快照保留期。书签/预览/脚本菜单和删除后应用运行结果仍待逐项验收。关联 [[wiki/guides/Arch Linux 已安装应用盘点与维护]]。

## 收录与验证范围

2026-10-22：阅读所列会话用户消息与最终答复，工具输出按相关主题抽查，未逐行重新审计全部历史执行；来源摘录不包含全部工具输出、内部推理或 Side Chat。历史截图未逐张核验。指南保持 needs-verification，实际部署、图形交互和恢复应按正文验收后补记录。所有工作区会话的归档状态保持不变。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]] · [[wiki/sources]]

公开阅读入口：[知识库导航](../index.md) · [仓库说明](../../README.md)
