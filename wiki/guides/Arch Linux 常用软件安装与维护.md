---
type: guide
status: needs-verification
updated: 2026-10-22
sources:
  - sources/codex-sessions/制定软件安装方案.md
  - scripts/archlinux/install-desktop-apps.sh
  - sources/codex-sessions/制定软件安装方案-2026-10-22增量.md
---

# Arch Linux 常用软件安装与维护

适用于 Arch Linux x86_64，覆盖编辑器、Markdown/PDF 阅读、通信、录屏、界面原型与截图编辑的安装选择、验收和维护。软件按需安装；AUR 辅助工具需预先准备。配套脚本默认只预览命令，实际安装须显式指定 `--apply`。

本文使用 `$HOME` 或 `~` 表示执行者的主目录；设备名、项目名及占位符须按目标环境调整。脚本命令均从本仓库根目录执行。

来源基线为 **2026-10-21 至 2026-10-22**；2026-10-22 增量读取会话并核对部分官方资料，未重新验收软件、硬件或远端权限。[来源记录](../../sources/codex-sessions/%E5%88%B6%E5%AE%9A%E8%BD%AF%E4%BB%B6%E5%AE%89%E8%A3%85%E6%96%B9%E6%A1%88.md) · [知识库导航](../index.md)

## 范围、环境与证据

本页最初提炼“制定软件安装方案”会话的 6 个完成轮次：VS Code、Obsidian、ghostwriter、Typora 免费版辨析、QQ 与微信。原始用户消息、助手答复及命令输出保存在 [[sources/codex-sessions/制定软件安装方案|会话来源快照]]。适用于 Arch Linux x86_64；会话观察到 Niri/Wayland、已安装 yay 与 paru，后续聊天软件查询还观察到 Fcitx5 与 Xwayland 命令存在。这些是历史观察，不是每次执行时的环境保证。

原会话只检查环境并提出方案，没有安装事务记录。Obsidian 首次查询未发现已安装包，后续查询输出 `obsidian 1.14.4-2`；说明两个观察时点状态不同，不能据此补造安装过程或声称当前仍为该版本。QQ/微信的包查询没有包含 `wechat-bin`，所以原答复“两个推荐包均未安装”对微信缺少直接查询证据。执行前应重新查询。依据：[[sources/codex-sessions/制定软件安装方案]] 中 Obsidian、Markdown 阅读器及 QQ/微信轮次。

2026-10-22 分两页读取共 17 个完成轮次，新增 11 轮另存 [[sources/codex-sessions/制定软件安装方案-2026-10-22增量|增量快照]]。新增涉及 Telegram、WebKitGTK 排错、PDF 阅读器切换、微信打包比较与实际安装查询、OBS、Fractal、Apostrophe、Workbench、Gradia。旧 6 轮来源快照不覆盖；一处历史截图本次未查看。后文的新证据限定于对应轮次，不表示重新验证整台机器。

## 软件选择与安装渠道

| 需求 | 会话方案 | 边界 |
| --- | --- | --- |
| 微软版 VS Code | AUR `visual-studio-code-bin` | 微软二进制、社区打包；不是微软提供的 Arch 官方包 |
| 开源构建替代 | 官方仓库 `code` | 与微软版选一个；服务及扩展兼容性需按具体需求核对 |
| 管理成套 Markdown 笔记 | 官方仓库 `obsidian` | 保留现有 Vault，通常无需另建一套 |
| 阅读、编辑散落的 Markdown 文件 | 官方仓库 `ghostwriter`，可选 `cmark-gfm` | 依赖 Qt WebEngine；安装体积看完整事务，不能只看主包体积 |
| Typora | 官方试用、购买授权后长期使用 | 增量会话 RPC 记录 `typora-free 0.11.18-4` 为旧版包；不等于当前正式版免费，不自动安装 |
| QQ / 微信 | AUR `linuxqq` / `wechat-bin` | 先测试原生客户端；额外修复/沙箱方案另作选择 |

