# Windows 通过 WSL2 读取同一台电脑上的 Fedora Btrfs 硬盘

## 1. 场景说明

电脑中安装有两块硬盘：

- 一块安装 Windows；
- 另一块安装 Fedora Linux。

由于 Fedora 通常使用 **Btrfs** 文件系统，Windows 本身不会像 NTFS 一样直接为该分区分配盘符，因此在 Windows 的资源管理器中无法直接打开 Fedora 的系统分区。

可以利用 **WSL2**：

```
Windows
   │
   │ wsl --mount --bare
   ▼
WSL2 / Ubuntu
   │
   │ mount -t btrfs
   ▼
Fedora Btrfs 分区
   │
   │ \\wsl$\Ubuntu\...
   ▼
Windows 资源管理器
```

Microsoft 官方支持使用 `wsl --mount` 将 Windows 无法直接识别的 Linux 文件系统所在物理磁盘连接到 WSL2；使用 `--bare` 时只连接磁盘，不自动挂载，由 Linux 自己完成后续挂载。

本文优先采用**只读挂载**，适合从 Fedora 中提取文件，同时尽量避免误修改 Linux 系统。

# 2. 前提条件

需要：

1. Windows 11 或支持 `wsl --mount` 的新版 WSL；
2. 已安装 WSL2；
3. 已安装一个 WSL Linux 发行版，例如 Ubuntu；
4. Fedora 位于与 Windows 系统盘不同的物理硬盘；
5. 使用管理员 PowerShell 执行磁盘连接操作。

检查：

```
wsl --status
wsl -l -v
```

例如：

```
Default Distribution: Ubuntu
Default Version: 2

NAME      STATE     VERSION
Ubuntu    Stopped   2
```

重点是：

```
VERSION = 2
```

即使用 WSL2。

# 3. 确认 Fedora 所在物理磁盘

首先不要急着挂载，必须区分 Windows 与 Fedora 所在硬盘。

以**管理员身份打开 PowerShell**：

```
Get-Disk | Format-Table Number,FriendlyName,PartitionStyle,Size,OperationalStatus
```

例如：

```
Number FriendlyName          PartitionStyle Size
------ ------------          -------------- ----
1      YMTC PC411-1TB-B      GPT            1TB
0      ZHITAI TiPlus7100 1TB GPT            1TB
```

继续：

```
Get-Partition | Format-Table DiskNumber,PartitionNumber,DriveLetter,Type,Size
```

例如：

```
DiskNumber PartitionNumber DriveLetter Type       Size
---------- --------------- ----------- ---------- ----
1          1                           Reserved
1          2               C           Basic      302GB
1          3               D           Basic      650GB
1          4                           System
1          5                           Recovery

0          1                           System      572MB
0          2                           Unknown     1.9GB
0          3                           Unknown     951GB
```

由此可以判断：

```
Disk 1 → Windows
Disk 0 → Fedora
```

Windows 将 Btrfs 等无法直接识别的 Linux 文件系统显示为 `Unknown` 是正常现象。

因此 Fedora 所在物理磁盘为：

```
\\.\PHYSICALDRIVE0
```

**这里的数字必须根据自己的** `**Get-Disk**` **结果确定，不要直接照抄。**

# 4. 检查 WSL 内核是否支持 Btrfs

在管理员 PowerShell 中执行：

```
wsl -d Ubuntu -u root -- modprobe btrfs
```

然后：

```
wsl -d Ubuntu -- cat /proc/filesystems
```

如果输出中存在：

```
btrfs
```

说明当前 WSL Linux 内核能够挂载 Btrfs。

例如：

```
ext4
vfat
xfs
btrfs
9p
```

即可继续。

需要注意：

```
btrfs-progs
```

与：

```
Linux Kernel Btrfs Driver
```

不是一回事。

`btrfs-progs` 提供 `btrfs` 等用户空间管理工具，而真正挂载 Btrfs 需要 Linux 内核本身支持 Btrfs。

# 5. 将 Fedora 物理磁盘连接给 WSL2

管理员 PowerShell：

```
wsl --mount \\.\PHYSICALDRIVE0 --bare
```

例如：

```
The operation completed successfully.
```

`--bare` 的含义是：

> 将整个物理磁盘连接到 WSL2，但不自动挂载其中的文件系统。

