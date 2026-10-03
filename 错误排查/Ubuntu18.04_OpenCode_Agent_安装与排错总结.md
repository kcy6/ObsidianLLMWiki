# Ubuntu 18.04 安装 OpenCode Agent：问题排查与最终方案

> 环境：Ubuntu 18.04.6 LTS（x86_64）、glibc 2.27、Python 3.6.9、Bash\
> 最终方案：OpenCode 1.14.48 + kitty 0.35.2 + JetBrainsMono Nerd Font\
> 目的：在较老的 100ASK / i.MX6ULL Ubuntu 开发环境中使用现代终端
> Agent，同时尽量不升级系统核心组件。

## 1. 最终结论

这次安装遇到的问题不是单一原因，而是几层兼容性问题叠加：

1.  OpenCode 2.0.18 二进制可以在 Ubuntu 18.04
    上启动，但后台服务/standalone 模式异常，最终出现 HTTP 503。
2.  降级到 OpenCode 1.14.48 后，程序本身可以运行，但首次沿用了 2.0.18
    创建的 SQLite 数据库，导致 Drizzle 数据库迁移失败。
3.  清理旧数据库后，OpenCode 1.14.48 成功进入 TUI。
4.  Ubuntu 18.04 自带 GNOME Terminal 3.28.2 / VTE 0.52.2
    太老，无法正确处理 OpenCode/OpenTUI
    使用的部分现代终端控制序列，因此出现大量乱码。
5.  改用 kitty 0.35.2 后，OpenCode TUI 已能正常显示。
6.  kitty 手动安装后不会自动出现在 GNOME 应用列表，需要安装/修正
    `kitty.desktop`；尤其 `TryExec=kitty` 需要注意 GNOME Shell 的 PATH
    与交互式 Bash 的 PATH 不一定相同。

最终不要为了 OpenCode 手动升级系统 glibc，也没有必要替换 Ubuntu 18.04
的系统 VTE。

------------------------------------------------------------------------

## 2. 基础环境确认

执行：

``` bash
uname -m
ldd --version | head -n 1
python3 --version
echo $SHELL
```

本机结果：

``` text
x86_64
ldd (Ubuntu GLIBC 2.27-3ubuntu1.6) 2.27
Python 3.6.9
/bin/bash
```

`glibc`（GNU C Library）是 Linux 用户空间最核心的运行库之一。大量 C/C++
程序以及预编译 Linux 二进制都会依赖它。

对于 Ubuntu 18.04，这里的关键约束是：

``` text
Ubuntu 18.04
└── glibc 2.27
```

不要为了运行一个 Agent 直接替换系统 glibc，否则可能破坏
apt、shell、系统程序以及原有 BSP/SDK 开发环境。

------------------------------------------------------------------------

## 3. 首次安装 OpenCode 2.0.18

使用安装脚本：

``` bash
curl -fsSL https://opencode.ai/v2/install | bash
```

安装完成后提示已经将 OpenCode 加入：

``` text
/home/book/.bashrc
```

第一次直接执行：

``` bash
opencode --version
```

却出现：

``` text
Command 'opencode' not found
```

### 原因

安装器虽然修改了 `~/.bashrc`，但**当前已经运行的 Bash
不会自动重新读取配置文件**。

执行：

``` bash
source ~/.bashrc
```

之后：

``` bash
opencode --version
```

成功：

``` text
opencode v2.0.18
```

并确认二进制：

``` bash
file "$(command -v opencode)"
ldd "$(command -v opencode)"
```

说明程序本身可以被当前系统动态加载。

------------------------------------------------------------------------

## 4. OpenCode 2.0.18：后台服务启动超时

在工程目录运行：

``` bash
opencode
```

出现：

``` text
Starting background server...
Error: Timed out waiting for the background service to start
```

查看日志：

``` bash
tail -n 100 ~/.local/share/opencode/log/opencode.log
```

发现反复出现：

``` text
Managed service port 49374 on 127.0.0.1 is already in use by another process.
```

检查：

