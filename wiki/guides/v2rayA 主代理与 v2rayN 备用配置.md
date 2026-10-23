---
type: guide
status: needs-verification
updated: 2026-10-23
sources:
  - sources/codex-sessions/代理开机 DNS 排错增量-2026-10-23摘录.md
  - sources/codex-sessions/查找 v2rayN 本机支持版本-2026-10-22会话摘录.md
  - scripts/archlinux/stage-session-config.py
---

# v2rayA 主代理与 v2rayN 备用配置

适用条件与来源日期在正文中分别列明；占位路径、设备名与版本须按目标环境调整。以下是知识收录，不代表已在新机器完成部署。

来源：[查找 v2rayN 本机支持版本](../../sources/codex-sessions/%E6%9F%A5%E6%89%BE%20v2rayN%20%E6%9C%AC%E6%9C%BA%E6%94%AF%E6%8C%81%E7%89%88%E6%9C%AC-2026-10-22%E4%BC%9A%E8%AF%9D%E6%91%98%E5%BD%95.md)。

## 最终选择与边界

会话从 Linux 版本支持比较、单节点偏好，推进到 v2rayN 便携安装和 v2rayA 配置，最后用户明确 **v2rayA 主用、v2rayN 备用**。这不是同时让两个客户端接管全机流量的配置。来源节点、订阅、账户、地理位置及公网出口不进入可发布模板。

v2rayN Linux x64 架构匹配不等于每个 Arch 版本获得官方发行版保证；7.25.6 是来源时间点的版本，不称为永久最新版。[上游发布包说明](https://github.com/2dust/v2rayN/wiki/Release-files-introduction)

## 手动部署 v2rayN

按上游支持架构下载发布包，验证当前版本提供的校验文件，再以普通用户放入 `~/.local/opt/v2rayN/`。复制既有配置前退出旧实例并备份；生成用户 desktop 启动项，Exec/Icon 使用实际文件路径，供 fuzzel 打开。desktop 不自动展开 `~`，不能直接照抄含波浪线的路径。

来源报告已下载校验、迁移配置并建立入口，但运行的旧 Downloads 实例没有被强制退出；其最终迁移生效仍需要用户完全退出旧版再从菜单启动。配置含敏感信息，不能随程序目录整体提交。

## 手动配置 v2rayA

来源采用 AUR `v2raya-bin`；安装前核对当前包及 PKGBUILD，完整系统更新后按需执行 `paru -S v2raya-bin`。[官方项目](https://github.com/v2rayA/v2rayA)说明服务式管理与所用核心；不要把旧教程额外安装核心的步骤不加判断地叠上去。

```bash
sudo systemctl edit v2raya
```

在 editor 指定的有效编辑区填入：

```ini
[Service]
Environment="V2RAYA_ADDRESS=127.0.0.1:2017"
```

若提示内容在编辑区之外、new contents are empty，就是未保存，不能当作配置生效。

```bash
sudo systemctl daemon-reload
sudo systemctl start v2raya
ss -lntp 'sport = :2017'
```

确认管理端只监听 loopback 后打开 `http://127.0.0.1:2017`，自行创建管理员并导入节点。密码、节点链接不放入 Wiki。先测试实际 SOCKS 端口和 DNS 行为，再开启透明代理；20170 等是来源默认值，实际以安装版本配置为准。

## 分流与切换

| 来源界面模式 | 使用含义 |
| --- | --- |
| Off | 不接管透明流量，显式代理端口仍可能可用 |
| Do not Split Traffic | 被接管流量不按国内外拆分；排除规则另算 |
| Proxy except CN Sites | 来源最后选择，按规则国内直连、其余代理 |
| Proxy only GFWList | 仅列表匹配目标代理，未匹配目标可能无法访问 |
| Same as the Rule Port | 跟规则端口选择，不是沿用 v2rayN |

具体界面、端口和 RoutingA 行为随版本核对，不能把规则库分类当作绝对地理判断。来源 HTTP 请求测试支持其测试目标呈现分流，**不覆盖所有进程、UDP、DNS和IPv6**；IPv6测试失败，完整防火墙规则未读取。

主用确认后 `sudo systemctl enable v2raya`。切换备用前 `sudo systemctl stop v2raya`，确认其接管已释放，再启用 v2rayN；切回则先完全退出后者及其 TUN/系统代理，再启动前者。关闭浏览器管理页不停止服务。遇到断网先确认两端服务、端口、路由及DNS，不反复叠加代理。

## 脚本、维护和回退

`python3 scripts/archlinux/stage-session-config.py proxy --output /tmp/proxy-review --apply` 只生成 loopback drop-in 模板，按上文手动合并到 systemctl edit；不导入节点、不启动服务、不改变网络。脚本阶段的“生成成功”不等于透明代理部署成功。

升级前保存私人配置并记录核心/客户端版本，先显式代理、再分流、最后检查重登录/重启；分别测试 IPv4、IPv6、DNS、UDP与所需应用。备份/回退改动过的 drop-in，不使用会移除其他自定义配置的整套 revert；回退服务前先恢复网络可达性。新机不得复制他人凭据。当前指南缺完整路由/防火墙及备用切换验收。

## 收录与验证范围

2026-10-22：阅读所列会话用户消息与最终答复，工具输出按相关主题抽查，未逐行重新审计全部历史执行；来源摘录不包含全部工具输出、内部推理或 Side Chat。历史截图未逐张核验。指南保持 needs-verification，实际部署、图形交互和恢复应按正文验收后补记录。所有工作区会话的归档状态保持不变。

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]] · [[wiki/sources]]

公开阅读入口：[知识库导航](../index.md) · [仓库说明](../../README.md)

## 开机 DNS 故障与恢复（2026-10-23）

新增三轮记录：v2rayA 早于 Wi-Fi 就绪启动，Codex 先报 ECONNRESET，之后 EAI_AGAIN；用户明确 v2rayN TUN 是故障后的补救，不能作为最初故障原因。重启 v2rayA 后连接恢复。DNS/透明代理初始化异常是推断，未保存当时完整 DNS、防火墙状态，不能认定唯一根因。

待实施建议是在已有 drop-in 中合并 Wants=network-online.target 和 After=network-online.target，并确认实际使用 NetworkManager 及其 wait-online 服务。仓库 proxy/override.conf 已补为待审阅模板，不代表系统已应用。Restart=on-failure 仅处理进程失败，不检测进程存活但网络不可达。

[systemd 文档](https://www.freedesktop.org/software/systemd/man/252/systemd.special.html)说明网络消费者应主动拉入并排序在 network-online.target 之后；[NetworkManager 文档](https://networkmanager.pages.freedesktop.org/NetworkManager/NetworkManager/NetworkManager-wait-online.service.html)说明 wait-online 等待启动阶段完成。该条件不保证公网、代理节点或应用 DNS 可达，不能声称加依赖就彻底修复。

再次发生时，先保存 `journalctl -u v2raya -b`、resolv.conf、`getent ahostsv4` 结果，再恢复；日志仅留本地，分享前隐去节点和出口。切备用前先停止 v2rayA 并核对接管已释放；停止服务本身不保证所有 DNS 残留已清理。回退只恢复本次修改的 drop-in 和 wait-online 原启用状态，不整套 systemctl revert。待验收多次重启、联网延迟与主备用切换，当前未执行系统修改。
