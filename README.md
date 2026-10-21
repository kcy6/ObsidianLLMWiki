# LLMWiki

这是一个在原始笔记和剪藏之上持续维护综合知识的 Obsidian 仓库。

从 [知识库首页](wiki/index.md) 开始，查看 [来源台账](wiki/sources.md) 和 [维护日志](wiki/log.md)。AI 的维护约定见 [wiki/AGENTS.md](wiki/AGENTS.md)。

| 位置 | 用途 |
| --- | --- |
| `notes/`、`Clippings/`、专题目录、`错误排查/` | 原始笔记与文章，默认只读 |
| `sources/` | 外部来源；Shorin 教程是独立 Git 子模块 |
| `wiki/` | 主题、概念、流程、问题及综合结论 |
| `附件/`、`Whiteboard/`、`.obsidian/` | 正在使用的附件、画板和 Obsidian 配置 |
| `scripts/` | 只读维护工具 |

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