``` bash
ps aux | grep '[o]pencode'
ss -lntp | grep 49374
lsof -iTCP:49374 -sTCP:LISTEN 2>/dev/null
```

确认：

``` text
opencode serve --service
```

确实占用了：

``` text
127.0.0.1:49374
```

杀掉残留进程：

``` bash
kill <PID>
```

或：

``` bash
pkill -f 'opencode serve' 2>/dev/null || true
```

但再次运行 `opencode` 仍然超时。

因此，端口占用只是现象之一，并不是根本问题。

------------------------------------------------------------------------

## 5. standalone 模式仍然 HTTP 503

测试：

``` bash
opencode --standalone
```

出现：

``` text
ClientError: UnexpectedStatus: 503
```

进一步测试：

``` bash
opencode run --standalone "Say hello"
```

仍然：

``` text
Error: UnexpectedStatus: 503
```

同时：

``` bash
opencode service status
```

显示：

``` text
stopped
```

这一步非常重要，因为它证明问题已经不是单纯的 TUI：

``` text
OpenCode 2.0.18
├── ELF 能启动                  OK
├── --version                  OK
├── opencode serve             OK
├── 普通后台 service           异常
├── TUI                        异常
└── standalone agent 请求      HTTP 503
```

因此决定停止继续修补 2.0.18，转而使用旧版本。

------------------------------------------------------------------------

## 6. 尝试通过 upgrade 降级

OpenCode 支持：

``` bash
opencode upgrade --help
```

其中：

``` text
target string    Version to upgrade to (with or without a leading v)
```

尝试：

``` bash
opencode upgrade v1.14.48 --method curl
```

OpenCode正确识别：

``` text
From 2.0.18 -> 1.14.48
```

但失败：

``` text
Error: Version 1.14.48 is not available for linux-x64
```

因此改为手动使用对应版本的 release 二进制。

------------------------------------------------------------------------

## 7. 手动安装 OpenCode 1.14.48

下载并解压旧版本后，在 `/tmp` 直接运行：

``` bash
./opencode --version
```

出现：

``` text
EEXIST: file already exists, mkdir '/tmp/opencode'
Bun v1.3.13 (Linux x64 baseline)
```

### 原因

解压后的二进制本身叫：

``` text
/tmp/opencode
```

而该程序运行时又尝试使用 `/tmp/opencode`
作为目录，因此发生文件/目录同名冲突。

解决办法是把二进制移出 `/tmp`：

``` bash
mv /tmp/opencode ~/.opencode/bin/opencode
chmod +x ~/.opencode/bin/opencode
```

检查：

``` bash
which opencode
opencode --version
```

结果：

``` text
/home/book/.opencode/bin/opencode
1.14.48
```

说明 OpenCode 1.14.48 本体已经能够在 Ubuntu 18.04 / glibc 2.27 上执行。

------------------------------------------------------------------------

## 8. 降级后的数据库迁移冲突

执行：

``` bash
opencode
```

出现大量：

``` text
DrizzleError: Failed to run the query 'CREATE TABLE `project` (...)'
```

涉及：

``` text
config.providers
provider.list
app.agents
config.get
```

### 原因

此前 OpenCode 2.0.18 已经创建并迁移过数据库：

``` text
~/.local/share/opencode/opencode.db
~/.local/share/opencode/opencode.db-shm
~/.local/share/opencode/opencode.db-wal
```

程序降级到了
1.14.48，但数据库没有一起降级，因此旧程序尝试使用新版数据库结构时发生
migration/schema 冲突。

先检查：

``` bash
ls -lah ~/.local/share/opencode
find ~/.local/share/opencode -maxdepth 2 -type f -printf '%p\n'
```

为了避免误删，先整体备份：

``` bash
pkill -f opencode 2>/dev/null || true

mv ~/.local/share/opencode \
   ~/.local/share/opencode.backup-2.0.18
```

然后重新：

``` bash
opencode
```

OpenCode 1.14.48 会自行创建属于自己的数据库。

**结果：成功进入 OpenCode TUI。**