这特别适合 Btrfs，因为可以进入 Ubuntu 后自己指定 Btrfs 的 subvolume 和只读等挂载选项。Microsoft 官方也明确提供了这种使用方式。

# 6. 在 WSL 中识别 Fedora 分区

先查看：

```
wsl -d Ubuntu -- lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS
```

例如：

```
NAME      SIZE FSTYPE LABEL          UUID
sdd     953.9G
├─sdd1    572M vfat
├─sdd2    1.9G ext4
└─sdd3  951.4G btrfs  fedora_fedora f6bf8fdb-...
```

这就可以确定：

```
/dev/sdd1 → Fedora EFI 分区
/dev/sdd2 → Fedora /boot
/dev/sdd3 → Fedora Btrfs 主分区
```

Fedora 默认 Btrfs 安装方案通常包含独立的 ext4 `/boot`，以及一个包含 `root` 和 `home` 子卷的 Btrfs 文件系统；`root` 和 `home` 分别挂载为 `/` 和 `/home`。

# 7. 不要假设 `/dev/sdX` 永远不变

这是实际操作中非常重要的一点。

例如第一次执行：

```
wsl -d Ubuntu -- lsblk
```

Fedora 磁盘可能显示：

```
/dev/sde3
```

但随后执行：

```
wsl -d Ubuntu
```

进入 Ubuntu 后重新：

```
lsblk
```

可能变成：

```
/dev/sdd3
```

因此：

**不要把** `**/dev/sdd3**`**、**`**/dev/sde3**` **等设备名当作永久固定名称。**

每次连接物理磁盘后重新执行：

```
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS
```

再确定设备。

更稳妥的方法是记录 Btrfs UUID，例如：

```
f6bf8fdb-eca5-4dc2-8aa8-cbc84054ea71
```

之后可以使用：

```
/dev/disk/by-uuid/f6bf8fdb-eca5-4dc2-8aa8-cbc84054ea71
```

代替容易变化的：

```
/dev/sdd3
```

# 8. 进入 Ubuntu

管理员 PowerShell：

```
wsl -d Ubuntu
```

再次确认：

```
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS
```

找到：

```
FSTYPE = btrfs
LABEL  = fedora_fedora
```

对应的分区。

例如本次实际为：

```
/dev/sdd3
```

# 9. 创建挂载目录

执行：

```
sudo mkdir -p /mnt/fedora
```

`-p` 表示如果目录已经存在也不会因此报错。

此时：

```
/mnt/fedora
```

只是一个普通空目录。

# 10. 只读挂载 Fedora Btrfs 顶层

假设实际 Fedora 分区为：

```
/dev/sdd3
```

执行：

```
sudo mount -t btrfs -o ro,subvolid=5 /dev/sdd3 /mnt/fedora
```

其中：

```
-t btrfs
```

明确指定文件系统为 Btrfs。

```
-o ro
```

表示只读挂载。

```
subvolid=5
```

表示挂载 Btrfs 的顶层 subvolume，而不是直接进入 Fedora 的 `root` 子卷。

成功时 `mount` 通常**不会输出任何内容**。

检查：

```
ls -lah /mnt/fedora
```

可能得到：

```
drwxr-xr-x  home
dr-xr-xr-x  root
```

说明挂载成功。

# 11. 理解 Fedora 的 root 和 home

此时：

```
/mnt/fedora
├── root
└── home
```

这里的：

```
/mnt/fedora/root
```

是名为 `root` 的 **Btrfs 子卷**，相当于 Fedora 正常运行时的：

```
/
```

所以：

```
/mnt/fedora/root/etc
```

相当于 Fedora 的：

```
/etc
```

而：

```
/mnt/fedora/root/usr
```

相当于：

```
/usr
```

注意不要把这个 `root` 与 root 用户家目录混淆。

Fedora root 用户真正的：

```
/root
```

对应：

```
/mnt/fedora/root/root
```

另一方面：

```
/mnt/fedora/home
```

就是 Fedora 正常运行时的：

```
/home
```

例如 Fedora 用户名为：

```
y
```

那么个人目录就是：

```
/mnt/fedora/home/y
```

Fedora 官方 Btrfs 默认方案本身就是使用 `root` 和 `home` 两个子卷分别对应 `/` 和 `/home`。

