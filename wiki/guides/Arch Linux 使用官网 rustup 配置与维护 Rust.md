---
type: guide
status: needs-verification
updated: 2026-10-24
sources:
  - sources/codex-sessions/查找 Rust 环境配置教程.md
  - scripts/archlinux/setup-rust-official.sh
---

# Arch Linux 使用官网 rustup 配置与维护 Rust

## 快速使用

区分工具链、项目依赖与 Shell PATH。

```bash
rustup show
cargo --version
```

执行范围：只读检查；需要工具已安装。

复用要点：保留 rust-toolchain.toml、Cargo.lock 与必要 Cargo 配置；官网版与系统包版分别处理。

操作细节：[[wiki/guides/Arch Linux 使用官网 rustup 配置与维护 Rust#后续维护]]。

按需跳转：[最终选择与适用范围](#%E6%9C%80%E7%BB%88%E9%80%89%E6%8B%A9%E4%B8%8E%E9%80%82%E7%94%A8%E8%8C%83%E5%9B%B4) · [三种入口不要混淆](#%E4%B8%89%E7%A7%8D%E5%85%A5%E5%8F%A3%E4%B8%8D%E8%A6%81%E6%B7%B7%E6%B7%86) · [手动配置流程](#%E6%89%8B%E5%8A%A8%E9%85%8D%E7%BD%AE%E6%B5%81%E7%A8%8B) · [脚本流程](#%E8%84%9A%E6%9C%AC%E6%B5%81%E7%A8%8B) · [后续维护](#%E5%90%8E%E7%BB%AD%E7%BB%B4%E6%8A%A4) · [核对与待验证](#%E6%A0%B8%E5%AF%B9%E4%B8%8E%E5%BE%85%E9%AA%8C%E8%AF%81)。

适用于 Linux 用户级 Rust 开发环境，示例以 Arch Linux 为依赖管理环境。采用官网 rustup 安装 stable 工具链，说明 Shell 环境、项目版本固定、依赖更新和卸载；系统包版 rustup 应按其打包方式维护。

本文使用 `$HOME` 或 `~` 表示执行者的主目录；设备名、项目名及占位符须按目标环境调整。脚本命令均从本仓库根目录执行。

来源与验证基线为 **2026-10-21**，本文于 **2026-10-22** 调整公开阅读表述，未重新验收软件、硬件或远端权限。[来源记录](../../sources/codex-sessions/%E6%9F%A5%E6%89%BE%20Rust%20%E7%8E%AF%E5%A2%83%E9%85%8D%E7%BD%AE%E6%95%99%E7%A8%8B.md) · [知识库导航](../index.md)

## 最终选择与适用范围

本指南采用 **Rust 官网安装器**，与来源记录中的最终选择一致。pacman 安装 rustup 作为可选方案对比，不与官网版叠加安装。来源：[[sources/codex-sessions/查找 Rust 环境配置教程]] 全部 3 轮。

2026-10-20 的来源检查环境为 Arch Linux x86_64，已有 base-devel、GCC、pkgconf、OpenSSL、Git、GDB 和 Vim，未发现 Rust 命令。初次环境输出 `$SHELL=/usr/bin/bash`；后续维护答复改用 Zsh 示例，但未附新的 Shell 查询。执行前确认实际 Shell，不能把两次说明合并成同时验证过的状态。会话未执行安装、修改启动文件或编译验收，该日期的知识整理未操作实际工具链。

## 三种入口不要混淆

| 方案 | rustup 本体 | Rust 工具链 | 本页处理 |
| --- | --- | --- | --- |
| 官网安装器 | 用户级安装，通常在 `~/.cargo/bin` | rustup 管理，默认数据在 `~/.rustup` | 用户最终选用 |
| pacman 的 rustup 包 | 系统包管理器维护 | 仍由 rustup 管理 | 保留对比，不与官网版叠装 |
| pacman 的 rust 包 | 直接使用发行版编译器包 | 按发行版包维护 | 另一种方案，不等于 rustup |

用户级路径及可用 `CARGO_HOME`、`RUSTUP_HOME` 改变位置的行为见 [rustup 安装说明](https://rust-lang.github.io/rustup/installation/index.html)。pacman 方案的路径与打包差异来自 [[sources/codex-sessions/查找 Rust 环境配置教程]]，2026-10-21 收录时未重新核验其软件包文件列表。官网方案不需要源会话早期针对 Arch 包写出的 `/usr/lib/rustup/bin`。

## 手动配置流程

### 1. 检查已有安装及系统依赖

```bash
printf '%s\n' "$SHELL"
command -v rustup rustc cargo cc curl
pacman -Q rust rustup base-devel gcc pkgconf openssl
```

未安装项会报错，按实际情况判断。若已有系统 rust/rustup 包或其他入口，先确认选用哪套再迁移，不直接覆盖。历史环境已有编译依赖，不代表新机器齐全；缺失时按需完整更新并安装，例如 `sudo pacman -Syu --needed base-devel pkgconf openssl curl`。来源：[[sources/codex-sessions/查找 Rust 环境配置教程]] 的环境检查。

### 2. 安装官方工具链

普通用户执行 Rust 官方入口：

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup component add rust-analyzer rust-src
```

先阅读安装器提示，再选择默认 stable/default profile；不加 sudo。官网安装器、参数及默认布局见 [Rust 入门页](https://rust-lang.org/zh-CN/learn/get-started/) 和 [其他安装方式](https://rust-lang.github.io/rustup/installation/other.html)。若有自定义 Cargo/Rustup 目录，上述路径需要相应调整。

### 3. 确认 Shell 入口

```bash
command -v rustup cargo rustc
rustup show
rustc --version
cargo --version
rust-analyzer --version
cargo fmt --version
cargo clippy --version
```

默认用户级入口通常应来自 `~/.cargo/bin`。新开终端后仍找不到时，先检查安装器已有配置，再决定补哪一个 Shell 的启动文件；不要重复追加。Zsh 可在 `~/.zshrc` 中添加一次：

```zsh
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
```

当前终端执行 `source ~/.zshrc`；Bash 用户检查自己的 `~/.bashrc`/登录配置，不照抄 Zsh 文件名。此 Shell 排查方法综合自 [[sources/codex-sessions/查找 Rust 环境配置教程]]；2026-10-21 收录时未修改启动文件。

### 4. 编译验收

在不存在同名项目的目录中执行：

```bash
mkdir -p ~/Projects
cd ~/Projects
cargo new rust-hello
cd rust-hello
cargo run
cargo fmt --check
cargo clippy --all-targets -- -D warnings
cargo test
```

记录工具链版本、命令退出码及输出；`Hello, world!` 只覆盖运行例程，仍需其他检查通过。项目已存在时进入并检查，不能为重跑教程删除原目录。来源：[[sources/codex-sessions/查找 Rust 环境配置教程]]；未完成目标机实测。

## 脚本流程

[官网工具链脚本](../../scripts/archlinux/setup-rust-official.sh)为整理阶段新增：

```bash
# 仓库根目录：只预览，无下载和配置写入。
bash scripts/archlinux/setup-rust-official.sh
# 明确选择后执行；此命令会实际安装；尚无目标环境执行记录。
bash scripts/archlinux/setup-rust-official.sh --apply
```

应用模式只支持默认用户级目录，拒绝 root、已由 pacman 安装的 rust/rustup，以及尚未辨明的现有 Rust 入口；要求 `cc` 可用。首次下载官方安装器到临时目录并执行，参数固定为 stable/default，`--no-modify-path` 避免改写 Shell 启动文件。已有用户级 rustup 时补齐 stable 和 rust-analyzer/rust-src，保留原来的默认工具链；因此检查目标 stable 时可显式用 `cargo +stable`。

脚本会安装或更新 stable，不是完全无副作用的重复操作；不调整项目覆盖、不修改项目版本文件、不设置镜像。下载失败时停止，已完成的工具链变更不自动回滚。安装器临时目录会清理，工具链数据保留；先核对 `rustup show` 再决定后续操作。脚本结束不会改变父 Shell 环境，按上一节手动加载环境，再进行编译验收。

## 后续维护

| 维护对象 | 操作 | 验证 |
| --- | --- | --- |
| 已安装的发布通道及组件 | `rustup update` | `rustup show`，重新运行项目测试 |
| 官网 rustup 本体 | 默认更新流程检查自更新；需要时 `rustup self update` | `rustup --version`；发行版管理的版本不要照搬此命令 |
| 项目依赖 | 项目中 `cargo update` | 审查 `Cargo.lock` 差异，运行测试 |
| cargo install 的工具 | 按需 `cargo install 包名 --locked` | 对应命令版本及所需功能 |

工具链与本体更新见 [rustup 基本使用](https://rust-lang.github.io/rustup/basics.html)；依赖锁文件更新见 [Cargo update](https://doc.rust-lang.org/cargo/commands/cargo-update.html)。其余维护建议来自 [[sources/codex-sessions/查找 Rust 环境配置教程]]。系统链接器等依赖仍按 Arch 完整系统更新维护，不由 rustup 更新。

### 固定项目版本

需要可复现工具链时，在项目根目录提交 `rust-toolchain.toml`，把占位符替换成实际验证过的版本再使用：

```toml
[toolchain]
channel = "<经项目验证的版本号>"
profile = "default"
components = ["rust-src", "rust-analyzer"]
```

固定版本不会因更新 stable 就自动切换。升级时显式修改版本文件，运行 fmt/clippy/test。命令行 `+工具链`、`RUSTUP_TOOLCHAIN`、目录覆盖和项目文件会影响实际选择，因此在项目内用 `rustup show` 判断，而不是只看系统默认值。[rustup 覆盖规则](https://rust-lang.github.io/rustup/overrides.html)

### 清理、迁移与卸载

- `rustup toolchain list` 检查后，仅在确认项目不依赖时执行 `rustup toolchain uninstall nightly` 等清理；固定版本也要检查依赖。
- 项目目录中 `cargo clean` 删除构建产物，下次需重新编译；不是删除源码或升级依赖。
- 迁移保留项目源码、版本文件、`Cargo.lock` 和必要的 Cargo 配置；记录工具链及自装工具版本。Cargo 配置可能包含凭据，不把令牌写进 Wiki 或 Git。
- 官网方案可按官方说明用 `rustup self uninstall` 卸载；先确认这是选用的用户级安装，保留项目和配置备份，再检查 Shell 中残留的环境加载行。不能对系统包版直接照搬清理步骤。[官方卸载说明](https://rust-lang.github.io/rustup/installation/index.html)

## 核对与待验证

2026-10-21 阅读接口返回的 3 个完成轮次、全部用户/助手消息与未标记截断的命令输出，保存来源快照；Side Chat 未覆盖。核对上列 Rust 官方资料，未进行真实下载安装或项目编译。脚本仅完成语法、预览和模拟流程验证，页面保持 needs-verification。

| 问题 | 状态 | 下一步及结论落点 |
| --- | --- | --- |
| 当前 Shell 和 Rust 安装状态 | 待验证 | 执行前重新核对，更新环境段 |
| 官网安装与实际项目验收 | 待实践 | 按流程记录版本和检查结果，更新验收段 |
| 编辑器 rust-analyzer 集成 | 待实践 | 按实际编辑器单独配置与验收；可关联软件指南 |

相关：[[wiki/guides/Arch Linux 常用软件安装与维护]] · [[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]]

公开阅读入口：[仓库说明](../../README.md) · [Arch Linux 主题](../topics/Arch%20Linux%20与桌面环境.md) · [来源台账](../sources.md)