------------------------------------------------------------------------

## 9. OpenCode 成功启动，但 GNOME Terminal 出现乱码

OpenCode 能进入界面后，出现大量类似：

``` text
66;w=1;
1016$p
2027$p
```

以及各种方块、控制字符和布局异常。

最初怀疑 Nerd Font。

检查：

``` bash
fc-list | grep -i "JetBrainsMono.*Nerd" | head
fc-match "JetBrainsMono Nerd Font"
```

结果确认 JetBrainsMono Nerd Font 已正确安装。

GNOME Terminal 中也已经启用了：

``` text
Custom font:
JetBrainsMono Nerd Font Regular
```

因此不是简单的"字体没装"。

------------------------------------------------------------------------

## 10. 确认 GNOME Terminal / VTE 太老

检查：

``` bash
gnome-terminal --version
dpkg -l | grep -E 'gnome-terminal|libvte'
```

结果：

``` text
GNOME Terminal 3.28.2
VTE 0.52.2
```

这是 Ubuntu 18.04 原生终端栈。

结合屏幕中直接显示出来的终端控制序列，判断 OpenCode/OpenTUI
使用了该老版本 VTE 无法完整处理的现代终端能力。

因此不去升级系统 VTE，而是单独安装现代终端模拟器。

------------------------------------------------------------------------

## 11. 安装 kitty 0.35.2

为了兼顾 Ubuntu 18.04 / glibc 2.27，没有直接追最新版，而安装 kitty
0.35.2：

``` bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
    installer=version-0.35.2 launch=n
```

安装目录：

``` text
~/.local/kitty.app
```

验证：

``` bash
~/.local/kitty.app/bin/kitty --version
```

结果：

``` text
kitty 0.35.2 created by Kovid Goyal
```

创建命令软链接：

``` bash
mkdir -p ~/.local/bin

ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/kitten
```

此时：

``` bash
which kitty
```

没有输出，`kitty --version` 也提示 command not found。

------------------------------------------------------------------------

## 12. `~/.local/bin` 不在 PATH

检查：

``` bash
echo "$PATH"
```

发现有：

``` text
/home/book/.opencode/bin
```

但没有：

``` text
/home/book/.local/bin
```

编辑：

``` bash
nano ~/.bashrc
```

加入：

``` bash
export PATH="$HOME/.local/bin:$PATH"
```

重新加载：

``` bash
source ~/.bashrc
hash -r
```

验证：

``` bash
which kitty
kitty --version
```

结果：

``` text
/home/book/.local/bin/kitty
kitty 0.35.2 created by Kovid Goyal
```

------------------------------------------------------------------------

## 13. Kitty 中 OpenCode 正常显示

启动：

``` bash
kitty
```

在新的 Kitty 窗口中确认：

``` bash
echo $TERM
kitty --version
opencode --version
```

其中 `$TERM` 为：

``` text
xterm-kitty
```

然后：

``` bash
cd ~/Desktop/02_dht11_drv_imx6ull_test
opencode
```

OpenCode 的 Logo、界面、文字和布局均能够正常显示。

这基本确认了之前 OpenCode 主界面乱码的根因：

``` text
OpenCode / OpenTUI
        |
        +-- GNOME Terminal 3.28 + VTE 0.52 -> 协议支持不足 -> 乱码
        |
        `-- kitty 0.35.2                  -> TUI 正常显示
