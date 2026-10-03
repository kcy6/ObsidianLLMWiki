# 2026-06-16 Codex bundled 插件异常排查与修复记录

## 背景

本次对话围绕 Codex Desktop 的 bundled 插件异常展开，主要现象是插件商店无法识别或打开 `Chrome` / `Computer Use` 插件，且用户此前观察到插件页缺少 Chrome 插件或显示未连接。

当前机器环境：

- 工作区：`F:\25E\QDrive-Software-master`
- Codex 用户目录：`%USERPROFILE%\.codex`
- Codex 本地安装/运行目录：`%LOCALAPPDATA%\OpenAI\Codex`
- 系统日期：2026-06-16

## 初始发现

最开始检查当前项目时，发现工作区本身是 STM32/CMake 项目，不是 Codex 插件仓库。于是转向检查 Codex 本地配置、插件缓存和 bundled marketplace。

关键发现：

- `C:\Users\y\.codex\plugins\cache\openai-bundled\browser\26.609.71450` 存在，且 `browser@openai-bundled` 的 `.codex-plugin\plugin.json` 完整。
- `C:\Users\y\.codex\.tmp\bundled-marketplaces\openai-bundled\plugins\chrome` 当时只剩 `extension-host.exe`，缺少 `.codex-plugin\plugin.json`、`scripts\browser-client.mjs`、assets、skills 等插件必需文件。
- `C:\Users\y\.codex\chrome-native-hosts-v2.json` 内容为 `entries: []`。
- `config.toml` 中启用了 `browser@openai-bundled`，但没有 `chrome@openai-bundled` / `computer-use@openai-bundled`。
- `.codex-global-state.json` 中存在 `electron-chrome-extension-sync-managed-plugin-ids=["chrome@openai-bundled"]`，但实际缓存和 marketplace 中没有完整 Chrome 插件。

初步结论：不是项目问题，也不是简单账号配置问题，而是本地 `openai-bundled` marketplace/cache 损坏或半更新。

## demo.md 需求

用户提供文件：

`F:\code_temp\5.13\demo.md`

该文件要求按流程排查并尽量修复 Codex Desktop bundled 插件异常，重点包括：

- 先诊断，不要一开始删除目录或改配置。
- 修复前必须备份。
- 不要盲目修改 `[windows] sandbox`。
- 不暴露 API key、token 或 `auth.json` 内容。
- 如果确认是 Windows 文件锁导致 bundled 插件半更新，则停止残留进程、从安装源重建 marketplace/cache、修复 native host JSON，并验证插件列表。

当时处于 Plan Mode，所以先进行了非破坏性诊断，并输出了一份执行计划。

## 诊断证据

非破坏性诊断确认如下：

- `codex plugin marketplace list` 当时没有列出 `openai-bundled`。
- `codex plugin list` 当时只列出 `openai-primary-runtime` 和 `openai-curated`，没有正常列出 `openai-bundled`。
- `C:\Users\y\.codex\.tmp\bundled-marketplaces\openai-bundled\.agents\plugins\marketplace.json` 不存在。
- bundled 临时目录只剩半截 Chrome host 内容。
- `C:\Users\y\.codex\plugins\cache\openai-bundled\chrome` 和 `computer-use` 缓存目录缺失。
- 系统中有残留 `extension-host` 进程，其路径指向：

```text
C:\Users\y\.codex\plugins\cache\openai-bundled\chrome\latest\extension-host\windows\x64\extension-host.exe
```

但对应 cache 目录已不存在，属于残留进程锁住旧路径的典型状态。

日志中发现关键错误：

```text
EBUSY: resource busy or locked, rmdir 'C:\Users\y\.codex\.tmp\bundled-marketplaces\openai-bundled\plugins\chrome\extension-host\windows\x64'
```

以及：

```text
marketplace file `C:\Users\y\.codex\.tmp\bundled-marketplaces\openai-bundled\.agents\plugins\marketplace.json` does not exist
```

未发现 `os error 740`，因此不改 `[windows] sandbox`。

## 修复计划

计划内容：

- 备份关键文件和修复前状态。
- 停止残留 `extension-host` / `codex-computer-use` 进程。
- 查找完整 `openai-bundled` 安装源。
- 从安装源重建：
  - `%USERPROFILE%\.codex\.tmp\bundled-marketplaces\openai-bundled`
  - `%USERPROFILE%\.codex\plugins\cache\openai-bundled\chrome\<version>`
  - `%USERPROFILE%\.codex\plugins\cache\openai-bundled\computer-use\<version>`
- 重建 `latest` junction，指向稳定版本目录。
- 修复 Chrome native messaging manifest。
- 最小化补齐 `config.toml`：
  - `chrome@openai-bundled`
  - `computer-use@openai-bundled`
  - 保留 `browser@openai-bundled`
- 验证 marketplace、关键文件、native host、插件列表。

## 实际执行

用户要求实施计划后，切换到 Default Mode 并实际执行修复。

### 1. 备份

创建备份目录：

```text
C:\Users\y\codex-plugin-backups\openai-bundled-lock-repair-20260616-143407
```

