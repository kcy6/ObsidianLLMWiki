**## GNOME

### 基础配置

==完整更新系统并重启==

```bash
sudo dnf upgrade --refresh
systemctl reboot
```

VMware（如果是安装的虚拟机且没有自动安装VMware-tools）

```bash
sudo dnf install open-vm-tools open-vm-tools-desktop -y
sudo systemctl enable --now vmtoolsd
systemctl reboot
```

==配置英文 Locale、中文界面==

```bash
localectl #查看当前系统配置
locale #查看当前用户会话配置
配置的理念是将系统设置为英文操作系统但是通过修改LANGUAGE=zh_CN:zh配置项来使桌面显示为中文
LANG=en_US.UTF-8
LANGUAGE=zh_CN:zh
LC_ALL=
全局系统级修改（对所有用户生效）
执行以下指令配置：
sudo dnf install langpacks-zh_CN langpacks-en -y
sudo nano /etc/locale.conf
添加
LANG="en_US.UTF-8"
LANGUAGE="zh_CN:zh"
```

==中文输入法==

```
Fe
dora Workstation的GNOME桌面默认与IBus集成最好，默认也是直接用IBus
直接在设置中添加中文输入法即可
进一步可以设置为Fcitx5+Rime+雾凇拼音，以实现能符合中文语境到词组识别


1.安装 Fcitx5、Rime 和应用支持模块
sudo dnf install fcitx5 fcitx5-autostart fcitx5-configtool \
  fcitx5-rime fcitx5-gtk fcitx5-qt
  
2.配置应用使用 Fcitx5（GTK/Qt 输入法模块方案）
mkdir -p ~/.config/environment.d
nano ~/.config/environment.d/90-fcitx5.conf 
内容
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx


3. 确认登录自动启动
cat /etc/xdg/autostart/org.fcitx.Fcitx5.desktop
关键内容应该包括
Exec=/usr/bin/fcitx5



```

==启用 Flathub，RPM Fusion按需启用==

```bash
flatpak remotes
flatpak remote-add --if-not-exists flathub \
https://dl.flathub.org/repo/flathub.flatpakrepo

sudo dnf install \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf upgrade --refresh
```

==安装常用基础工具==

```bash
sudo dnf install \
git curl wget vim-enhanced \
gcc gcc-c++ gdb \
cmake ninja-build make \
python3-pip \
htop fastfetch \
ripgrep fd-find tree \
arm-none-eabi-gcc-cs arm-none-eabi-newlib openocd
```

## KDE Plasma

### 基础配置

==完整更新系统并重启==

```bash
sudo dnf upgrade --refresh
systemctl reboot
```

VMware（如果是安装的虚拟机且没有自动安装VMware-tools）

```bash
sudo dnf install open-vm-tools open-vm-tools-desktop -y
sudo systemctl enable --now vmtoolsd
systemctl reboot
```

==配置英文 Locale、中文界面、中文输入法==
桌面语言，检查配置

```bash
cat ~/.config/plasma-localerc
```

执行配置

```bash
kwriteconfig6 --file plasma-localerc \
    --group Formats \
    --key LANG en_US.UTF-8

kwriteconfig6 --file plasma-localerc \
    --group Translations \
    --key LANGUAGE "zh_CN:zh"
```

Fedora KDE建议使用 Fcitx5

```bash
sudo dnf install fcitx5 fcitx5-chinese-addons fcitx5-configtool -y
fcitx5输入法框架
fcitx5-chinese-addons拼音、双拼等中文输入法
fcitx5-configtool图形配置工具

终端执行添加中文输入法
fcitx5-configtool
```

最终效果

```
底层Locale：英文
KDE界面：中文
终端命令输出：可能是中文（视翻译团队翻译量而定）
中文输入法：正常使用
```

==启用 Flathub，RPM Fusion按需启用==

```bash
flatpak remotes
flatpak remote-add --if-not-exists flathub \
https://dl.flathub.org/repo/flathub.flatpakrepo

RPM Fusion检查命令
rpm -q rpmfusion-free-release rpmfusion-nonfree-release
dnf repolist --enabled | grep -i rpmfusion

sudo dnf install \
https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

验证
rpm -q rpmfusion-free-release rpmfusion-nonfree-release
dnf repolist --enabled | grep -i rpmfusion

更新
sudo dnf upgrade --refresh
```

==安装常用基础工具==

```bash
sudo dnf install \
git curl wget vim-enhanced \
gcc gcc-c++ gdb \
cmake ninja-build make \
python3-pip \
htop fastfetch \
ripgrep fd-find tree \
arm-none-eabi-gcc-cs arm-none-eabi-newlib openocd
```

==启用SSH连接==

```
sudo dnf install openssh-server
sudo systemctl enable --now sshd
systemctl status sshd --no-pager

如果开了防火墙
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
sudo firewall-cmd --list-services
```

==关闭终端每次都要sudo都要输入密码==

```bash
sudo visudo -f /etc/sudoers.d/y-nopasswd
打开后输入
y ALL=(ALL:ALL) NOPASSWD: ALL
保存退出后验证配置
sudo visudo -cf /etc/sudoers.d/y-nopasswd
```