```

Kitty 启动它时，父终端仍可能看到：

``` text
[PARSE ERROR] Unsupported screen mode: 2031 (private)
[PARSE ERROR] Unsupported screen mode: 2027 (private)
[PARSE ERROR] Unknown OSC escape code: 66
```

以及：

``` text
Could not move child process into a systemd scope
```

这些反映 kitty 0.35.2、OpenCode/OpenTUI 和 Ubuntu 18.04 老 systemd
之间仍存在部分新特性兼容差异，但实际 OpenCode TUI
已经可以正常显示和使用。

------------------------------------------------------------------------

## 14. 配置 Nerd Font

Kitty 能识别已安装字体：

``` bash
kitty +list-fonts | grep -i "JetBrainsMono Nerd"
```

输出：

``` text
JetBrainsMono Nerd Font
JetBrainsMono Nerd Font Mono
```

可以创建：

``` bash
mkdir -p ~/.config/kitty
nano ~/.config/kitty/kitty.conf
```

例如：

``` text
font_family JetBrainsMono Nerd Font
font_size 12.0
```

如果主要用于终端/TUI，也可以考虑：

``` text
font_family JetBrainsMono Nerd Font Mono
```

------------------------------------------------------------------------

## 15. Kitty 没有出现在 GNOME 应用列表

手动安装 kitty 后，命令行可以启动：

``` bash
kitty
```

但 GNOME Activities 搜索不到真正的 Kitty，只搜到了 100ASK SDK 中名字包含
`kitty` 的普通文件。

原因是手动安装二进制和"注册桌面应用"是两件事。

安装 desktop 文件：

``` bash
mkdir -p ~/.local/share/applications

cp ~/.local/kitty.app/share/applications/kitty.desktop \
   ~/.local/share/applications/
```

检查：

``` bash
desktop-file-validate ~/.local/share/applications/kitty.desktop
```

无输出，说明语法合法。

文件内容为：

``` ini
[Desktop Entry]
Version=1.0
Type=Application
Name=kitty
GenericName=Terminal emulator
Comment=Fast, feature-rich, GPU based terminal
TryExec=kitty
StartupNotify=true
Exec=/home/book/.local/kitty.app/bin/kitty
Icon=kitty
Categories=System;TerminalEmulator;
```

`Exec` 已经是绝对路径，但：

``` ini
TryExec=kitty
```

仍然依赖 GNOME Shell 自己的 PATH。

交互式 Bash 中的：

``` bash
export PATH="$HOME/.local/bin:$PATH"
```

并不意味着已经运行的 GNOME Shell 一定获得了同样的 PATH。

因此改为绝对路径：

``` bash
sed -i \
's|^TryExec=kitty$|TryExec=/home/book/.local/kitty.app/bin/kitty|' \
~/.local/share/applications/kitty.desktop
```

最终关键字段：

``` ini
Name=kitty
TryExec=/home/book/.local/kitty.app/bin/kitty
Exec=/home/book/.local/kitty.app/bin/kitty
Icon=kitty
```

刷新：

``` bash
update-desktop-database ~/.local/share/applications
```

之后 Kitty 成功出现在 GNOME 应用列表中。

------------------------------------------------------------------------

## 16. 清理安装过程中留下的备份

确认 OpenCode 1.14.48 已经可以正常使用后，清理之前保留的 2.0.18 二进制：

``` bash
rm -f ~/.opencode/bin/opencode-2.0.18
```

删除 2.0.18 数据库备份：

``` bash
rm -rf ~/.local/share/opencode.backup-2.0.18
```

删除下载到 `/tmp` 的安装包：

``` bash
rm -f /tmp/opencode-1.14.48.tar.gz
```

还发现：

``` text
~/.opencode/bin/opencode2
```

只有 47 字节。

检查：

``` bash
cat ~/.opencode/bin/opencode2
```

内容：

``` sh
#!/bin/sh
exec "$(dirname "$0")/opencode" "$@"
```

这是一个简单的 wrapper，当前没有必要保留，因此删除：

``` bash
rm ~/.opencode/bin/opencode2
```

最终 OpenCode 二进制目录只需保留：

``` text
~/.opencode/bin/opencode
```

当前数据保留：

``` text
~/.local/share/opencode/
```

------------------------------------------------------------------------

## 17. 最终目录和版本状态

### OpenCode

``` bash
which opencode
opencode --version
```

目标状态：

``` text
/home/book/.opencode/bin/opencode
1.14.48
```

主要目录：

``` text
~/.opencode/bin/opencode
~/.local/share/opencode/
```

### Kitty

``` bash
which kitty
kitty --version
```

目标状态：

``` text
/home/book/.local/bin/kitty
kitty 0.35.2 created by Kovid Goyal
```

实际程序：

``` text
~/.local/kitty.app/bin/kitty
```

软链接：

``` text
~/.local/bin/kitty
~/.local/bin/kitten
```

桌面入口：

``` text
~/.local/share/applications/kitty.desktop
```

### 字体

``` bash
kitty +list-fonts | grep -i "JetBrainsMono Nerd"
```

可识别：

``` text
JetBrainsMono Nerd Font
JetBrainsMono Nerd Font Mono
```

------------------------------------------------------------------------

## 18. 最终使用方式

打开 GNOME Activities：

``` text
kitty
```

启动 Kitty 后：

``` bash
cd ~/Desktop/02_dht11_drv_imx6ull_test
opencode
```

也可以在任意工程目录直接：

``` bash
opencode
```

OpenCode 会以当前目录作为项目上下文。

------------------------------------------------------------------------

## 19. 本次排错中最重要的经验

### 19.1 安装器修改 `.bashrc` 不等于当前 Shell 已更新

修改：

``` text
~/.bashrc
```

后通常需要：

``` bash
source ~/.bashrc
```

或者重新打开终端。

### 19.2 `--version` 能运行不代表整个应用兼容

OpenCode 2.0.18：

``` text
opencode --version    OK
```

但真正启动 Agent 时：

``` text
background service   FAIL
standalone           HTTP 503
```

因此测试复杂 CLI/TUI 程序时，应测试实际工作路径，而不能只看
`--version`。

### 19.3 程序降级时要考虑数据格式降级

本次：

``` text
2.0.18 创建数据库
        ↓
