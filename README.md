# LLMWiki

这是一个在原始笔记和剪藏之上持续维护综合知识的 Obsidian 仓库。

从 [知识库首页](wiki/index.md) 开始，查看 [来源台账](wiki/sources.md) 和 [维护日志](wiki/log.md)。AI 的维护约定见 [wiki/AGENTS.md](wiki/AGENTS.md)。

| 位置 | 用途 |
| --- | --- |
| `notes/`、`Clippings/`、专题目录、`错误排查/` | 原始笔记与文章，默认只读 |
| `sources/` | 外部来源；Shorin 教程是独立 Git 子模块 |
| `wiki/` | 主题、概念、流程、问题及综合结论 |
| `附件/`、`Whiteboard/`、`.obsidian/` | 正在使用的附件、画板和 Obsidian 配置 |
| `scripts/` | 只读检查器及需显式应用的配置辅助脚本 |

## 设计依据与目录约定

参考 [Karpathy 的 LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)，本地保存 [中文阅读卡](sources/Karpathy-LLM-Wiki.md)，并非全文副本。具体操作见 [收录与维护流程](wiki/guides/LLM%20Wiki%20收录与维护流程.md)。

新个人笔记放 notes，网页剪藏放 Clippings，外部项目资料放 sources；既有专题目录继续作为来源。wiki 内按 topics（路线图）、concepts（概念）、guides（流程）、questions（比较与待验证问题）分类；不预建空目录或批量移动旧笔记。

## 日常维护

1. 收录：指定来源与需要解决的问题，读完全文或明确章节范围，更新关联页面、台账和日志。
2. 问答：先查 Wiki 和来源，将可复用的结论写回；缺失证据进入问题表。
3. 检查：运行结构检查，再人工检查矛盾、过时结论、适用条件和图示。

在仓库根目录使用 Python 3.9+（仅标准库，无需安装依赖）：

```sh
python3 scripts/check_wiki.py
python3 scripts/check_wiki.py --strict
```

或使用 PowerShell 7：

```powershell
pwsh -NoProfile -File scripts/Test-Wiki.ps1
pwsh -NoProfile -File scripts/Test-Wiki.ps1 -Strict
```

普通模式有错误返回 1，仅有警告返回 0；严格模式有警告也返回 1。工具只读，不联网，不初始化或更新子模块。Python 用 `--root`、PowerShell 用 `-Root` 指定另一个仓库目录。

检查范围：Wiki 页面的四项必要属性、日期和状态、类型与目录对应关系、sources 路径、wikilink 文件和 ATX 标题或块锚点、首页覆盖、入链和子模块可用性。跳过代码示例；图片嵌入核验目标但不计入概念入链。

两个实现覆盖上述同一组约定，不承诺对所有复杂 Markdown 语法解析一致。Python 检查器用于没有 PowerShell 的环境；维护检查逻辑时应同步两者。

这是遵循本库约定的检查器，不是完整 YAML/Markdown 解析器：属性采用简单标量及缩进 sources 列表（空列表用 `[]`），其他属性格式会报错；不检查普通 Markdown 链接、外链、Setext 标题或复杂格式标题的等价形式，也不判断事实是否正确。`reviewed` 仍需人工或证据核对。

## 来源不可用时

`git submodule status` 行首的 `-` 表示子模块未初始化。此时检查器报告 `SOURCE_UNAVAILABLE`，跳过该来源的文件与章节核验；不要因此删除引用或把历史内容标为已复查。需要完整核验时，先在具备来源的工作区核对版本与改动，遵循子模块保护约定，不为 Wiki 维护重置或更新来源。

## Arch Linux 配置指南

以下为可独立阅读的综合指南。设备与软件状态均有核对日期；`needs-verification` 表示仍存在实践或证据缺口。来源快照保留历史上下文，不直接作为安装成功证明。

- [Arch Linux 常用软件安装与维护](wiki/guides/Arch%20Linux%20%E5%B8%B8%E7%94%A8%E8%BD%AF%E4%BB%B6%E5%AE%89%E8%A3%85%E4%B8%8E%E7%BB%B4%E6%8A%A4.md)
- [Arch Linux 使用官网 rustup 配置与维护 Rust](wiki/guides/Arch%20Linux%20%E4%BD%BF%E7%94%A8%E5%AE%98%E7%BD%91%20rustup%20%E9%85%8D%E7%BD%AE%E4%B8%8E%E7%BB%B4%E6%8A%A4%20Rust.md)
- [GitHub 账户对应与 SSH 私有仓库使用](wiki/guides/GitHub%20%E8%B4%A6%E6%88%B7%E5%AF%B9%E5%BA%94%E4%B8%8E%20SSH%20%E7%A7%81%E6%9C%89%E4%BB%93%E5%BA%93%E4%BD%BF%E7%94%A8.md)
- [Niri 个性化 Waybar 搭建与亮度调节](wiki/guides/Niri%20%E4%B8%AA%E6%80%A7%E5%8C%96%20Waybar%20%E6%90%AD%E5%BB%BA%E4%B8%8E%E4%BA%AE%E5%BA%A6%E8%B0%83%E8%8A%82.md)

仓库 Wiki 使用 Obsidian 双向链接；GitHub 不原生解析该语法。以上入口及指南中的“来源记录”“公开阅读入口”使用标准相对链接，可直接在 GitHub 浏览。