# 12. 查看 Fedora 个人文件

例如：

```
ls -lah /mnt/fedora/home
```

如果出现：

```
y
```

继续：

```
ls -lah /mnt/fedora/home/y
```

即可看到：

```
Desktop
Documents
Downloads
Pictures
.config
.local
...
```

也可以检查所有 Btrfs 子卷：

```
sudo btrfs subvolume list /mnt/fedora
```

# 13. 从 Windows 资源管理器访问

保持 WSL 运行。

在 Windows 文件资源管理器地址栏输入：

```
\\wsl$\Ubuntu\mnt\fedora
```

即可浏览整个 Fedora Btrfs 顶层。

如果只想访问 Fedora 用户文件：

```
\\wsl$\Ubuntu\mnt\fedora\home
```

或者：

```
\\wsl$\Ubuntu\mnt\fedora\home\y
```

Microsoft 官方也支持通过：

```
\\wsl$\<Distro>\<Mountpoint>
```

从 Windows 访问 WSL 中挂载的 Linux 文件。

于是整个访问路径实际上是：

```
Windows 资源管理器
        ↓
\\wsl$\Ubuntu
        ↓
WSL2 Ubuntu
        ↓
/mnt/fedora
        ↓
/dev/sdd3
        ↓
Fedora Btrfs
```

# 14. 为什么推荐只读挂载

本文使用：

```
-o ro
```

而不是：

```
-o rw
```

因为如果目的只是：

- 找回 Fedora 文件；
- 把文件复制到 Windows；
- 查看 Fedora 配置；
- 备份 `.config`；
- 读取项目代码；
- 读取 Documents、Downloads 等；

完全没有必要修改 Fedora 文件系统。

只读方式可以避免：

```
Windows/WSL
    ↓
误修改 Fedora 权限、配置或系统文件
    ↓
Fedora 下次启动出现问题
```

因此建议：

> **读取和备份 Fedora 数据时始终优先使用** `**ro**`**。**

# 15. 如果确实需要读写

首先确保 Fedora 已经**完全关机**，而不是正在运行、休眠或被其他环境挂载。

先卸载：

```
cd ~
sudo umount /mnt/fedora
```

然后：

```
sudo mount -t btrfs -o rw,subvolid=5 /dev/sdd3 /mnt/fedora
```

但除非确实需要，否则不建议这么做。

尤其不要因为 Windows 访问时出现权限问题，就直接执行：

```
sudo chmod -R 777 /mnt/fedora
```

或者：

```
sudo chown -R ...
```

这种操作会大规模改变 Fedora 原本的 Linux 权限和所有权。

# 16. 推荐使用 UUID 挂载

因为 `/dev/sdX` 可能变化，所以长期使用时推荐 UUID。

先：

```
lsblk -f
```

或者：

```
sudo blkid
```

假设 Fedora Btrfs UUID 为：

```
f6bf8fdb-eca5-4dc2-8aa8-cbc84054ea71
```

检查：

```
ls -l /dev/disk/by-uuid/
```

之后可以直接：

```
sudo mount -t btrfs \
  -o ro,subvolid=5 \
  /dev/disk/by-uuid/f6bf8fdb-eca5-4dc2-8aa8-cbc84054ea71 \
  /mnt/fedora
```

这样即使：

```
sdd3 → sde3
```

也不需要修改命令。

# 17. 使用完毕后正确卸载

不要直接关掉 WSL。

首先关闭正在访问：

```
\\wsl$\Ubuntu\mnt\fedora
```

的：

- Windows 资源管理器窗口；
- VS Code；
- 编辑器；
- 终端；
- 其他程序。

然后 Ubuntu 中：

```
cd ~
sudo umount /mnt/fedora
```

如果成功，通常没有输出。

退出：

```
exit
```

回到管理员 PowerShell：

```
wsl --unmount \\.\PHYSICALDRIVE0
```

Microsoft 官方也使用：

```
wsl --unmount <DiskPath>
```

来从 WSL 分离物理磁盘。

# 18. 常见问题

## 问题 1：`special device /dev/sde3 does not exist`

例如：

```
mount: /mnt/fedora: special device /dev/sde3 does not exist.
```

先：

```
lsblk -f
```

很可能设备名称已经从：