程序降级为 1.14.48
        ↓
仍读取 2.0.18 数据库
        ↓
Drizzle migration 失败
```

解决方法不是继续重装二进制，而是让旧版本使用干净的数据目录。

### 19.4 字体乱码和终端协议乱码是两类问题

如果普通英文正常、只有图标是方块，优先检查 Nerd Font。

如果出现：

``` text
66;w=1
2027$p
OSC
CSI
```

这类内容，则更应该怀疑终端模拟器不支持应用发送的控制序列。

### 19.5 不要为了单个工具升级 Ubuntu 18.04 的 glibc

对于 BSP、交叉编译器、Buildroot、老 SDK 环境：

``` text
保持系统核心运行库稳定
```

通常比运行最新版开发工具更重要。

更合理的策略是：

``` text
固定兼容的应用版本
+
单独安装用户级现代工具
```

而不是替换系统底层组件。

### 19.6 `.desktop` 的环境与 Bash 环境不同

这次：

``` ini
TryExec=kitty
```

在 Bash 中看起来没问题，因为：

``` bash
which kitty
```

能找到 `~/.local/bin/kitty`。

但 GNOME Shell 不一定继承后来在 `.bashrc` 中添加的 PATH。

对这种手动安装到用户目录的软件，使用：

``` ini
TryExec=/home/book/.local/kitty.app/bin/kitty
Exec=/home/book/.local/kitty.app/bin/kitty
```

更稳妥。

------------------------------------------------------------------------

## 20. 当前推荐组合

对于这台 Ubuntu 18.04 开发环境，当前已经验证可工作的组合是：

``` text
Ubuntu 18.04.6 LTS
├── glibc 2.27                  保持系统原状
├── GNOME Terminal 3.28.2       保留，不用于 OpenCode
├── VTE 0.52.2                  保持系统原状
│
├── JetBrainsMono Nerd Font
│
├── kitty 0.35.2
│   └── 用于现代 TUI
│
└── OpenCode 1.14.48
    └── 在 Kitty 中运行
