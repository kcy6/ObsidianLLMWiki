---
type: question
status: draft
updated: 2026-10-04
sources:
  - AGENTS.md
  - wiki/AGENTS.md
  - wiki/index.md
  - wiki/sources.md
  - wiki/log.md
  - .obsidian/app.json
  - .gitmodules
---

# LLM Wiki 仓库结构评估

评估对象为 `D:/Obsidian/LLMWiki`，检查跨 2026-10-03 至 2026-10-04。下述统计为新增本报告前的快照。参考 [Karpathy 的 LLM Wiki 原文](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)，未将评论区建议视为原文要求。

## 判断依据与结论

原文强调原始来源、持久化 Wiki 和维护规则三层，以及收录、问答回写、健康检查三个工作流；目录形式可以因人而异。因此本库结构总体合理，适合保留现有来源位置，逐步提升综合内容和维护闭环，无需为了统一外观迁移到 raw/。

根目录规则将笔记、剪藏、专题目录和子模块定义为来源；[[wiki/AGENTS|Wiki 规则]]约束综合层。[[wiki/index|索引]]、[[wiki/sources|来源台账]]、[[wiki/log|日志]]分工清晰。topics、concepts、guides、questions 已能容纳当前内容，不必提前增加实体目录或数据库。

## 检查结果

| 范围 | 观察 |
| --- | --- |
| 来源 Markdown | notes 48、Clippings 14、错误排查 2、MPU6050 专题 7、Fedora 专题 7、sources 44，共 122 个文件；文件数不等于独立来源数 |
| Wiki | 10 个 Markdown，含规则 1、管理页 3、内容页 6；内容集中在 Arch/Niri 和 MPU6050 两条主题线 |
| 链接 | 96 处非嵌入式双链通过目标存在性检查；带章节引用通过标题精确匹配检查 |
| 元数据 | 除 AGENTS.md 外的 9 页均包含 type、status、updated、sources 字段；此项检查仅确认字段存在 |
| 导航 | 6 个内容页均由 index 链接，内容页之间已有主题与问题关联 |
| 收录 | 台账列 12 项，清楚区分全文与部分章节；不能把 12/122 解释为完成率 |
| 附件与画布 | 附件目录 685 个文件，Whiteboard 2 个 Canvas；本次未逐图检查或验证全库嵌入 |
| 来源版本 | 子模块 HEAD 为 d8772456749981c0de3417a84c2783578603cfc6，与台账相同；当前子模块工作区干净 |

本次完整阅读 Wiki 内容，检查目录、配置与子模块状态，并抽查剪藏元数据；未逐篇审核 122 个来源、技术命令时效或全部事实。未修改来源、子模块、附件和 Obsidian 配置。

## 优先优化

### P1：把来源台账变成可跟踪的收录队列

现有“待处理”只列大类，不能直接确定下一篇。建议在现有台账增加明确状态（pending、partial、ingested、needs-recheck）、上次处理日期、已读范围和下一步。来源处理状态应与 Wiki 的 draft、reviewed、needs-verification 分开。

个人笔记持续变化，收录时应记录文件内容哈希或可定位的 Git 版本；子模块记录提交，存在未提交改动时补文件哈希。来源改变后先标记依赖页待复核，避免自动宣称全部过时。台账中的“工作区有未提交改动”是旧状态，建议注明“首次收录时”，另记本次检查结果；历史日志保留原样。

### P1：明确人工新笔记入口

`.obsidian/app.json` 中 newFileLocation 为 current，虽然 newFileFolderPath 写着 notes，当前策略仍按所在目录创建。建议在 Obsidian 中把新笔记默认位置设为 notes，避免浏览 Wiki 时将手写草稿混入综合层。该建议尚未执行。

来源台账的“可修改笔记”建议改称“个人原始笔记”，与根目录要求的“AI 默认只读、用户明确要求才修改”保持一致。

### P1：增加可重复的轻量检查

建议未来添加 scripts/lint-wiki.ps1，检查 Wiki 目标与章节链接、必要 YAML 字段和允许值、sources 路径、索引覆盖及来源指纹变化。AGENTS.md 是规则文件，应明确豁免页面元数据；index、sources、log 等管理页允许 sources 为空。事实矛盾、引用是否真正支持结论仍需人工或模型阅读复核。

每次收录后运行检查并追加日志即可。当前 Wiki 内容只有 6 页，优先用索引与文本搜索；出现检索瓶颈后再评估搜索基础设施。

### P2：优先深化两条现有主题

当前内容已有跨来源综合：姿态数据概念页区分表示方式与处理路径，并保留“9 轴”的疑问；Niri 页面比较发行版间复用条件。接下来应围绕实际问题补证据，例如核实 DMP 的驱动与坐标约定，或验证一组 Niri 配置。不要把每篇来源简单复制成一个摘要页。

questions 可补问题状态、缺失证据、解决后回写目标。guides 当前存放阅读路线，而维护规则描述为可执行流程；可在规则中允许 reading-route 与 procedure 两类，或明确每篇指南的性质，无需立即迁移文件。

### P2：区分空白、修订版本和重复来源

发现 5 个零字节 Markdown：notes/.clang-format.md、notes/.clang-format参考.md、notes/单片机不支持浮点运算.md、notes/Linux代理配置.md、角度传感器-姿态解算MPU6050/MPU6050姿态解算.md。收录时标为占位，不作事实依据，不因为空就自动删除。

两篇 Shadowsocks 剪藏标题相近，但 source 分别指向早期博客与 IMC20 论文页面，应记录版本关系，不能仅凭名称去重。此观察仅基于元数据和开头说明，不代表完成内容比较。

### P3：按增长需要再拆目录

维持当前 topics/concepts/guides/questions。来源台账变得难以阅读时，再在 wiki 下增加逐来源卡片，由 sources.md 做导航；卡片存版本、已读范围和依赖页，避免机械复制原文。只有出现稳定的实体检索需求时才增加 entities。

附件已统一存入“附件”，可以继续沿用；未来清理必须同时检查 Markdown 嵌入、HTML 引用和 Canvas。Obsidian 配置与插件文件的 Git 跟踪已有明确策略，本次无需调整。

## 建议执行顺序

1. 完善来源台账状态、版本信息及具体待处理队列。
2. 明确新笔记入口、元数据豁免与 reviewed 的判定条件。
3. 增加轻量检查并记录检查范围。
4. 选择一个 DMP 或 Niri 问题完成“补证据—修订概念/指南—关闭问题”的闭环。

相关：[[wiki/index|知识库首页]] · [[wiki/sources|来源台账]] · [[wiki/log|维护日志]]
