
### lsblk
用于列出系统中所有可用的块设备信息及其分区结构
```
lsblk # 列出所有块设备
lsblk -fp #以键值对格式输出显示文件系统信息
```


|列名|说明|
|---|---|
|NAME|设备名称|
|MAJ:MIN|主设备号和次设备号|
|RM|是否为可移动设备（1表示是，0表示否）|
|SIZE|设备大小|
|RO|是否为只读设备（1表示是，0表示否）|
|TYPE|设备类型（disk, part, rom等）|
|MOUNTPOINT|设备的挂载点|
显示文件系统信息
```
lsblk -f
```
以键值对格式输出
```
lsblk -p
```
自定义输出哪些列
```
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
```
以 JSON 格式输出
```
lsblk -J
```
显示设备所有者信息
```
lsblk -m
```

### fdisk
fdisk 是一个创建和维护分区表的程序

```
fdisk -l # 查看详细分区信息
```

### cfdisk
 cfdisk是用来磁盘分区的程序,具有互动式操作界面而非传统fdisk的问答式界面
 cfdisk /dev/sda

### df
用于显示文件系统的磁盘空间使用情况，包括总容量、已用空间、可用空间和挂载点等信息。
```shell
df -h #以易读的形式
df -ih #显示 inode 信息而非块使用量
```


### btrfs