```

核心原则：

**不动 Ubuntu 18.04 的 glibc / VTE 等底层组件，通过固定 OpenCode 与
Kitty 的兼容版本，在用户目录中补齐现代开发工具。**


---

## 21. Kitty 已出现在 GNOME 应用列表，但图标显示错误

完成 `kitty.desktop` 注册后，Kitty 已经能够在 Ubuntu 18.04 的 GNOME Activities 应用列表中正常出现，但图标仍显示为通用的紫色菱形应用图标，而不是 Kitty 自带图标。

当前 `kitty.desktop` 中：

```ini
Icon=kitty
```

这表示 GNOME 会根据图标名称 `kitty`，到当前图标主题以及标准图标搜索目录中查找对应图标。

虽然 Kitty 本体安装在：

```text
~/.local/kitty.app
```

但手动安装方式不一定会把 Kitty 图标安装到 GNOME 默认搜索的用户图标主题目录，因此应用入口可以找到，图标却可能回退为通用图标。

### 21.1 查找 Kitty 自带图标

先检查安装目录：

```bash
find ~/.local/kitty.app -type f \
  \( -iname '*kitty*.png' -o -iname '*kitty*.svg' \)
```

通常可以找到类似：

```text
/home/book/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png
```

实际路径以 `find` 输出为准。

### 21.2 方法一：直接在 desktop 文件中使用绝对图标路径

假设实际图标为：

```text
/home/book/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png
```

可以执行：

```bash
sed -i \
's|^Icon=.*|Icon=/home/book/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|' \
~/.local/share/applications/kitty.desktop
```

检查：

```bash
grep -E '^(Name|TryExec|Exec|Icon)=' \
~/.local/share/applications/kitty.desktop
```

预期：

```ini
Name=kitty
TryExec=/home/book/.local/kitty.app/bin/kitty
Exec=/home/book/.local/kitty.app/bin/kitty
Icon=/home/book/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png
```

刷新桌面应用数据库：

```bash
update-desktop-database ~/.local/share/applications
```

Ubuntu 18.04 默认 Xorg GNOME 会话下，可以按：

```text
Alt + F2
```

输入：

```text
r
```

然后回车，以重新加载 GNOME Shell。

也可以直接注销后重新登录。

这种方式最直接，但 `.desktop` 文件中写死了当前用户 `/home/book` 的绝对路径，可移植性较差。

### 21.3 方法二：将图标安装到用户 hicolor 图标主题（更规范）

更推荐保持：

```ini
Icon=kitty
```

然后把 Kitty 自带图标安装到：

```text
~/.local/share/icons/hicolor/
```

例如对应不同尺寸：

```text
~/.local/share/icons/hicolor/
├── 16x16/apps/kitty.png
├── 32x32/apps/kitty.png
├── 48x48/apps/kitty.png
├── 128x128/apps/kitty.png
└── 256x256/apps/kitty.png
```

这样 GNOME 可以按照标准的 freedesktop 图标主题搜索规则，通过：

```ini
Icon=kitty
```

找到 Kitty 图标。

实际复制命令应根据：

```bash
find ~/.local/kitty.app -type f \
  \( -iname '*kitty*.png' -o -iname '*kitty*.svg' \)
```

得到的真实文件和尺寸决定，不应假设安装包一定包含上述所有尺寸。

安装后可以刷新：

```bash
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor
update-desktop-database ~/.local/share/applications
```

然后重新加载 GNOME Shell或注销再登录。

### 21.4 本问题与前面的应用列表问题的区别

这两个问题属于不同层次：

```text
Kitty 无法出现在应用列表
        |
        +-- kitty.desktop 是否存在
        +-- Exec 是否有效
        `-- TryExec 是否能找到程序

Kitty 已出现但图标错误
        |
        +-- Icon=kitty
        +-- GNOME 图标搜索路径
        `-- hicolor 图标主题中是否存在 kitty 图标
```

因此当前状态已经说明：

```text
.desktop 注册       OK
Exec                OK
TryExec             OK
GNOME 应用发现       OK
图标解析             待完善
```

如果只追求快速修复，可以使用 `Icon=` 的绝对路径；如果希望配置规范、方便长期维护，则应把 Kitty 图标安装到用户级 `hicolor` 图标主题目录，并继续使用：

```ini
Icon=kitty
```