2026-10-21 核对：[Obsidian 包页面](https://archlinux.org/packages/extra/x86_64/obsidian/)与 [ghostwriter 包页面](https://archlinux.org/packages/extra/x86_64/ghostwriter/)仍列在 Extra，后者列出 `cmark-gfm` 为可选依赖。[微软安装说明](https://code.visualstudio.com/docs/setup/linux)将 Arch 包列为社区维护。AUR 网页被访问防护拦截，但 2026-10-21 通过 [AUR RPC](https://aur.archlinux.org/rpc/v5/info?arg%5B%5D=visual-studio-code-bin&arg%5B%5D=linuxqq&arg%5B%5D=wechat-bin&arg%5B%5D=wechat)核对四个包元数据：`visual-studio-code-bin` 与 `code` 冲突；`wechat` 依赖 `wechat-bin` 和 `portable`，描述为修复和可选沙箱。RPC 不等于 PKGBUILD 或上游下载链审核，安装前仍需审阅配方。

2026-10-21 核对的 Typora 官方商店说明提供 15 天试用，长期使用需授权；“旧测试版免费”与“当前正式版永久免费”不能混同。不推断未提供链接的第三方包是否适用。[Typora 授权说明](https://store.typora.io/)

## 手动安装流程

### 先检查并选择软件

```bash
cat /etc/os-release
uname -m
pacman -Q obsidian ghostwriter cmark-gfm code visual-studio-code-bin linuxqq wechat-bin
command -v yay paru
```

未安装的包会使 `pacman -Q` 报错；这用于观察状态，不表示要一次安装全部。备份已存在的编辑器配置和笔记数据，查看 Arch 更新公告及目标系统的可用空间，选择需要安装的软件。以下安装命令都会进行相应事务，按提示确认；不能只同步仓库数据库后进行局部升级。原会话采用完整升级再安装的流程，见 [[sources/codex-sessions/制定软件安装方案]]。

### Obsidian 与 Markdown 阅读器

按需选择其中一条；需要两者时可合并包名：

```bash
sudo pacman -Syu --needed obsidian
sudo pacman -Syu --needed ghostwriter cmark-gfm
```

安装后普通用户启动 `obsidian` 或 `ghostwriter "/完整路径/文档.md"`。Obsidian 可直接打开现有笔记文件夹作为 Vault；备份应包括笔记、附件与隐藏的 `.obsidian`。ghostwriter 打开文档后启用 HTML 预览，再按需要在文件管理器设置默认打开方式。不要自动批量重写 MIME 关联。来源：[[sources/codex-sessions/制定软件安装方案]] 的 Obsidian 与 Markdown 阅读器轮次。

### 微软版 VS Code

```bash
sudo pacman -Syu --needed base-devel git
yay -S --needed visual-studio-code-bin
# 如果选择 paru，用 paru 替代 yay，不必执行两次。
pacman -Q visual-studio-code-bin
code --version
code .
```

以普通用户运行 AUR 辅助工具和编辑器。阅读 PKGBUILD、下载地址及变更；需要管理员权限时由工具提示。若选择官方仓库开源构建，则改用 `sudo pacman -Syu --needed code`，不同时安装两个发行版。已有另一个发行版时先备份配置、核对包冲突，再决定切换。来源：[[sources/codex-sessions/制定软件安装方案]] 的 VS Code 轮次；包冲突关系以所用版本为准；2026-10-21 的 RPC 核对见上文。

微软版可按需安装中文扩展：

```bash
code --install-extension MS-CEINTL.vscode-language-pack-zh-hans
```

之后使用命令面板 `Configure Display Language` 选择中文并重启。仅在出现问题时，退出已有实例后分别用 `code --disable-gpu`、`code --ozone-platform=x11` 排查 GPU 或后端；X11 测试要求桌面具备相应支持，不默认持久化参数。此处沿用会话方案，截至 2026-10-21 未做 GUI 或扩展安装测试。来源：[[sources/codex-sessions/制定软件安装方案]]。

### QQ 与微信

```bash
sudo pacman -Syu --needed base-devel git
yay -S --needed linuxqq wechat-bin
pacman -Q linuxqq wechat-bin
```

也可选择 `paru`。首次从应用菜单启动并扫码登录；先测试原生客户端，再决定是否增加 `wechat` 所提供的修复及可选沙箱。Niri 下若 X11 应用不能显示窗口，应检查当前 Niri 与 xwayland-satellite 集成，而不是仅以 `Xwayland` 可执行文件存在断言兼容性已就绪。Waybar 用户检查托盘入口；不全局强制 Qt/Electron 后端。来源：[[sources/codex-sessions/制定软件安装方案]] 的 QQ/微信轮次；这些兼容性项目仍需目标机测试。

## 增量软件方案与选择变更（2026-10-22）

本节各项来源为 [[sources/codex-sessions/制定软件安装方案-2026-10-22增量]]；历史包版本仅供追溯，执行前重新查询。以下命令为可复用方案，本次没有执行安装、卸载或 MIME 修改。

### Markdown 与 PDF 阅读器

用户最终选择 Papers 替代 Zathura，并请求安装 Apostrophe、卸载 Mark Text；Workbench 的具体含义仍由原助手按 GNOME 工具解释，未得到用户进一步确认。Papers 选择不能写成已完成卸载，Apostrophe 请求也不能写成已完成安装。

```bash
# 按需要分别执行，不必全部安装
sudo pacman -Syu --needed papers
sudo pacman -Syu --needed apostrophe
papers
apostrophe
```

先用实际文档验证打开、中文输入、预览和需要的导出功能，再保存工作并关闭旧程序。查询后只移除实际已安装且决定放弃的包：

```bash
pacman -Q zathura zathura-pdf-mupdf marktext-bin marktext-bin-debug
# 以下为两组独立选择；先审阅各自事务
sudo pacman -Rns zathura zathura-pdf-mupdf
sudo pacman -Rns marktext-bin marktext-bin-debug
```

增量查询明确返回 Mark Text 主包与 debug 包，但无移除事务证据。不自动删除用户配置、书签、阅读位置或 Markdown/PDF 文件；旧会话中的个人目录删除命令仅作为历史记录保留，综合流程优先备份。

默认程序需在目标安装中核对 desktop 文件和现有关联。采用会话方案的 ID 时，可分别设置并查询：

```bash
xdg-mime query default application/pdf
xdg-mime query default text/markdown
xdg-mime query default text/x-markdown
# 先记录上述旧值，以便回退
xdg-mime default org.gnome.Papers.desktop application/pdf
xdg-mime default org.gnome.gitlab.somas.Apostrophe.desktop text/markdown
xdg-mime default org.gnome.gitlab.somas.Apostrophe.desktop text/x-markdown
```

用实际文件打开验收；回退用记录的旧 desktop ID 恢复关联，不改所有 `text/plain`。Apostrophe 的 WebKitGTK 依赖及 LaTeX 相关可选组件见 [Arch 包页](https://archlinux.org/packages/extra/any/apostrophe/)；[官方功能说明](https://apps.gnome.org/Apostrophe/)与 [Papers 说明](https://apps.gnome.org/Papers/)仅核对用途，不代表导出已测试。

### Telegram 与 WebKitGTK 排错

```bash
sudo pacman -Syu --needed telegram-desktop
# 需要内嵌网页功能且出现对应依赖缺口时，再选择：
sudo pacman -Syu --needed webkitgtk-6.0
telegram-desktop
```

会话先给出安装建议，后续实际查询到 Telegram `7.3.2-1`、WebKitGTK `2.54.1-1`；文件检查为 292 项、0 改动，动态库加载成功，安装后启动的 webviewhelper 进程映射中有该库。这是依赖加载证据；原菜单和截图中的具体功能本次未操作验证，不能直接认定整个问题已解决。不要把历史 PID 当作现在仍运行的进程。

排查顺序：记录错误与版本 → 核对包文件和动态库 → 完全退出后重开 → 检查新进程是否加载 → 重试原操作并记录用户验收。网络不通与 WebKitGTK 缺失分别排查；代理地址、端口按本机配置填写，不在来源快照或模板中保存凭据。[Telegram 包页](https://archlinux.org/packages/extra/x86_64/telegram-desktop/)列出两代 WebKitGTK 为可选嵌入浏览器组件；无需仅为“齐全”同时安装。

### 微信、WPS 与 Typora 的辨析

- 增量 RPC/PKGBUILD 输出记录：`wechat-appimage` 打包腾讯 AppImage，`wechat-bin` 重打包腾讯 DEB；均是原生 Linux 客户端的社区包。经 AUR 安装的 AppImage 仍由包管理器管理，格式不能证明沙箱或兼容性优劣。
- 后续查询明确输出 `wechat-bin 4.1.13.26-1`，启动命令与 desktop 文件归它管理；原复合命令因用户 desktop 通配符无匹配返回 1，所以用户目录中的重复入口尚未完整扫描。不能把这条命令当作全部查询成功。
- 若确需换包：关闭微信、核对实际安装及文件归属，卸载不保留的客户端包，再重装保留包并复查归属；不强制覆盖文件、不删除聊天数据。`wechat` 增强包装与独立客户端的关系另查依赖，不能仅凭包数判断重复。
- WPS 两包 `wps-office-cn`、`wps-office-mui-zh-cn` 及 `pacseek` 是独立的按需选择；旧版 Typora 已在 RPC 中识别为 `0.11.18-4`，修正旧页“具体包尚未识别”的范围限制，仍不纳入自动安装。

可按需预览 `wps`、`pacseek` 安装组；中文界面、字体、打开/保存/打印与包来源仍需验收。本次 AUR 网页访问被防护拦截，包格式和旧版本辨析依据会话保存的 RPC/配方输出，不声称完成当前下载链审核。

### OBS、Fractal、Gradia 与 Workbench

| 软件 | 安装与启动（各行独立选择） | 验收重点 |
| --- | --- | --- |
| OBS Studio | `sudo pacman -Syu --needed obs-studio`；`obs` | PipeWire 画面、音频、短片回放与编码器；浏览器源插件按需选择 |
| Fractal | `sudo pacman -Syu --needed fractal`；`fractal` | Matrix 登录、设备验证、同步、收发与钥匙环解锁 |
| Gradia | `sudo pacman -Syu --needed gradia`；`gradia` | 导入已有图片、标注、复制和保存；应用内截图单独验证 |
| GNOME Workbench | `flatpak install flathub re.sonny.Workbench`；`flatpak run re.sonny.Workbench` | 示例项目、GTK 预览及需要的语言组件 |

OBS 会话查询到 PipeWire、WirePlumber 和门户处于 active，且有 AMD/NVIDIA 双显卡，但没有录屏或 NVENC 实测。NVENC 作为原设备候选，不写成新主机默认；先录制短片验证画面与音频，异常时再检查门户日志。复合 GPU/门户查询退出码 2，保留已输出观察，不能判定每个检查项均成功。[Arch OBS 包页](https://archlinux.org/packages/extra/x86_64/obs-studio/)支持仓库安装方案；[OBS 官方页面](https://obsproject.com/kb/linux-installation)在非 Ubuntu 发行版推荐 Flathub，因此仓库包是本库维护选择，不是 OBS 官方统一首选。

Fractal 查询有钥匙环服务运行证据，但无登录与加密恢复验收；恢复密钥不入库。[Arch Fractal 包页](https://archlinux.org/packages/extra/x86_64/fractal/)列出 Secrets 服务依赖。抓取页面版本为 14.1，会话本地查询为 14.2，不用网页缓存覆盖设备历史观察。

[Gradia 官方介绍](https://apps.gnome.org/Gradia/)核对标注用途，[Arch 包页](https://archlinux.org/packages/extra/x86_64/gradia/)核对仓库渠道；上游版本与仓库版本可能不同。Workbench 指 [GNOME 原型工具](https://apps.gnome.org/Workbench/)及其 [Flathub ID](https://flathub.org/apps/re.sonny.Workbench)，与 `mysql-workbench` 无关。使用前先确认用户要哪一个，并核对远端与安装范围；来源设备有 Flathub 镜像不代表新机已配置。

上述新增仓库软件使用 `sudo pacman -Syu` 统一更新，卸载时仅选择实际安装包并审阅事务；配置及用户数据保留。Workbench 使用 `flatpak info/update/uninstall re.sonny.Workbench` 查询、更新、卸载，不加删除数据选项；卸载不等于已实现完整回退。

## 脚本配置流程

[安装脚本](../../scripts/archlinux/install-desktop-apps.sh)是2026-10-21 收录时新增，原会话中没有独立脚本。脚本于 2026-10-22 扩充上述新增软件与 GNOME Workbench 的 Flatpak 安装组。脚本封装包安装流程，不自动登录账号、设置默认程序、安装语言扩展、写入自启动或更改渲染后端。

在仓库根目录，以普通用户运行：

```bash
# 默认只预览，不执行 pacman 或 AUR 安装。
bash scripts/archlinux/install-desktop-apps.sh obsidian markdown
bash scripts/archlinux/install-desktop-apps.sh --helper paru vscode chat

# 确定软件范围并审阅后，显式执行；仍保留包管理器交互确认。
bash scripts/archlinux/install-desktop-apps.sh --apply --helper paru vscode chat
```

可选组：`obsidian`、`markdown`（保留原含义：ghostwriter + cmark-gfm）、`vscode`、`code-oss`、`chat`（QQ + 微信）、`telegram`、`telegram-webview`（Telegram + WebKitGTK）、`papers`、`apostrophe`、`obs`、`fractal`、`gradia`、`workbench`（GNOME Flatpak）、`wps`（中文套件与界面）、`pacseek`。不提供“默认全装”，也不自动安装未核实来源的 Typora 免费包。`vscode` 与 `code-oss` 同选会报错；应用模式还会检查已安装的另一发行版。需要 AUR 时显式指定 helper，或自动优先选已存在的 yay，其次 paru；两者均缺失时应用模式退出，不代装辅助工具。`workbench` 要求 Flatpak 及已有 `flathub` 远端，不自动安装 Flatpak、添加源或决定 system/user 安装范围，歧义由原生交互确认；只选 Flatpak 时不触发 pacman 升级。`chat` 若检测到 `wechat-appimage` 则停止，要求先人工处理渠道选择。脚本不自动卸载 Mark Text/Zathura、不改默认程序、不删除数据。

重复运行通过 `--needed` 避免重复安装同版本目标包，但完整系统升级仍可能改变其他包，因此不是无副作用操作。脚本在 `${XDG_STATE_HOME:-$HOME/.local/state}/wiki-desktop-apps/` 下创建权限受限的独立执行记录目录，保存升级前包清单、显式安装清单、目标包及退出码；成功时保存目标包版本。包清单不是配置备份或可自动恢复的系统快照。

若 AUR 阶段失败，官方仓库升级可能已经完成。不要把整个过程视为原子事务；阅读错误、检查安装状态后处理，不自动降级系统、删除配置或取消用户数据。脚本不实现自动回滚。

新增组预览示例：

```bash
bash scripts/archlinux/install-desktop-apps.sh papers apostrophe telegram-webview
bash scripts/archlinux/install-desktop-apps.sh obs fractal gradia workbench
```

Flatpak 阶段记录安装前后应用列表；任一渠道失败即停止并保存退出码，之前完成的渠道不会自动回退。

## 验收与故障检查

| 软件/范围 | 安装后检查 | 截至 2026-10-21 的证据 |
| --- | --- | --- |
| 包安装 | `pacman -Q` 查询实际所选包 | 来源仅有环境查询，没有安装事务记录 |
| VS Code | 版本、窗口、目录打开、中文扩展、需要的扩展市场/同步功能 | 未实测 |
| Obsidian | 现有 Vault 可打开、中文输入、附件及插件需求 | 仅历史包查询证据，未验收 |
| ghostwriter | 中文文档、HTML 预览、链接和所需 Markdown 语法 | 未实测 |
| QQ / 微信 | 中文输入、复制粘贴、文件收发、通知、托盘、退出和所需通话功能 | 未实测；截图/共享另受客户端与桌面环境影响 |
| 重登录 | 需要的桌面入口及后台退出行为 | 未设置自启动，未测试 |

出现问题时先记录包版本、会话类型、启动日志与复现步骤，再逐项检查；不能由“窗口可打开”推断截图、通知和中文输入都正常。相关桌面条件见 [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]]。

## 后续更新、迁移与卸载

- 官方仓库软件随 `sudo pacman -Syu` 更新；AUR 用户选用 `yay -Syu` 或 `paru -Syu`，阅读更新和构建变更。不要因为脚本存在而跳过审阅。
- 更新后重新检查关键功能；包改名、维护者或依赖变化时复查本页的安装映射与脚本，调整来源台账。记录新版本及验证日期，不覆盖旧实践记录冒充新验收。
- 迁移时保存已安装包清单和所用脚本版本；单独备份 Vault、编辑器配置和需要保留的应用数据。VS Code 的 `~/.config/Code`、`~/.vscode` 是会话列出的常见目录；采用其他发行版或 XDG 路径时先核对实际位置。QQ/微信数据路径未在来源中确认，不猜测批量清理路径。
- 卸载按实际已安装包选择，例如 `sudo pacman -Rns visual-studio-code-bin`、`sudo pacman -Rns obsidian`、`sudo pacman -Rns ghostwriter` 或 `sudo pacman -Rns linuxqq wechat-bin`。仔细阅读依赖移除列表；`cmark-gfm` 是否保留取决于其他用途。不自动执行孤儿包批量删除。
- 卸载应用与删除个人数据分开。Vault、聊天数据和编辑器设置先备份再决定清理；脚本不删除它们。系统升级回退需要已有系统备份方案，不能靠本脚本的包清单保证恢复。

维护步骤综合自 [[sources/codex-sessions/制定软件安装方案]] 的更新/卸载建议，并补充脚本实际作用边界。

## 待验证与核对记录

| 项目 | 状态 | 下一步与结论落点 |
| --- | --- | --- |
| AUR 配方及下载链 | 待验证 | 安装前审阅所选版本 PKGBUILD，记录版本和来源；更新渠道表 |
| 软件安装及图形功能 | 待实践 | 按验收表逐项测试并记录环境；更新证据列 |
| 真实安装脚本与失败恢复 | 待实践 | 在可恢复的目标环境执行；确认包状态及失败处理，不以预览测试替代 |
| Typora 旧版包 | 待验证 | RPC 已识别版本；当前配方/下载链及适用性仍待审阅，不纳入脚本 |
| 新增软件与替换选择 | 待实践 | Papers/Apostrophe 及新增工具按本节验收；旧包卸载和 MIME 尚未执行 |
| Telegram WebView | 待实践 | 库已加载；重试原菜单并记录功能验收 |
| Workbench 含义 | 待验证 | 用户未确认 GNOME 还是 MySQL，不默认当作必装模块 |

2026-10-21：读取会话接口返回全部 6 轮用户/助手消息和命令输出，未发现输出截断；保存限定范围的来源快照。核对官方软件包页、微软 Linux 安装说明、Typora 授权页及 AUR RPC；AUR/ArchWiki HTML 页面受访问防护限制，未核对 PKGBUILD。本页保持 needs-verification。2026-10-21 仅验证脚本语法、预览及模拟命令执行；真实安装及 GUI 功能尚未验收。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/sources]] · [[wiki/index]]

公开阅读入口：[仓库说明](../../README.md) · [Arch Linux 主题](../topics/Arch%20Linux%20与桌面环境.md) · [来源台账](../sources.md)

## 应用盘点与复用规划

安装或移除软件后的基线维护见 [[wiki/guides/Arch Linux 已安装应用盘点与维护]]；新主机的软件选择与配置部署统一跟踪于 [[wiki/questions/Arch Linux 个性化配置复用计划]]。
