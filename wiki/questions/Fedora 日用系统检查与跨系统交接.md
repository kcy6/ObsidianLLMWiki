---
type: question
status: draft
updated: 2026-10-04
sources:
  - wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用.md
  - Fedora桌面配置相关/Fedora Minimal+Niri+DMS.md
---

# Fedora 日用系统检查与跨系统交接

## 用户已确认的目标

2026-10-04 会话记录：用户选择在本机现有 Fedora + Niri + DMS 上整理完善，不重装。先只读审计多余组件，尽量保持干净，再补日用功能、最后美化。熟练后才考虑独立组件替代 DMS，以及迁移 Arch。

“干净”不能按包名判断：应区分完整桌面、独立组件、共享依赖、当前启用服务及重复功能。先给出证据和移除影响，不直接批量卸载或 autoremove。

## 本机信息及其证据边界

Windows 侧于 2026-10-04 通过 CIM、Get-Disk、Get-Partition、Get-NetAdapter 只读采集：机械革命 Yilong15Pro Series GM5HG0A；Ryzen 7 8845H；Radeon 780M + RTX 4060 Laptop；系统可见内存约 15.3 GiB；MT7922 Wi-Fi、有线 Realtek 千兆。

两块磁盘都是约 953.9 GiB、GPT：YMTC PC411 含 Windows C/D 分区；致态 TiPlus7100 含 EFI 和两个 Linux 类型分区。用户确认后者就是现有 Fedora + Niri + DMS。Windows 磁盘编号不能代替 Linux 设备名，不能据此生成格式化命令。Secure Boot 在 Windows 侧因权限不足未确认；Fedora 版本、文件系统、加密、显卡路由、登录管理器均待本机复核。

## 已完成的仓库工作

- 建立并优化 Wiki 规则、索引、来源台账、问题跟踪和只读 PowerShell 检查器。
- [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]] 已完成本地笔记与官方文档对照，尚未在 Fedora 实测。
- Shorin 子模块在本次 Windows worktree 中未初始化；不要为维护 Wiki 重置或更新该独立来源。
- 切换前本次修改尚未提交，不能假定 GitHub 或主工作区已经包含它们。当前 worktree 的 .git 指向 Windows 主仓库，不能原样当独立 Git 仓库复制到 Linux。

## Fedora 上的首轮任务

先阅读根目录与 wiki/AGENTS.md，再检查新环境，不沿用 Windows 的绝对路径。允许只读系统检查和写入 wiki 的报告；尚未授权卸载软件、停用服务或改变系统配置。

1. 确认 Fedora、内核、Niri、DMS 版本及安装来源，识别 DNF 版本后选用对应查询语法。
2. 清点 RPM、用户主动安装记录、软件组、Flatpak、手动安装程序；不能把“依赖安装”直接判为无用。
3. 查看可用会话、登录管理器、系统及用户服务、XDG 自启动和 Niri 启动项；区分安装、启用和实际运行。
4. 对照通知、锁屏、认证代理、门户、剪贴板、壁纸、电源管理等职责，识别重复提供者；核对包依赖、反向依赖和实际用途。
5. 报告分为保留、可选、疑似重复、需进一步确认，每个候选附证据、影响和回退方案。后续卸载另行审阅具体事务，不在审计阶段执行。

系统清单可能带用户名、路径或设备标识；不将凭据、完整环境变量或私人配置无筛选写入仓库。仓库内只保存与结论有关的结果。

## 新会话续接提示词

请阅读 AGENTS.md、wiki/AGENTS.md、wiki/index.md 和 wiki/questions/Fedora 日用系统检查与跨系统交接.md，继续现有 Fedora + Niri + DMS 整理任务。当前已启动到 Fedora，先只读检查实际系统、包依赖与启动服务，判断多余或重复组件，将证据与建议写入 Wiki。不要重装、卸载、停用服务或修改系统配置；先给出可审阅清单。保留 Windows 双系统和现有数据。

相关：[[wiki/index]] · [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]]