备份内容包括：

- `config.toml`
- `.codex-global-state.json`
- `chrome-native-hosts-v2.json`
- 其他存在的 native host/extension manifest 文件
- 修复前进程和目录状态：`pre-repair-state.txt`

### 2. 停止残留进程

停止了残留的：

```text
extension-host
```

没有关闭 Codex Desktop 主进程。

### 3. 查找完整安装源

通过 AppX 包登记找到完整安装源：

```text
C:\Program Files\WindowsApps\OpenAI.Codex_26.609.9530.0_x64__2p2nqsd0c76g0\app\resources\plugins\openai-bundled
```

确认其中包含：

- `.agents\plugins\marketplace.json`
- `plugins\chrome\.codex-plugin\plugin.json`
- `plugins\chrome\scripts\browser-client.mjs`
- `plugins\chrome\extension-host\windows\x64\extension-host.exe`
- `plugins\chrome\assets\google-chrome.png`
- `plugins\computer-use\.codex-plugin\plugin.json`
- `plugins\computer-use\scripts\computer-use-client.mjs`
- `plugins\computer-use\assets\app-icon.png`

注意：当前版本的 `computer-use` 插件目录中不携带旧计划里提到的 `node_modules\@oai\sky\bin\windows\codex-computer-use.exe`，该 helper 由 Codex 运行时提供，因此验证标准按实际 manifest 调整。

### 4. 重建 marketplace/cache

重建：

```text
C:\Users\y\.codex\.tmp\bundled-marketplaces\openai-bundled
C:\Users\y\.codex\plugins\cache\openai-bundled\chrome\26.609.71450
C:\Users\y\.codex\plugins\cache\openai-bundled\computer-use\26.609.71450
```

重建 `latest` junction：

```text
C:\Users\y\.codex\plugins\cache\openai-bundled\chrome\latest
  -> C:\Users\y\.codex\plugins\cache\openai-bundled\chrome\26.609.71450

C:\Users\y\.codex\plugins\cache\openai-bundled\computer-use\latest
  -> C:\Users\y\.codex\plugins\cache\openai-bundled\computer-use\26.609.71450
```

### 5. 修复 Chrome native host

写入：

```text
C:\Users\y\AppData\Local\OpenAI\extension\com.openai.codexextension.json
```

并将 Windows registry：

```text
HKCU\Software\Google\Chrome\NativeMessagingHosts\com.openai.codexextension
```

指向该 manifest。

同时写入稳定版本目录下的：

```text
C:\Users\y\.codex\plugins\cache\openai-bundled\chrome\26.609.71450\extension-host\windows\x64\extension-host-config.json
```

关键设计：manifest 和 host config 使用稳定版本目录路径，不指向 `.tmp` 或 `chrome\latest`。

### 6. 更新 config.toml

最小补齐：

```toml
[plugins."chrome@openai-bundled"]
enabled = true

[plugins."computer-use@openai-bundled"]
enabled = true

[plugins."browser@openai-bundled"]
enabled = true
```

没有修改：

- API key
- 登录态
- `auth.json`
- 模型 provider
- `[windows] sandbox`

## 验证结果

验证通过：

