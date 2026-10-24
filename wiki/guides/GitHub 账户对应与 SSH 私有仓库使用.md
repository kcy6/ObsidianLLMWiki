---
type: guide
status: needs-verification
updated: 2026-10-24
sources:
  - sources/codex-sessions/分析本机与 GitHub 账户配置.md
  - scripts/archlinux/configure-github-repo.sh
---

# GitHub 账户对应与 SSH 私有仓库使用

## 快速使用

分别检查提交署名、仓库地址和 SSH 认证。

```bash
git var GIT_AUTHOR_IDENT
git remote -v
```

执行范围：在目标 Git 仓库执行，只读；输出可能含私人地址。

复用要点：每个仓库明确身份与 remote；私钥、公钥授权和 agent 单独准备。

操作细节：[[wiki/guides/GitHub 账户对应与 SSH 私有仓库使用#先区分三种对应关系]]。

按需跳转：[先区分三种对应关系](#%E5%85%88%E5%8C%BA%E5%88%86%E4%B8%89%E7%A7%8D%E5%AF%B9%E5%BA%94%E5%85%B3%E7%B3%BB) · [手动配置流程](#%E6%89%8B%E5%8A%A8%E9%85%8D%E7%BD%AE%E6%B5%81%E7%A8%8B) · [脚本流程](#%E8%84%9A%E6%9C%AC%E6%B5%81%E7%A8%8B) · [后续维护与排错](#%E5%90%8E%E7%BB%AD%E7%BB%B4%E6%8A%A4%E4%B8%8E%E6%8E%92%E9%94%99) · [核对与待验证](#%E6%A0%B8%E5%AF%B9%E4%B8%8E%E5%BE%85%E9%AA%8C%E8%AF%81)。

说明 Git 提交署名、SSH 认证账户与远程仓库地址的区别，提供单账户配置、私有仓库克隆及已有项目关联流程。示例中的 `OWNER`、`REPOSITORY`、邮箱和项目路径均须替换；配套脚本只配置指定本地仓库。

本文使用 `$HOME` 或 `~` 表示执行者的主目录；设备名、项目名及占位符须按目标环境调整。脚本命令均从本仓库根目录执行。

来源与验证基线为 **2026-10-21**，本文于 **2026-10-22** 调整公开阅读表述，未重新验收软件、硬件或远端权限。[来源记录](../../sources/codex-sessions/%E5%88%86%E6%9E%90%E6%9C%AC%E6%9C%BA%E4%B8%8E%20GitHub%20%E8%B4%A6%E6%88%B7%E9%85%8D%E7%BD%AE.md) · [知识库导航](../index.md)

## 先区分三种对应关系

| 层次 | 由什么决定 | 能证明什么 |
| --- | --- | --- |
| 提交署名 | Git `user.name` / `user.email` | 提交作者信息；不能提供登录权限 |
| 访问身份 | SSH 密钥或 HTTPS 凭据 | 实际访问账户；浏览器/Codex 登录不自动等于终端认证 |
| 目标仓库 | remote URL | 克隆或推送的位置；仓库所有者也可能是组织 |

Linux 用户名不自动等于 GitHub 账户。以上是原会话的核心区分，来源：[[sources/codex-sessions/分析本机与 GitHub 账户配置]]；设置与认证入口可对照 [GitHub Git 设置说明](https://docs.github.com/en/get-started/git-basics/set-up-git)。

2026-10-20 的来源检查：工作区 `~/Documents/ChatGPT/archlinux环境搭建` 未设置可见的 Git 作者信息、无 remote、未发现 `.ssh` 和常见凭据配置，仓库 master 分支无提交。该结论仅限检查时点及常规路径，不是当前状态，也不能排除其他认证方法。后续用户明确表示 `ssh -T git@github.com` 已实现，但会话没有附用户名输出，因此不能推断具体登录账户。2026-10-21 收录时未重新审计认证状态。

## 手动配置流程

### 1. 检查目标仓库和提交身份

```bash
cd /实际项目目录
git status --short --branch
git config --show-origin --get-regexp '^user\.'
git remote -v
```

没有设置时 Git 查询可能返回非零。先决定全局默认还是仅此仓库：

```bash
# 仅本仓库，多账户时优先明确此范围。
git config --local user.name "提交名称"
git config --local user.email "已验证邮箱或 GitHub 提供的 noreply 邮箱"
# 单一身份且希望所有仓库沿用时，才把 --local 改成 --global。
```

仓库配置与全局配置作用域不同；环境变量等仍可能影响最终作者。[Git config 文档](https://git-scm.com/docs/git-config)。原会话给全局示例，本页补充仓库范围以便避免影响其他项目；没有替用户更改身份。

### 2. 准备 SSH 密钥

已能成功认证时跳过生成，先确认账号。尚未配置时先检查已有公钥文件，避免覆盖，选择一个尚不存在的密钥路径：

```bash
ssh-keygen -t ed25519 -C "GitHub 邮箱" -f ~/.ssh/id_ed25519_github
# 按提示设置口令，不在命令或 Wiki 中保存口令。
```

复用已有 agent；没有可用 agent 时，可在当前终端启动一个：

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_github
cat ~/.ssh/id_ed25519_github.pub
```

只把 `.pub` 公钥添加到 GitHub Settings → SSH and GPG keys → New SSH key，类型选 Authentication Key；私钥不上传、不粘贴到会话。[GitHub 密钥与 agent 说明](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

自定义密钥名需要让 SSH 选择它，可在现有 `~/.ssh/config` 中核对后合并下面配置，不覆盖整个文件：

```sshconfig
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
```

多账户不要让一个全局 Host 同时承担不同账户；可为每个账户设置不同 Host 别名及密钥，并让对应 remote 使用该别名。这里是单账户示例，脚本只支持标准 github.com URL。

### 3. 确认认证账户

```bash
ssh -T git@github.com
```

首次连接核对 [GitHub 官方主机指纹](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)再接受。成功欢迎信息中的用户名才是所用账户；GitHub 不提供 Shell，成功认证测试通常仍以退出码 1 结束，不能只按零/非零判定。[GitHub SSH 测试说明](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection)

### 4A. 克隆已有私有仓库

```bash
cd ~/Documents
git clone git@github.com:OWNER/REPOSITORY.git 本地项目名
cd 本地项目名
git remote -v
```

从仓库 Code → SSH 复制真实地址，替换占位符。直接 clone，无需先 `git init`。SSH 能登录仅证明认证，账户仍需拥有目标私有仓库权限；`Repository not found` 时核对地址、欢迎信息账户和组织授权要求。来源：[[sources/codex-sessions/分析本机与 GitHub 账户配置]] 的最终轮次及 [GitHub 克隆文档](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)。

### 4B. 将已有本地项目关联新远程

先在 GitHub 创建目标空仓库；已有 README 或提交时先协调历史，不能套用空仓库首推流程。已有本地 Git 仓库中：

```bash
git remote -v
# 仅在 origin 尚不存在时添加：
git remote add origin git@github.com:OWNER/REPOSITORY.git
```

若已有 origin，核对后选择保留、增加其他名称或明确 `git remote set-url origin ...`，不要盲目重复添加。[GitHub remote 管理](https://docs.github.com/en/get-started/git-basics/managing-remote-repositories)

```bash
git status --short
# 明确列出待提交的文件，不把私钥、令牌、聊天数据等加入提交。
git add -- 需要提交的文件
git diff --cached --stat
git diff --cached
# 确认内容后：
git commit -m "Describe the change"
git branch --show-current
# 将 CURRENT_BRANCH 替换成上条输出的实际分支名：
git push -u origin CURRENT_BRANCH
```

原会话的新仓库示例使用 `git branch -M main`；那是特定初始化选择，不是每个已有项目都应强制改名的步骤。本页保留实际分支再明确推送，也不假定原会话建议中的文件仍是当前应上传内容。无提交、detached HEAD 或无权限时先解决对应问题。以上只是可复现流程，2026-10-21 的收录工作未执行该流程中的远端创建或提交推送。

## 脚本流程

[仓库身份配置脚本](../../scripts/archlinux/configure-github-repo.sh)为整理阶段新增：

```bash
# 仓库根目录运行脚本，--repo 指向待配置的已有仓库。
bash scripts/archlinux/configure-github-repo.sh \
  --repo /实际项目目录 --name "提交名称" --email "已验证邮箱" \
  --remote git@github.com:OWNER/REPOSITORY.git
# 预览确认后，在同一命令后增加 --apply 才应用。
```

脚本只设置指定仓库的 local 署名，并在 origin 不存在时添加标准 GitHub SSH URL；重复运行相同输入不添加重复配置。已有不同 origin、多 URL 或独立 pushurl 时拒绝，交由手动核对。它不会生成或上传密钥、修改 SSH config、测试网络、克隆、改分支、提交或推送；这些交互仍按手动流程执行。

应用前将 Git config 备份到 `${XDG_STATE_HOME:-$HOME/.local/state}/wiki-github-repo/run-XXXXXXXX/`，包含 `config.before` 和原路径 `config-path.txt`，目录权限受限。备份可能包含仓库地址或其他敏感设置，不提交它。失败可能留下部分已写入配置；核对差异后手动恢复所需键，或在确定期间没有其他配置变化时恢复整个备份。不要直接复制旧 config 覆盖后来新增的设置。

脚本不覆盖系统/全局身份，也不证明身份在环境变量、include 配置等影响下的最终结果；用 `git var GIT_AUTHOR_IDENT`、`git remote -v` 及 SSH 欢迎信息分别确认三层关系。真实账户认证和私有仓库访问未由 2026-10-21 的隔离测试覆盖。

## 后续维护与排错

- 每个新项目检查有效提交署名、remote 和认证账户；共享机器或多账户优先明确仓库范围。改邮箱不自动重写已有提交。
- 新终端 agent 未加载时先 `ssh-add -l`，按实际会话加载正确密钥；不在每个终端无条件重复启动新 agent。
- 仓库转移、重命名或切换协议后核对 remote；保留 fetch/push 地址差异，不能只看浏览器登录状态。
- 轮换密钥时先验证新密钥及所需仓库访问，再撤销不再使用的旧公钥；丢失、泄露时及时撤销。没有需要时不删除本地密钥或 known_hosts。
- SSH 认证失败检查选用的密钥和 agent；认证成功但仓库不可见检查路径、账户权限及必要组织授权。日志中的私钥、令牌等不进入 Wiki。
- 撤销脚本写入的仓库配置前查备份或原值，按键恢复；remote、署名、GitHub 公钥授权分别维护。删除 remote 不删除远端仓库，也不撤销密钥权限。

以上维护方案综合自 [[sources/codex-sessions/分析本机与 GitHub 账户配置]] 及配套脚本的作用边界。

## 核对与待验证

2026-10-21 阅读接口返回的全部 3 个完成轮次及未标记截断的命令输出，保存来源快照；Side Chat 未覆盖。核对 Git/GitHub 官方配置、SSH、remote 和克隆文档。脚本在临时本地仓库测试，不接触用户真实仓库、密钥或远端；页面保持 needs-verification。

| 问题 | 状态 | 下一步及结论落点 |
| --- | --- | --- |
| 用户确认 SSH 成功后的具体账户 | 待验证 | 如需审计，查看欢迎信息，不由本页推断 |
| 私有仓库克隆与写权限 | 待实践 | 用户实际目标仓库授权及 clone/push 结果；更新验收记录 |
| 多账户与会话 agent 持久集成 | 待实践 | 按实际桌面与密钥方案另作配置，不能由单账户示例外推 |

相关：[[wiki/topics/Arch Linux 与桌面环境]] · [[wiki/index]] · [[wiki/sources]]

公开阅读入口：[仓库说明](../../README.md) · [Arch Linux 主题](../topics/Arch%20Linux%20与桌面环境.md) · [来源台账](../sources.md)
