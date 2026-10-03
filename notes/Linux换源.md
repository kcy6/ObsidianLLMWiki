
## ARM架构换源（树莓派）
### Ubuntu24.04 及以上
确认系统版本与架构
```
cat /etc/os-release
dpkg --print-architecture

注意，对于不同的架构存在不同的换源方式arm64、armhf、riscv64：需要使用ubuntu-ports
而amd64：使用后面的普通 Ubuntu 镜像
VERSION_ID="26.04"
VERSION_CODENAME=resolute
arm64
```
对于初次安装的系统需要先更新时间
```
# 检查时间
date
timedatectl status
# 开启网络时间同步，也就是让系统自动从网络时间服务器校准时间。
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd
```
备份
```
# 备份新版源配置
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak
```
换源
```
sudo nano /etc/apt/sources.list.d/ubuntu.sources

# 改URI(两处)
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports

Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports
Suites: resolute resolute-updates resolute-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports
Suites: resolute-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg


sudo apt clean
sudo apt update
sudo apt upgrade
```

### Raspberry Pi OS（基于Debian）
架构：aarch64
系统：Debian 13 (trixie)  DEB822 格式
```
sudo cp -a /etc/apt/sources.list.d \
/etc/apt/sources.list.d.backup-$(date +%Y%m%d)

sudo nano /etc/apt/sources.list.d/debian.sources
sudo nano /etc/apt/sources.list.d/raspi.sources
```
**debian.sources**
```
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/debian
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
```
**raspi.sources**
```
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/
Suites: trixie
Components: main
Signed-By: /usr/share/keyrings/raspberrypi-archive-keyring.gpg
```


## x86_64架构换源
