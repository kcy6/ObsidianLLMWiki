---
type: guide
status: needs-verification
updated: 2026-10-22
sources:
  - sources/codex-sessions/分析本机虚拟机安装方式-2026-10-22会话摘录.md
  - scripts/archlinux/stage-session-config.py
---

# Arch Linux KVM 虚拟机与 Fedora 文件传输

适用条件与来源日期在正文中分别列明；占位路径、设备名与版本须按目标环境调整。以下是知识收录，不代表已在新机器完成部署。

来源：[分析本机虚拟机安装方式](../../sources/codex-sessions/%E5%88%86%E6%9E%90%E6%9C%AC%E6%9C%BA%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%AE%89%E8%A3%85%E6%96%B9%E5%BC%8F-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md)。

## 适用环境和历史变化

Arch x86_64 宿主机、KVM/QEMU、virt-manager；来源机器为 AMD-V、约 14 GiB 内存、Wi-Fi。先后记录“尚未安装”与“软件和服务已就绪”，是不同检查时点，不能从第一轮结论推断当前状态。最后创建流程仍写明未创建虚拟机；文件传输为后续使用说明，不是传输成功记录。

## 手动配置宿主机

```bash
sudo pacman -Syu --needed qemu-desktop libvirt virt-manager edk2-ovmf dnsmasq swtpm
virt-host-validate qemu
```

先判断现有 libvirt 使用单体还是模块化守护进程，再启用相应服务；来源采用 `sudo systemctl enable --now libvirtd.service`，不要同时照抄另一套 virtqemud 套件。[libvirt 官方架构说明](https://libvirt.org/daemons.html)

通过 Polkit 授权连接 `qemu:///system`。来源已有对 libvirt 组的本地规则，添加该组会授予较广泛虚拟化管理权限，不能外推所有机器都必须加组；确需使用时 `sudo usermod -aG libvirt "$(id -un)"`，注销再登录验证。KVM 已加载/嵌套已开启时不重复修改内核参数。

```bash
virsh -c qemu:///system net-list --all
# 只对已存在但未启动的 default 网络执行：
virsh -c qemu:///system net-start default
virsh -c qemu:///system net-autostart default
virsh -c qemu:///system pool-list --all
```

网络缺失时先找到发行版提供的默认 XML 或明确创建 NAT 网络，不盲用不存在的 `/etc/libvirt/.../default.xml`。dnsmasq 实例交给 libvirt，不为此单独开启系统 dnsmasq。网络/存储池权限失败先解决授权。

## 创建 Fedora 虚拟机

把已校验的 ISO 复制到 QEMU 可读取的位置，不放宽整个用户主目录权限。例如用 `sudo install -d -m 0755 /var/lib/libvirt/boot`，再 `sudo install -m 0644 "$HOME/Downloads/实际镜像.iso" /var/lib/libvirt/boot/fedora.iso`。

打开 `virt-manager --connect qemu:///system`，新建本地 ISO 安装，按实际 Fedora 版本选择系统；来源示例为 Fedora 44、4 vCPU、4096 MiB、50 GiB qcow2、default NAT。资源值是单机起点，按宿主机余量调整。

安装前核对 Q35、UEFI、VirtIO 磁盘/网卡和 SPICE，初次关闭 3D 加速；host-passthrough 会影响跨主机迁移。Fedora 自带 VirtIO 驱动；Windows 的 TPM/驱动 ISO 不能照搬到 Fedora。只对目标虚拟磁盘分区，安装后弹出 ISO并优先从磁盘启动。

Fedora 客体内按需执行：

```bash
sudo dnf upgrade --refresh
sudo dnf install spice-vdagent qemu-guest-agent openssh-server
sudo systemctl enable --now sshd
# guest agent 需存在 org.qemu.guest_agent.0 通道，再启用服务。
sudo systemctl enable --now qemu-guest-agent
```

这是来源方案，客体版本/服务行为需实测；Fedora 在线入门页此次访问被防护拦截，未据此独立确认所有命令。

## 文件传输

在客体防火墙中按所用 zone 放行 SSH，确认客体用户名/IP及主机指纹；不要直接关闭防火墙。默认 libvirt NAT 通常允许宿主访问客体，不保证任意自定义网段都相同。

```bash
# Arch 宿主机执行，使用实际客体地址；不是 NAT 网关。
scp 文件 用户@客体IP:~/
scp -r 项目目录 用户@客体IP:~/
```

支持 SFTP 的文件管理器可打开 `sftp://用户@客体IP`。长期共享可另行配置 Virtiofs，来源未完成这项实践；SPICE 剪贴板不是文件共享的同义词。

## 脚本、维护与恢复

生成软件安装脚本：`python3 scripts/archlinux/stage-session-config.py vm --output /tmp/vm-review --apply`。审阅后 `bash /tmp/vm-review/install-host.sh` 默认预览；追加 `--apply` 才安装包，不启用服务、不创建虚拟机或改用户组。

升级后检查 KVM、连接、NAT、客体启动及 SSH/剪贴板；备份关闭状态的磁盘、域 XML、UEFI NVRAM等必要状态。删除虚拟机前确认是否保留磁盘；配置导出或快照不等于离线备份。来源未实测备份恢复、文件传输或此脚本真实安装，均待实践。

## 收录与验证范围

2026-10-22：阅读所列会话用户消息与最终答复，工具输出按相关主题抽查，未逐行重新审计全部历史执行；来源摘录不包含全部工具输出、内部推理或 Side Chat。历史截图未逐张核验。指南保持 needs-verification，实际部署、图形交互和恢复应按正文验收后补记录。所有工作区会话的归档状态保持不变。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]] · [[wiki/sources]]

公开阅读入口：[知识库导航](../index.md) · [仓库说明](../../README.md)