```
/dev/sde3
```

变成：

```
/dev/sdd3
```

使用当前实际设备名即可。

长期解决办法是使用 UUID。

## 问题 2：Windows 显示 Fedora 分区为 Unknown

正常。

Windows 本身不能像 NTFS 那样直接处理 Fedora Btrfs，因此：

```
Get-Partition
```

可能显示：

```
Unknown
```

这并不意味着分区损坏。

进入 WSL 后：

```
lsblk -f
```

能够正确显示：

```
btrfs
fedora_fedora
```

即可。

## 问题 3：`wsl --mount` 成功，但 `/mnt` 中没有 Fedora

正常。

因为使用的是：

```
wsl --mount \\.\PHYSICALDRIVE0 --bare
```

`--bare` 的目的就是：

> 只把块设备交给 WSL，不自动挂载。

Microsoft 官方说明也是如此。

需要自己：

```
sudo mkdir -p /mnt/fedora
sudo mount ...
```

## 问题 4：怎么确认当前是只读？

执行：

```
findmnt /mnt/fedora
```

查看挂载参数中是否存在：

```
ro
```

也可以：

```
mount | grep '/mnt/fedora'
```

## 问题 5：Windows 资源管理器从哪里进入？

使用：

```
\\wsl$\Ubuntu\mnt\fedora
```

而不是寻找新的：

```
E:
F:
G:
```

盘符。

Windows 实际上是通过 WSL 文件共享层访问 Ubuntu 中已经挂载的 Fedora 文件系统。

# 19. 完整操作流程速查

## 管理员 PowerShell

确定硬盘：

```
Get-Disk | Format-Table Number,FriendlyName,PartitionStyle,Size,OperationalStatus

Get-Partition | Format-Table DiskNumber,PartitionNumber,DriveLetter,Type,Size
```

确认 WSL：

```
wsl --status
wsl -l -v
```

确认 Btrfs：

```
wsl -d Ubuntu -u root -- modprobe btrfs
wsl -d Ubuntu -- cat /proc/filesystems
```

连接 Fedora 硬盘：

```
wsl --mount \\.\PHYSICALDRIVE0 --bare
```

进入 Ubuntu：

```
wsl -d Ubuntu
```

## Ubuntu

重新识别实际设备：

```
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS
```

创建挂载点：

```
sudo mkdir -p /mnt/fedora
```

推荐使用 UUID 只读挂载：

```
sudo mount -t btrfs \
  -o ro,subvolid=5 \
  /dev/disk/by-uuid/<Fedora-Btrfs-UUID> \
  /mnt/fedora
```

检查：

```
ls -lah /mnt/fedora
```

查看用户：

```
ls -lah /mnt/fedora/home
```

确认挂载：

```
findmnt /mnt/fedora
```

## Windows 资源管理器

输入：

```
\\wsl$\Ubuntu\mnt\fedora
```

或者直接：

```
\\wsl$\Ubuntu\mnt\fedora\home\<Fedora用户名>
```

## 使用结束

Ubuntu：

```
cd ~
sudo umount /mnt/fedora
exit
```

管理员 PowerShell：

```
wsl --unmount \\.\PHYSICALDRIVE0
```

# 20. 最终原理

整个方案可以概括为：

```
Fedora 所在物理硬盘
        │
        │ Windows 无法原生读取 Btrfs
        ▼
wsl --mount PHYSICALDRIVE --bare
        │
        │ 将整个物理磁盘交给 WSL2
        ▼
Ubuntu / Linux Kernel
        │
        │ Linux 原生 Btrfs 驱动
        ▼
mount -t btrfs -o ro,subvolid=5
        │
        ▼
/mnt/fedora
        │
        │ WSL 文件共享
        ▼
\\wsl$\Ubuntu\mnt\fedora
        │
        ▼
Windows 资源管理器
```

因此，**并不是 Windows 本身突然获得了读取 Btrfs 的能力**。

真正读取 Btrfs 的仍然是：

```
WSL2 Linux 内核
```

Windows 只是通过：

```
\\wsl$
```

访问 WSL 已经读取并挂载好的 Linux 文件系统。

对于 Windows + Fedora 双硬盘双系统，这是一个不需要额外 Windows Btrfs 驱动、并且可以使用只读方式降低误操作风险的实用方案。