## Ubuntu26.04
在 Windows 生成密钥
```
ssh-keygen -t ed25519 -C "vscode-rpi"
```
Windows PowerShell 执行
```
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" |
    ssh pi5@192.168.137.170 "umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys"
```
然后明确指定该密钥测试
```
ssh -i "$env:USERPROFILE\.ssh\id_ed25519" pi5@192.168.137.170
```
如果仍然要求密码，在树莓派修复权限
```
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chown -R "$USER:$USER" ~/.ssh
```



Arch Linux
live环境
```shell
reflector -p https -a 12 -c cn --v --sort rate --save /etc/pacman.d/mirrorlist 
pacman -Sy # 执行过则跳过
pacman -S openssh
sudo vim /etc/ssh/sshd_config
# 开头加上，允许root用户通过ssh登录
PermitRootLogin yes

systemctl enable --now sshd
passwd root # 设置root密码
```