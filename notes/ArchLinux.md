




[[Linux代理配置]]


### pacman安装卸载软件
```shell
sudo pacman -S hyprland kitty fuzzel firefox wqy-zenhei
sudo pacman -Rns hyprland kitty fuzzel firefox wqy-zenhei
pacman -Qdt
sudo pacman -Rns $(pacman -Qdtq)

ls ~/.config/hypr
ls ~/.config/kitty
ls ~/.config/fuzzel

rm -rf ~/.config/hypr
rm -rf ~/.config/kitty
rm -rf ~/.config/fuzzel
```







# Arch Linux手动安装
## live环境

### 确认是 UEFI 固件

```shell
cat /sys/firmware/efi/fw_platform_size
```
> `cat` 命令将文件内容打印在终端。
> `/sys/firmware/efi/fw_platform_size` 这是一个文件的绝对路径。

如果输出 `64`，说明主板是 64 位 x64 UEFI 固件；如果输出 `32`，说明是 32 位 UEFI；如果提示 `No such file or directory` 没有文件或目录，说明是 BIOS。本文只涉及 x64 UEFI 情况下安装，如果你不是的话安装引导的步骤会不一样，可以查阅[ArchWiki GRUB](https://wiki.archlinux.org/title/GRUB#GUID_Partition_Table_\(GPT\)_specific_instructions)。
### 连接网络
有线网自动连接，还可以用数据线分享手机的网络。
确认网络连接使用：
```shell
ip a #查看网络连接信息，如果出现了紫色的 ip 地址说明成功连接
ping bilibili.com #确认网络正常
```
Ctrl+C 可以中止正在运行的命令。
- 使用`iwctl` 命令行工具连接 wifi（此工具由 `iwd` 提供）
    1. 启动
        ```shell
        iwctl
        ```
        此时会进入 iwctl，提示符会产生变化。
    2. 连接
        ```
        device list #列出设备
        station wlan0 scan #扫描网络
        station wlan0 get-networks #列出所有扫描的wifi
        station wlan0 connect 【此处是你的wifi名字（不能是中文）】
        ```
    3. 退出 iwctl
        ```shell
        exit
        ```
[[Linux网络相关工具]]

### Reflector 自动设置镜像源
用 `reflector` 配置最快最新的镜像源，大幅提高软件下载速度。
```shell
reflector -p https -a 12 -c cn --v --sort rate --save /etc/pacman.d/mirrorlist
reflector -p https -c cn --v --sort rate --save /etc/pacman.d/mirrorlist
# -p（protocol） https 指定 https 协议的链接
# -a（age） 12 指定最近 12 小时更新过的源
# -c（country） cn 指定国家为中国（可以增加邻国）
# --v（verbose） 过程可视化
# --sort rate 按照下载速度排序（经过前面几道筛选，镜像源通常已经足够稳定，所以这里直接按照速度排序即可）
# --save /etc/pacman.d/mirrorlist 将结果保存到 /etc/pacman.d/mirrorlist
```
然后同步软件列表数据。
```shell
pacman -Sy
```
### 远程控制SSH
[[Linux SSH密钥登陆配置]]
### 确认开启了 NTP（网络时间协议）
运行 `timedatectl`，应该在输出看到 NTP 已经开启，否则在安装时可能会出现验证相关的报错：
```shell
NTP service: active
```
手动开启使用：
```shell
timedatectl set-ntp true
```

### 硬盘分区/btrfs子卷
==分区==
```shell
lsblk -pf  #查看当前分区情况
fdisk -l /dev/想要查询详细情况的硬盘  #小写字母l，查看详细分区信息
cfdisk /dev/nvme0n1 #选择自己要使用的硬盘进行分区

# 完成分区和类型选择后格式化硬盘创建文件系统
lsblk -pf #再次查看分区情况
fdisk -l /dev/想要查询详细情况的硬盘  #小写字母l，查看详细分区信息
mkfs.fat -F 32 /dev/nvme0n1p1（EFI 分区名）
mkfs.btrfs /dev/nvme0n1p2（根分区名）
#加上 -f 参数可以强制格式化
```
1. 确保硬盘为GPT分区表
2. EFI分区分512MB分区类型选择EFI System(如果类型列表没有EFI System说明不是GPT分区表)
3. 其余全部分为一个分区,类型为linux filesystem
==子卷==
```shell
mount -t btrfs /dev/nvme0n1p2（根分区名） /mnt #挂载btrfs的那块磁盘
#创建子卷
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap #如果你的内存大于等于 16G 且不需要休眠到硬盘功能，不做大型项目的话跳过这个
btrfs subvolume list /mnt
umount /mnt
```
==正式挂载==
```shell
#挂载root子卷
mount -t btrfs -o subvol=/@,compress=zstd /dev/nvme0n1p2 /mnt
#挂载home子卷
mount --mkdir -t btrfs -o subvol=/@home,compress=zstd /dev/nvme0n1p2 /mnt/home
#挂载swap子卷
mount --mkdir -t btrfs -o subvol=/@swap,compress=zstd /dev/nvme0n1p2 /mnt/swap
#挂载EFI分区
mount --mkdir /dev/nvme0n1p1 /mnt/efi
#复查挂载情况
df -h
```
### 安装系统
`pacstrap` 是 Arch Linux 安装环境中提供的一个脚本。
将基础软件包、内核以及其他必要的系统组件安装到你指定的挂载目录中（通常是新硬盘的分区），从而构建出一个最基本的、可运行的 Linux 系统骨架。
```
从 Arch 软件仓库
       ↓
下载软件包
       ↓
安装到指定目录
       ↓
形成一个新的 Arch Linux 系统
```
```shell
pacstrap -K /mnt base linux linux-firmware btrfs-progs networkmanager vim sudo amd-ucode

# -K 初始化密钥
# base 基本包
# linux是内核，可以更换
# linux-firmware是固件
# btrfs-progs是 Btrfs 文件系统的管理工具
# networkmanager 是联网用的，是各个桌面环境标配的联网工具
# vim 是文本编辑器，也可以换成别的，比如 nano、neovim
# sudo 和权限管理有关
# amd-ucode 是微码，用来修复和优化 CPU，Intel 用户安装 intel-ucode
```

### 硬盘swap交换空间
如果内存大于等于 16G 且不需要休眠到硬盘功能，不做大型项目的话跳过硬盘 Swap，后面会配置更适合现代设备的内存 Swap（ZRAM）

### 生成fstab文件
`genfstab` 是 Arch Linux 及其衍生发行版在安装过程中使用的一个脚本工具，它的主要作用是自动生成 `/etc/fstab`（文件系统挂载表）文件。系统会根据 fstab 中的内容自动进行挂载。
```shell
genfstab -U /mnt > /mnt/etc/fstab
# -U 用 UUID 指定分区
```

## change root
> [!summary]+
在系统异常时即可通过live环境和chroot环境对系统进行修复,live环境中的修改是通过Cow将(Copy-on-Write)层做隔离来保存在内存的,chroot的修改是保存在硬盘上的,将各个分区分别挂载后即可进入chroot
### 正式进入系统
```shell
arch-chroot /mnt 
```
### 设置时区和时间
设置时区：
```shell
timedatectl set-timezone Asia/Shanghai
```
同步硬件时间：
```shell
hwclock --systohc
```
除了 `timedatectl` 命令，还可以手动创建链接。
```shell
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# ln 是 link 的缩写
# -s 代表跨文件系统的软链接
# -f 代表强制执行
```
### 本地化设置(设置系统底层为en_US.UTF-8)
[[Linux中文环境及中文输入法#本地化设置(设置系统底层为en_US.UTF-8)]]
### 设置主机名
```shell
vim /etc/hostname
```
### 设置 root 密码
```shell
passwd
```
### 安装引导程序
这是 UEFI 引导的安装方式，如果你是 BIOS 设备请看 ArchWiki 的 GRUB 页面。
根据 ESP 挂载点和个人需求的不同，Bootloader 的选择也会不同。这里安装最常用的 `grub`，采用的是"ESP 挂载点为 `/efi` 且 `grub` 装进 /boot/grub"的方案。
1. 安装必要的包
```shell
pacman -S grub efibootmgr os-prober fuse3
```
2. 安装引导
```shell
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=ARCH
```
> `grub-install` 安装 GRUB；

> `--target` 指定架构；

> `--efi-directory` 指定 ESP 位置；

> `--boot-directory` 可以指定 GRUB 的安装目录，如果不写的话就是 /boot/grub

> `--bootloader-id` 取一个启动项名字；

上面这段命令在 `/efi/EFI/ARCH` 目录生成 `grubx64.efi` 文件，同时在主板的存储芯片（NVRAM）中生成对应的启动项。efibootmgr能修改主板上的NVRAM的启动项
3. 安装回退引导(非必要不选择)
> [!note]-
> 当主板找不到 NVRAM 中记录的启动文件时，会尝试从`回退启动文件`启动系统，该启动文件所在路径被称为`可移动媒体启动路径`，通常是 `ESP/EFI/BOOT/BOOTx64.EFI`。`ESP`指代 ESP 的挂载点，在本文中是 `/efi`
> ```shell
> grub-install --target=x86_64-efi --efi-directory=/efi --removable --no-nvram
> ```
> `--removable` 将引导安装至回退路径
> `--no-nvram` 不记录进主板的存储芯片中

4. 编辑GRUB的源文件
```shell
vim /etc/default/grub
```
这是生成 GRUB 的配置文件时需要用到的东西。
- 启动项记忆功能
  `GRUB_DEFAULT=0` 改成 `=saved`，再取消 `GRUB_SAVEDEFAULT=true` 的注释。
- 显示开机日志
  `GRUB_CMDLINE_LINUX_DEFAULT` 里面去掉 `quiet` 以显示开机日志。再把 `loglevel` 日志等级设置为 5。`loglevel` 共 8 级，5 级是一个信息量的平衡点。
- 禁用watchdog
  `GRUB_CMDLINE_LINUX_DEFAULT` 里添加 `nowatchdog` 以及 `modprobe.blacklist=sp5100_tco`。Intel CPU 用户把 `sp5100_tco` 换成 `iTCO_wdt`。
watchdog 的目的简单来说是在系统死机的时候自动重启系统。对个人用户来说没有意义，禁用以节省系统资源、提高开机和关机速度。
- 允许使用os-prober搜索其他操作系统
取消最后一行 `GRUB_DISABLE_OS_PROBER=false` 的注释。
5. 生成启动流程grub.cfg
```
grub-mkconfig -o /boot/grub/grub.cfg
```
6. 初始化 Btrfs 环境块
通常环境变量会存储在 `/boot/grub/grubenv` 中，这与`启动项记忆`等实用功能相关，但 Btrfs 文件系统的特殊性导致了写入异常。从 GRUB 2.14 版本开始，可以初始化 Btrfs Header 中的部分区域用于 `grubenv` 相关功能。
```
grub-editenv - set ok=1

# grub-editenv 编辑 grubenv
# 短横杠代表 /boot/grub/grubenv 
# set ok=1 这里随意写了点东西初始化环境快
```
可以使用如下命令验证
```
grub-editenv - list
```
应该会看到类似下面这样的输出
```
env_block=512+1
ok=1
```
> 注意，如果你使用 LVM、RAID 或 encryption 则不适用这个方法
### ZRAM
ZRAM 将内存的部分空间用作交换空间
1. 安装 zram-generator
    ```shell
    pacman -S zram-generator
    ```
2. 编辑配置文件
    ```shell
    vim /etc/systemd/zram-generator.conf
    ```
    
    ```ini
    [zram0]
    zram-size = ram
    compression-algorithm = zstd
    ```

    `zram-size` 设置最多存储多少数据，注意这里设置的是压缩之前的大小。
    `compression-algorithm` 设置使用 zstd 算法。
3. 禁用 zswap
    zswap 是 Swap 的缓存。需要交换的数据在存入交换空间之前会先被 zswap 压缩后暂时放进内存里。和 ZRAM 功能重复且引入了复杂性，故禁用。
    ```shell
    vim /etc/default/grub
    ```
    在 `GRUB_CMDLINE_LINUX_DEFAULT=""` 里写入 `zswap.enabled=0`。
    ```ini
    GRUB_CMDLINE_LINUX_DEFAULT="... zswap.enabled=0 ..."
    ```
4. 重新生成 GRUB 的配置文件
    ```shell
    grub-mkconfig -o /boot/grub/grub.cfg
    ```
### 启用网络服务
开启新系统的 NetworkManager 服务，注意大小写。
```shell
systemctl enable NetworkManager
```
- 可选：替换网络后端为 `iwd(它主要负责无线连接这一层)`
    NetworkManager 的无线网默认后端是 wpa_supplicant，可以更换为更现代的 iwd。

### 退出 chroot
```shell
exit
```
此时就回到了 Live 环境，可以注意到提示符的变化。
### 重启电脑
```shell
reboot
```
此时会自动取消所有的挂载。
如果 U 盘没拔掉的话记得拔掉。
## 正式进入系统

### 选择 BIOS 启动项
通常默认就是刚刚安装的 Arch，如果不是的话选择一下启动项。有的电脑的启动项可能埋在子菜单里，例如 BBS 菜单什么的，仔细找一下。
如果没有出现 Arch Linux 的启动项，看这个页面：[ArchWiki GRUB](https://wiki.archlinux.org/title/GRUB)。

### 登录 root 账户
用户名为 root，密码刚刚设置过了。
### 连接网络
1. 验证是否有网
    ```shell
    ip a
    ping bilibili.com
    ```
2. 连接 wifi
    ```shell
    nmtui
    ```
    `nmtui` 是 NetworkManager 提供的 TUI（终端用户交互程序）。
    - 选择 activate a connection
    - 选择自己的 wifi 进行连接
    - esc 退出
    - Ctrl+L 或者 `clear` 清屏
### 国际惯例一下
```shell
pacman -S fastfetch lolcat cmatrix
fastfetch
fastfetch | lolcat
cmatrix
cmatrix | lolcat
cmatrix -r
```

# 安装桌面环境前准备

## 设置全局默认文本编辑器
通过 `EDITOR` 环境变量设置默认编辑器。如果不设置的话有些程序会默认调用 `vi` 编辑器。Arch 默认是没有安装 `vi` 的，会报错。
```shell
sudo vim /etc/environment
```
```shell
EDITOR=vim

# 如果使用neovim的话填入nvim，nano填入nano
```
由于是全局变量，需要 `exit` 注销后重新登录才能生效。
```
exit
```
## 创建普通用户
很多软件会拒绝在 root 权限下运行，所以普通用户是必须的。
1. 新建用户
    ```
    useradd -mG wheel 你的用户名
    ```
    > `-m` 代表创建用户的时候创建 `home` 目录。
    > `-G` 代表设置组。
2. 设置密码
    ```
    passwd 你的用户名
    ```
3. 编辑权限
    ```
    visudo
    ```
    > 此时编辑的文件本体是 `/etc/sudoers`，`visudo`是在有安全机制的情况下进行编辑。
    搜索 `wheel`，取消注释。
    ```
    %wheel ALL=(ALL:ALL) ALL
    ```
4. 退出 root 使用普通用户登录
## 开启32位源
运行 Windows 软件通常需要各种 32 位的依赖，想玩游戏的话 Steam 客户端也在 32 位源里，所以建议开启 32 位源。
1. 编辑 pacman 配置文件
    ```
    sudo vim /etc/pacman.conf
    ```
    去掉 `[multilib]` 两行的注释。
    ```
    [multilib]
    Include = /etc/pacman.d/mirrorlist
    ```
2. 同步数据库
    ```
    sudo pacman -Syu
    ```
## archlinuxcn源
archlinuxcn 源是由 archlinuxcn 维护的软件仓库，可以丰富我们安装软件的手段。
1. 编辑 pacman 配置文件添加 archlinuxcn 源
    ```
    sudo vim /etc/pacman.conf
    ```
2. 文件底部写入
    ```
    [archlinuxcn]
    Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
    Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
    ```
3. 同步数据库并安装 archlinuxcn 密钥
    ```
    sudo pacman -Sy archlinuxcn-keyring
    sudo pacman -Syu
    ```
## AUR助手
> [ArchWiki AUR Helpers](https://wiki.archlinux.org/title/AUR_helpers)
AUR 是 Arch 最强大的软件仓库。这个仓库里通常只存放软件的`PKGBUILD`，可以将其理解为一个自动化安装脚本。通常的流程是从 AUR 上拉取`PKGBUILD`，然后`makepkg -si`打包软件，再用`pacman -U`安装，但这太过繁琐。通过社区做好的 AUR 助手可以更方便地从 AUR 安装软件。archlinuxcn 上有编译好的版本，可以直接从 archlinuxcn 安装。

```
sudo pacman -S --needed base-devel yay paru
```

> `base-devel` 是编译软件时必须的；`yay` 和 `paru` 都是常用的助手，任选其一，也可以都装。

## 字体
通常安装以下字体包：
```shell
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd
```

> `noto-fonts` 包含大部分外文字体。

> `noto-fonts-cjk` 最常用的中日韩字体，但是因为同时包含中日韩，所以不正确设置系统字体的话会出现中文以日文的字体显示之类问题。有关 `fontconfig 字体设置` 的内容可以看。

> `noto-fonts-emoji` emoji 表情。

> `ttf-jetbrains-mono-nerd` 最常用的等宽字体，用于终端字体显示。`nerd` 代表包含了字符字体。






## 快照和系统维护






# 桌面
主要分为以下两个大类
- Desktop Environment 桌面环境
    
    简称 DE。这是传统意义上的桌面环境，提供 Windows 和 macOS 那样完整的桌面体验。
    
    代表：GNOME、KDE Plasma
    
- Window Manager 窗口管理器
    
    Wayland 下叫 Wayland Compositor（Wayland 合成器），为了方便以下统称 WM。只提供基础的窗口绘制、布局、动画效果等功能。以键盘和终端操作为主。大多数 WM 默认使用自动平铺（后文称`平铺式窗口管理器`），窗口会按照预设的逻辑自动调整大小，不同的 WM 的布局逻辑略有不同。现代的 WM 都同时支持平铺式和传统桌面那样的堆叠式。平铺式窗口管理器常常会导致软件的弹出窗口出现异常，兼容性不如堆叠式。
    
    代表：Hyprland、Niri、Sway


## niri+自行搭建其他组件
### 更换 shell 为 fish
> [!hint]- 可选
> 由于会频繁用到命令行，有一个便利的 shell 会方便很多。
> ```
> sudo pacman -S fish
> ```
### 安装niri及部分工具
```shell
sudo pacman -S --need niri xwayland-satellite xdg-desktop-portal-gnome fuzzel alacritty firefox wdisplays libnotify mako polkit-gnome
# alacritty 可以换成其他终端仿真器，例如 Kitty / Foot / Ghostty
# 出现选项选择 pipewire-jack
# 字体选择谷歌开源字体noto-fonts
```
> [!note]+
> `niri` 本体,niri会话时作为system服务启动的,可以在其配置文件中顺带其他其他相关的配套的组件,通过修改niri配置文件会更方便；
> `xwayland-satellite` 提供 Xwayland 功能，Xwayland 是在 Wayland 上运行 X11 软件的兼容环境；
> `xdg-desktop-portal-gnome` 是 Niri 推荐使用的桌面门户，提供文件选择、屏幕分享等功能；
> `fuzzel` 是 Niri 推荐的程序启动器；
> `alacritty` 是 Niri 默认的终端仿真器；
> `firefox` 是 Linux 上好用的浏览器；
> `wdisplays` 用于临时修改显示设置(可选)；
> libnotify让应用程序能够发送桌面通知
> `mako` 精简好用的通知服务。
> `polkit-gnome` 需要管理员权限的软件会通过 polkit 询问权限，没有 polkit 的话就无法启动，例如 `btrfs-assistant`。

允许niri-session打开niri会话,如果有显示管理器的话在显示管理器切换会话(第一次运行时会默认生成配置文件~/.config/niri/config.kdl)
[[niri配置文件config.kdl]]
### 设置为中文显示/安装中文输入法
[[Linux中文环境及中文输入法#niri配置文件设置用户环境为中文]]
安装:[[Linux中文环境及中文输入法#Fcitx5相关配置总结]]
在niri中的简单配置:[[Linux中文环境及中文输入法#niri关于输入法相关配置]]
常用的输入法框架有 Fcitx5 和 IBus。GNOME 桌面和 IBus 的兼容会更好，配置过程也更简单，所以推荐使用 IBUS。除 GNOME 外的其他桌面和合成器都推荐使用 Fcitx5。 



# niri+dms桌面安装

https://niri-wm.github.io/niri/Getting-Started.html#quick-start

# 登录管理器

> [!note]+ 显示管理器DM补充(对一些定义的解析)
> 显示管理器（Display Manager，DM）可以理解成“图形化登录界面 + 图形会话启动器”。
> 作用:开机后显示登录界面,用户名/密码认证,选择用户,选择要进入的桌面环境或窗口管理器,启动 X11 或 Wayland 图形会话, 注销、切换用户、自动登录等
> 
> 启动 X11 或 Wayland 图形会话通常由哪些进程完成?
> X11：通常由 Xorg 这个服务器进程提供图形服务器。
> Wayland：通常由 Compositor 进程同时承担显示服务器/合成器等核心职责。
> system->display manager->greeter->xorg(图形会话)
> system->display manager->greeter
> 
> ***通俗而言将整个登录页面称为显示管理器,但细分如下***
> greetd      = Display Manager管理登录
> tuigreet    = Greeter负责显示登录界面的那个程序
> Niri        = Wayland compositor合成器