- `marketplace.json` 可被 `ConvertFrom-Json` 解析。
- Chrome / Computer Use 图标文件存在。
- Chrome browser client 存在。
- Chrome extension host 存在。
- Computer Use client 存在。
- `latest` junction 指向稳定版本目录。
- native host 检查返回 `correct: true`。
- native JSON 文件合法，且不含 `\chrome\latest\` 或 `\.tmp\bundled-marketplaces\`。

`codex plugin marketplace list` 修复后显示：

```text
openai-primary-runtime
openai-bundled
openai-curated
```

`codex plugin list` 修复后显示：

```text
browser@openai-bundled       installed, enabled  26.609.71450
chrome@openai-bundled        installed, enabled  26.609.71450
computer-use@openai-bundled  installed, enabled  26.609.71450
```

## 2026-06-17 更新后复发与修复

更新到 `OpenAI.Codex_26.611.8273.0_x64__2p2nqsd0c76g0` 后，`chrome@openai-bundled` 和 `computer-use@openai-bundled` 再次无法被插件商店识别。

复发证据：

```text
codex plugin marketplace list: 缺少 openai-bundled
openai-bundled\.agents\plugins\marketplace.json: missing
日志：EBUSY: resource busy or locked
锁定目录：openai-bundled\plugins\chrome\extension-host\windows\x64
残留进程：extension-host.exe
```

本次修复备份目录：

```text
C:\Users\y\codex-plugin-backups\openai-bundled-update-repair-20260617-193048
```

已完成修复：

```text
停止 extension-host / codex-computer-use 残留进程
从 WindowsApps 当前 Codex 安装源重建 openai-bundled marketplace
重建 browser/chrome/computer-use cache 到版本 26.611.61753
重建 latest junction 指向稳定版本目录
修复 Chrome native host manifest
修复 codex:// 协议注册到当前 PackageId
补齐并启用 browser/chrome/computer-use plugin 配置
```

额外发现并修复：

```text
C:\Users\y\.codex\config.toml 第 11 行存在乱码项目路径，导致 TOML parse error:
unclosed table, expected `]`
```

处理方式：只删除该损坏的 `[projects...]` 小段，未修改 provider、API key、auth 或 `[windows] sandbox`。

验证结果：

```text
openai-bundled marketplace: restored
browser@openai-bundled: installed, enabled, 26.611.61753
chrome@openai-bundled: installed, enabled, 26.611.61753
computer-use@openai-bundled: installed, enabled, 26.611.61753
native host manifest: correct
native host manifest 不包含 \chrome\latest\ 或 \.tmp\bundled-marketplaces\
codex:// PackageId: OpenAI.Codex_26.611.8273.0_x64__2p2nqsd0c76g0
```

结论：本次仍是同一类更新竞态/文件锁问题。只要更新时 `extension-host.exe` 仍在运行，就可能再次把 `openai-bundled` 半更新成损坏状态。后续更新前建议先退出 Chrome/Codex，必要时手动确认并停止：

```powershell
Get-Process extension-host,codex-computer-use -ErrorAction SilentlyContinue | Stop-Process -Force
```

## 失败原因总结

本次失败的根因是 Windows 文件锁：

Codex 更新 bundled 插件时，Chrome 插件的 native host 进程 `extension-host.exe` 仍在运行，占用了目录：

```text
%USERPROFILE%\.codex\.tmp\bundled-marketplaces\openai-bundled\plugins\chrome\extension-host\windows\x64
```

更新流程尝试删除/替换该目录时触发：

```text
EBUSY: resource busy or locked
```

结果更新只写入半截内容，导致 `openai-bundled` 缺少：

```text
%USERPROFILE%\.codex\.tmp\bundled-marketplaces\openai-bundled\.agents\plugins\marketplace.json
```

因此插件商店无法读取 marketplace，`chrome@openai-bundled` / `computer-use@openai-bundled` 表现为消失、不可用、图标不加载或点进去报错。

## 后续是否可能复发

有可能复发。

触发条件：

- Codex 更新 bundled 插件时，旧的 `extension-host.exe` 或 `codex-computer-use.exe` 仍在运行。
- Windows 锁住正在运行的 `.exe` 或其父目录。
- Codex 更新逻辑再次尝试直接清理/替换同一路径。

本次修复已经降低了部分风险：

- native host manifest 不再指向 `.tmp` 或 `chrome\latest`。
- `latest` junction 指向稳定版本目录。
- marketplace 和 cache 已恢复完整。

但如果未来 Codex 自身更新 bundled marketplace 时再次遇到残留进程锁，仍可能再次损坏 `.tmp\bundled-marketplaces\openai-bundled`。

建议后续更新前：

```powershell
Get-Process extension-host,codex-computer-use -ErrorAction SilentlyContinue
```

如果有残留：

```powershell
Get-Process extension-host,codex-computer-use -ErrorAction SilentlyContinue | Stop-Process -Force
```

再更新/重启 Codex。

如果插件页再次异常，优先检查：

- `EBUSY`
- `resource busy or locked`
- `marketplace.json does not exist`
- `extension-host\windows\x64`

不要优先改账号、地区、provider、API key 或 `[windows] sandbox`。

## 2026-06-16 追加：修复 codex:// 协议注册

参考文章继续排查后，发现本机 `HKCU\Software\Classes\codex` 只有：

```text
URL Protocol = ""
(Default) = URL:codex
```

缺少 AppX DelegateExecute 打开链路。当前 Codex 包对应的参考 handler 为：

```text
HKCU\Software\Classes\AppXybfp6cjpb1wf0pftw0fd4bz59gzn1401
```

其中包含：

```text
AppUserModelID = OpenAI.Codex_2p2nqsd0c76g0!App
PackageId = OpenAI.Codex_26.609.9530.0_x64__2p2nqsd0c76g0
DelegateExecute = {A56A841F-E974-45C1-8001-7E3F8A085917}
```

修复前已导出备份：

```text
C:\Users\y\codex-plugin-backups\codex-url-protocol-repair-20260616-181735
```

实际补齐了：

```text
HKCU\Software\Classes\codex\Application
HKCU\Software\Classes\codex\DefaultIcon
HKCU\Software\Classes\codex\Shell\open
HKCU\Software\Classes\codex\Shell\open\command
```

并保留：

```text
HKCU\Software\Classes\codex
    URL Protocol = ""
    (Default) = URL:codex
```

验证结果：

```text
DelegateExecute = {A56A841F-E974-45C1-8001-7E3F8A085917}
PackageId = OpenAI.Codex_26.609.9530.0_x64__2p2nqsd0c76g0
AppUserModelID = OpenAI.Codex_2p2nqsd0c76g0!App
```

同时再次验证插件状态仍正常：

```text
browser@openai-bundled       installed, enabled  26.609.71450
chrome@openai-bundled        installed, enabled  26.609.71450
computer-use@openai-bundled  installed, enabled  26.609.71450
```
