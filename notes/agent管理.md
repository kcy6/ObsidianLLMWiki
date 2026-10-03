推荐上下文管理，agent说明文档处理的方式，主要为嵌入式开发

10:03 PM

Worked for 50s

针对你的项目形态——树莓派视觉程序、STM32 云台固件、UART/CAN 通信以及实机烧录测试——推荐采用“短 `AGENTS.md` + 分层技术文档 + 单次任务说明”的方式。

官方建议也是：`AGENTS.md` 用于持久规则，复杂仓库使用目录级文件，越靠近当前目录的说明优先；文件应保持短小、准确，详细架构放到其他 Markdown 文档中。[Codex AGENTS.md 文档](https://learn.chatgpt.com/docs/agent-configuration/agents-md)

## 一、推荐目录结构

```
QGimbal-workspace/
├─ AGENTS.md                     # 整个工作区的共同规则
├─ docs/
│  ├─ SYSTEM_ARCHITECTURE.md     # 树莓派→UART→STM32→CAN→电机
│  ├─ HARDWARE.md                # 接线、电压、板卡、接口映射
│  ├─ PROTOCOL.md                # UART协议、命令、回复包、波特率
│  ├─ SAFETY.md                  # 烧录和电机安全要求
│  ├─ TEST_MATRIX.md             # 分层测试及通过标准
│  ├─ DECISIONS.md               # 关键技术决策及原因
│  └─ CURRENT_STATE.md           # 当前已验证状态，控制篇幅
│
├─ QGimbal/                      # STM32固件
│  ├─ AGENTS.md
│  ├─ Core/
│  ├─ Drivers/
│  └─ ...
│
├─ QGimbal-Vision/               # 树莓派视觉与云台控制
│  ├─ AGENTS.md
│  ├─ control/
│  ├─ vision/
│  └─ ...
│
└─ flask-project/
   └─ AGENTS.md                  # 可明确写“默认不处理”
```

核心原则：

- 根目录 `AGENTS.md` 只放跨工程规则。
- 固件和视觉工程分别放自己的 `AGENTS.md`。
- 协议、接线、架构等技术事实放 `docs/`。
- 日志、终端输出、临时测试结果不要大量写入 `AGENTS.md`。
- 当前任务的具体目标放在对话提示词中，不要全部固化。

## 二、不同信息放在哪里

|信息类型|推荐位置|
|---|---|
|永久执行规则、安全限制|`AGENTS.md`|
|系统架构、接口关系|`docs/SYSTEM_ARCHITECTURE.md`|
|UART命令、包结构、波特率|`docs/PROTOCOL.md`|
|GPIO、供电、电平和接线|`docs/HARDWARE.md`|
|编译、烧录和实机测试步骤|工程级 `AGENTS.md` 或 `docs/TEST_MATRIX.md`|
|已验证性能数据|`docs/CURRENT_STATE.md`|
|为什么关闭自稳、为什么用最新帧|`docs/DECISIONS.md`|
|某次具体修复要求|当前任务提示词|
|大型芯片手册、原理图|保留原文件，只在文档中标出路径和关键页码|
|可重复烧录/测试流程|后续可做成 Codex Skill 或脚本|

最重要的区分是：

> `AGENTS.md` 告诉 Agent“应该如何工作”；技术文档告诉 Agent“这个系统是什么”。

## 三、根目录 AGENTS.md 示例

```
# QGimbal workspace instructions

## 项目范围

本工作区包含：

- `QGimbal/`：STM32 云台控制固件
- `QGimbal-Vision/`：树莓派视觉检测和 UART 云台控制
- `flask-project/`：当前默认不处理，除非用户明确要求

系统链路：

摄像头 → 树莓派视觉程序 → UART → STM32 → CAN → 云台电机

详细说明：

- 架构：`docs/SYSTEM_ARCHITECTURE.md`
- 串口协议：`docs/PROTOCOL.md`
- 硬件接线：`docs/HARDWARE.md`
- 测试标准：`docs/TEST_MATRIX.md`

## 通用工作规则

1. 修改前先确认目标属于 STM32 固件还是树莓派程序。
2. 不把编译成功等同于硬件功能验证成功。
3. 不根据单次串口超时直接判断为接线故障。
4. 不随意统一项目中的波特率；115200 和 1152000 可能用于不同链路。
5. 修改通信协议时，同时检查发送端、接收端和协议文档。
6. 保留用户已有修改，不覆盖无关文件。
7. 修改完成后检查差异并创建清晰的 Git 提交。

## 硬件安全

除非用户明确授权，否则不得：

- 烧录固件
- 擦除 STM32 Flash
- 修改 Option Bytes
- 启动激光
- 让电机持续非零转速运行
- 修改树莓派启动配置并重启

实机测试结束后必须：

- 发送零速命令
- 关闭自稳
- 失能云台
- 确认激光关闭

## 完成标准

软件修改至少需要：

- 语法或编译检查通过
- 相关测试通过
- 检查 Git diff
- 报告哪些是软件验证，哪些是实机验证
- 记录尚未验证的硬件假设
```

## 四、STM32 工程 AGENTS.md 示例

````
# STM32 firmware instructions

## 工程职责

本工程负责：

- UART命令接收和回复
- 云台状态管理
- IMU、自稳和零点
- CAN电机控制
- 通信超时保护

## 修改要求

- UART协议变更前阅读 `../docs/PROTOCOL.md`。
- 不改变数据包大小、字节序或校验方式，除非任务明确要求。
- UART接收逻辑不得在中断中进行长时间阻塞。
- 所有非零速度控制必须受通信看门狗保护。
- 超过规定时间未收到有效控制包时，目标速度必须归零。
- Flash参数结构变更必须考虑旧版本兼容或明确升级方式。
- 浮点数传输必须确认双方字节序和长度一致。

## 构建与烧录

构建命令：

```text
填写实际命令
````

生成文件：

```
填写实际 HEX/ELF 路径
```

烧录不是普通构建步骤。只有用户明确要求烧录时才可调用 ST-Link。

烧录前确认：

1. MCU型号
2. ST-Link已识别
3. 固件文件路径和时间
4. 必要时备份现有Flash
5. 云台机械结构处于安全状态

## 测试顺序

1. 静态检查
2. 编译
3. UART协议测试
4. 无电机或零速测试
5. 单轴低速测试
6. 双轴和自稳测试
7. 通信断开保护测试

````

## 五、树莓派视觉工程 AGENTS.md 示例

```markdown
# Raspberry Pi vision instructions

## 运行环境

- 平台：树莓派无桌面系统
- Python环境：`.venv`
- 摄像头目标模式：640x480，实际约100 FPS
- UART设备：`/dev/serial0`
- UART波特率：以命令行参数和协议文档为准
- 网页预览：MJPEG，仅局域网调试使用

## 性能要求

主控制链路优先级：

摄像头采集 → 检测 → 控制计算 → UART发送

网页显示和日志不得阻塞主链路。

修改后至少检查：

- `CAP` 实际采集帧率
- `PROC` 实际处理帧率
- `SW` 软件处理延迟
- 网页预览是否造成帧率下降
- 是否积压旧帧
- 目标锁定后两个轴是否真正输出零速

不得使用理论循环次数冒充实际摄像头帧率。

## 控制安全

- 默认关闭激光。
- 视觉瞄准模式默认按项目设定决定是否开启 IMU 自稳。
- 目标进入锁定死区后，应复位或冻结相应轴 PID 并输出零速。
- 程序退出时必须零速、关闭自稳并失能。
- 串口线程异常必须通知主线程，不得静默退出。

## 验证

修改后运行：

```bash
python -m py_compile ...
````

再执行无窗口性能测试和必要的网页预览测试。

最终报告必须区分：

- 摄像头实际帧率
- 图像处理帧率
- 软件计算延迟
- JPEG编码延迟
- 无法由软件测得的传感器/USB/网络/机械延迟

````

## 六、CURRENT_STATE.md 应该怎么写

这个文件只保留最近已确认的系统状态，不记录全过程：

```markdown
# Current verified state

更新日期：2026-07-20
对应版本：

- QGimbal firmware: `<commit>`
- QGimbal-Vision: `e33f0ea`

## 已验证

- 摄像头640x480模式实际约99.3 FPS
- 图像处理约99.3 FPS
- 软件处理延迟约3.0–3.5 ms
- 网页预览30 FPS不影响主处理帧率
- 视觉瞄准模式关闭IMU自稳后，锁定目标不会周期漂移
- UART实际波特率配置见 `PROTOCOL.md`

## 尚未验证

- 长时间运行温度和稳定性
- UART线断开时STM32超时保护
- 树莓派突然断电时云台安全状态
- 移动底盘状态下的自稳参数
````

每次验证后只更新结论，原始日志可以放：

```
test-results/2026-07-20-camera-benchmark.log
```

不要把几千行日志直接加入上下文。

## 七、推荐的单次任务提示格式

每次交给 Agent 的任务用四段式：

```
目标：
修复UART回复偶尔不足42字节的问题。

上下文：
- `QGimbal-Vision/control/serial_stub.py`
- `docs/PROTOCOL.md`
- STM32回复固定为42字节
- 树莓派串口使用1152000，不要改成115200

约束：
- 不修改协议格式
- 不烧录固件
- 最长等待时间不超过30ms
- 退出时必须失能云台

完成标准：
- 完成代码修改
- 通过语法检查
- 使用真实UART连续测试1000次
- 报告完整包率、超时次数和最大响应时间
- 创建Git提交，但不推送
```

这正好对应官方建议的 `Goal / Context / Constraints / Done when` 四类上下文。[Codex 最佳实践](https://learn.chatgpt.com/guides/best-practices)

## 八、嵌入式项目尤其需要避免的做法

- 不要在根 `AGENTS.md` 中复制整份芯片手册。
- 不要只写“运行测试”，要写出具体命令和通过标准。
- 不要混淆“Windows本机”“树莓派SSH终端”“STM32固件环境”的命令。
- 不要让 Agent 自动把所有波特率统一成同一个值。
- 不要默认允许烧录、重启、修改启动项和驱动电机。
- 不要把旧测试结果当成当前固件的事实，必须记录对应 Git commit。
- 不要用一个巨大的 `AGENTS.md` 管理所有子工程。
- 不要把临时调参值过早写成永久规范。

对当前 QGimbal 项目，最合适的是：一个约 50–100 行的根 `AGENTS.md`，两个工程各自一个约 50–120 行的嵌套 `AGENTS.md`，其余事实拆入 `docs/`。这样上下文足够完整，又不会每次任务都消耗大量上下文。

10:04 PM

怎么做上下文和多agent管理呢，例如保存曾经处理过的问题，讨论过的方案怎么留痕，怎么开多agent协同工作，实现需求后进行记录方便后续复用

10:30 PM

Worked for 39s

推荐把整个过程设计为：

> Git 仓库是长期记忆，Codex 对话只是工作现场；主 Agent 负责决策和集成，子 Agent 负责独立调查、实现或验证。

不要尝试永久保存所有对话。应该把有复用价值的内容提炼为结构化文档，并和代码版本关联。

## 1. 上下文分四层管理

建议目录：

```
QGimbal-workspace/
├─ AGENTS.md
├─ .codex/
│  └─ agents/
│     ├─ firmware_explorer.toml
│     ├─ vision_explorer.toml
│     ├─ protocol_reviewer.toml
│     └─ hardware_verifier.toml
│
├─ docs/
│  ├─ CURRENT_STATE.md
│  ├─ SYSTEM_ARCHITECTURE.md
│  ├─ PROTOCOL.md
│  ├─ HARDWARE.md
│  ├─ SAFETY.md
│  │
│  ├─ issues/
│  │  ├─ QG-001-uart-short-read.md
│  │  ├─ QG-002-camera-fps-error.md
│  │  └─ QG-003-gimbal-lock-drift.md
│  │
│  ├─ adr/
│  │  ├─ 0001-use-latest-frame-only.md
│  │  ├─ 0002-disable-stability-in-vision-mode.md
│  │  └─ 0003-use-mjpeg-preview.md
│  │
│  ├─ runbooks/
│  │  ├─ build-firmware.md
│  │  ├─ flash-with-stlink.md
│  │  ├─ uart-diagnosis.md
│  │  └─ camera-benchmark.md
│  │
│  └─ tasks/
│     ├─ active/
│     └─ completed/
│
├─ test-results/
│  └─ 2026-07-20-camera-benchmark.log
│
├─ QGimbal/
│  └─ AGENTS.md
└─ QGimbal-Vision/
   └─ AGENTS.md
```

四层分别承担：

|层级|内容|是否经常载入|
|---|---|---|
|`AGENTS.md`|工作规则、安全边界、验证要求|自动/长期|
|`CURRENT_STATE.md`|当前版本、已验证能力、已知问题|每次任务开始|
|Issue、ADR、Runbook|相关问题、决策和操作步骤|按任务读取|
|原始日志、手册、数据|完整证据|需要时搜索|

不要让 Agent 每次读取所有历史问题和全部日志，否则容易产生上下文污染。

## 2. 不同记录该放在哪里

### Issue：记录一个问题的完整处理过程

例如：

```
docs/issues/QG-003-gimbal-lock-drift.md
```

适合保留：

- 问题现象
- 复现条件
- 调查过的假设
- 排除过的原因
- 最终根因
- 修改方案
- 实机验证结果
- 对应提交
- 尚未解决的问题

### ADR：记录“为什么这样设计”

ADR 是 Architecture Decision Record，适合保存有取舍的决定，例如：

- 为什么视觉瞄准模式默认关闭 IMU 自稳
- 为什么不用摄像头读取线程
- 为什么网页预览采用 MJPEG
- 为什么保留115200和1152000两种波特率
- 为什么只处理最新帧

Issue 关注“问题怎么解决”，ADR 关注“为什么选择这个设计”。

### Runbook：保存以后还会重复执行的操作

例如：

- 如何编译STM32固件
- 如何用ST-Link备份和烧录
- 如何检查UART
- 如何测试摄像头100 FPS
- 如何安全启动云台
- 如何在测试后失能电机

### CURRENT_STATE：给新任务快速接手

这个文件只保留当前有效结论：

```
# Current state

更新时间：2026-07-20

## 当前版本

- Firmware: `<commit>`
- Vision: `e33f0ea`

## 已验证

- 摄像头640×480实际约99.3 FPS
- 主循环处理约99.3 FPS
- 软件处理延迟约3.0–3.5ms
- 网页输出30 FPS不影响主循环
- 视觉模式关闭IMU自稳后可以稳定锁定
- 网页地址为 `http://<pi-ip>:8080`

## 当前配置

- Raspberry Pi UART: `/dev/serial0`
- Python端波特率：以运行参数为准
- 固件内部不同接口可能分别使用115200和1152000
- 视觉模式：`--stability 0`
- 最大转速：3 RPM

## 已知风险

- STM32通信超时保护仍需最终断线验证
- 网页服务没有认证，仅限可信局域网
- 软件SW延迟不包含曝光、USB和机械响应

## 下一步

1. 验证UART断线保护
2. 进行长时间运行测试
3. 测量摄像头到物理运动的端到端延迟
```

它不应该变成流水账，已经过时的内容应移到 Issue 或 Git 历史中。

## 3. Issue记录模板

建议统一使用下面的格式：

````
# QG-003 云台锁定后周期性漂移

状态：Resolved
创建日期：2026-07-20
解决日期：2026-07-20
涉及工程：QGimbal-Vision、QGimbal
对应提交：7900a15
硬件版本：填写板卡版本
固件版本：填写commit或HEX哈希

## 现象

目标已经位于锁定死区内，但云台仍然周期性上下左右移动。

## 复现条件

- 分辨率：640×480
- 摄像头实际帧率：约99.3 FPS
- `--stability 1`
- 目标静止
- `lock=1/1`

## 初始假设

1. PID积分未清零
2. 摄像头积帧
3. 检测中心抖动
4. IMU积分漂移
5. 串口回复延迟

## 实验记录

| 实验 | 改动 | 结果 | 结论 |
|---|---|---|---|
| 1 | 锁定后强制输出零速 | 仍有周期运动 | 不只是PID输出 |
| 2 | 关闭网页预览 | 问题仍存在 | 与网页无关 |
| 3 | `--stability 0` | 保持稳定 | 与IMU自稳有关 |
| 4 | 观察目标误差 | 约±1px | 视觉检测稳定 |

## 根因

视觉控制和IMU自稳同时修正云台位置。BMI088积分漂移导致自稳产生慢速补偿，
视觉控制随后反向纠正，形成周期运动。

## 最终方案

视觉瞄准模式默认：

```text
--stability 0
````

移动底盘模式才单独评估开启自稳。

## 验证结果

- 连续运行：8分钟
- `lock=1/1`
- 目标误差：约±1px
- 输出速度：0 RPM
- 未观察到周期漂移

## 未解决事项

- 移动底盘模式下需要重新设计视觉控制与姿态补偿融合方式。

````

关键是保留“失败实验”。否则未来 Agent 很容易重新尝试已经排除的方案。

## 4. ADR记录模板

```markdown
# ADR-0002 视觉瞄准模式默认关闭IMU自稳

状态：Accepted
日期：2026-07-20

## 背景

视觉跟踪和IMU自稳会同时作用于Yaw/Pitch控制。

## 可选方案

### 方案A：视觉模式继续开启自稳

优点：

- 对底盘姿态变化有补偿

缺点：

- IMU漂移会与视觉闭环互相对抗
- 静止目标可能产生周期运动

### 方案B：视觉模式关闭自稳

优点：

- 控制链路单一
- 静止目标锁定更稳定

缺点：

- 无法主动补偿底盘姿态变化

## 决定

视觉瞄准模式默认关闭自稳。

## 适用范围

- 静止或低扰动安装平台
- 基于图像误差的目标跟踪

## 不适用范围

- 高动态移动底盘
- 必须依赖姿态前馈的场景

## 后果

未来若支持移动底盘，需要融合视觉误差和IMU姿态，而不是简单同时打开两个闭环。
````

## 5. 一个标准任务的生命周期

建议每个需求按下面的闭环执行：

```
提出需求
  ↓
创建任务说明
  ↓
并行调查
  ↓
主Agent汇总结论
  ↓
确定方案/记录ADR
  ↓
实现代码
  ↓
编译与软件测试
  ↓
实机验证
  ↓
独立复查
  ↓
更新Issue、Runbook、CURRENT_STATE
  ↓
Git提交
```

### 第一步：创建任务包

```
docs/tasks/active/QG-004-uart-watchdog.md
```

内容：

```
# QG-004 STM32 UART超时保护

## 目标

超过300ms未收到有效控制包时，让两个轴目标速度归零并停止输出。

## 范围

- STM32 UART解析
- 云台控制状态机
- 通信时间戳

## 不在范围内

- 修改树莓派视觉算法
- 修改UART包格式
- 修改CAN驱动
- 修改Flash参数结构

## 约束

- 不得在UART中断中阻塞
- 只接受校验通过的数据包作为有效通信
- 上电尚未收到第一个控制包时保持失能
- 烧录和电机测试必须单独获得授权

## 完成标准

- 固件编译通过
- 正常控制不受影响
- 断开UART后300ms内速度归零
- UART恢复后按设计重新进入控制状态
- 更新协议或安全文档
```

完成后移动到：

```
docs/tasks/completed/
```

## 6. 多Agent如何分工

嵌入式项目推荐使用“一个主Agent + 三类子Agent”。

### 主Agent

负责：

- 理解用户需求
- 拆分任务
- 管理安全边界
- 汇总子Agent发现
- 决定最终方案
- 集成代码
- 组织验证
- 更新记录
- 创建提交

主 Agent 应保留干净上下文，尽量只接收子 Agent 的结论，不接收海量日志。

### 调查Agent

分别调查：

- STM32固件
- 树莓派视觉程序
- UART协议与跨工程一致性
- 硬件和安全风险

默认只读，不修改代码。

### 实现Agent

只负责一个明确范围：

- 一个工程
- 一个目录
- 一组互不冲突的文件

不要让两个 Agent 同时修改相同文件。

### 验证Agent

独立检查：

- 修改是否真正解决需求
- 是否引入竞态或阻塞
- 协议两端是否一致
- 是否存在电机、激光和烧录风险
- 测试证据是否充分

官方也建议先把多 Agent 用在代码探索、测试、分类和总结等只读工作上；多个 Agent 同时大量写代码更容易产生冲突。[Codex Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)

## 7. 适合QGimbal的多Agent任务拆分

例如实现“STM32 UART超时保护”：

### 阶段一：三个Agent并行调查

```
Agent A：固件调查
- 找到UART接收入口
- 找到速度目标保存位置
- 找到控制循环周期
- 不修改文件

Agent B：树莓派调查
- 确认控制包发送频率
- 确认串口线程异常行为
- 确认程序退出动作
- 不修改文件

Agent C：安全审查
- 分析UART断线、树莓派崩溃、重启的失效状态
- 给出超时时间和恢复策略建议
- 不修改文件
```

### 阶段二：主Agent决定方案

主 Agent 汇总：

- 哪个时钟可用
- 在哪里更新时间戳
- 超时作用于速度还是整个使能状态
- 通信恢复是否自动重新使能
- 200ms还是300ms
- 是否影响校准和固件升级命令

### 阶段三：一个Agent实现

只让一个 Agent 修改 STM32 工程，避免竞争。

### 阶段四：两个Agent独立验证

```
Agent D：审查固件diff和边界条件
Agent E：设计实机测试矩阵
```

最后由主 Agent 执行或组织实机验证。

## 8. 可以直接使用的多Agent提示词

```
这个任务涉及STM32固件和树莓派视觉程序。

先不要修改代码。请启动3个并行子Agent：

1. firmware-investigator
   只读分析STM32 UART接收、控制状态机和速度输出位置。

2. vision-investigator
   只读分析树莓派控制包发送频率、串口线程和退出动作。

3. safety-reviewer
   只读分析UART断线、树莓派崩溃和系统重启的危险状态。

要求：

- 三个Agent都先读取根目录及各自工程的AGENTS.md。
- 不烧录、不重启、不驱动电机。
- 不允许修改文件。
- 每个Agent返回：相关文件、关键调用链、发现、风险、推荐方案、
  未确认事项。
- 等待三个Agent全部完成后，由主Agent汇总。
- 主Agent在汇总前不要实施修改。
```

实施阶段：

```
基于已确认方案，只启动一个实现Agent修改STM32固件。

约束：

- 只允许修改已经确认的固件文件。
- 不修改协议包格式。
- 不修改树莓派工程。
- 完成后运行编译，但不要烧录。
- 返回修改文件、关键逻辑、编译结果和剩余风险。

实现完成后，再启动一个独立reviewer审查diff。
```

## 9. 项目级自定义Agent

Codex支持在项目的 `.codex/agents/` 中定义自定义 Agent；至少包含 `name`、`description` 和 `developer_instructions`。也可以指定模型、推理强度和只读权限。[Codex自定义Agent](https://learn.chatgpt.com/docs/agent-configuration/subagents)

例如：

```
# .codex/agents/protocol_reviewer.toml

name = "protocol_reviewer"
description = "检查树莓派与STM32之间的UART协议一致性和通信安全。"
sandbox_mode = "read-only"
model_reasoning_effort = "high"

developer_instructions = """
你是QGimbal协议审查Agent。

主要职责：
- 对比树莓派发送端和STM32接收端。
- 检查命令编号、数据长度、包长度、校验、字节序和超时。
- 明确区分115200和1152000，不得擅自统一波特率。
- 检查无效包、短包、丢包和断线后的状态。
- 不修改文件。
- 不执行烧录、重启或电机测试。

结果必须包含：
1. 涉及文件和函数
2. 协议字段对应表
3. 不一致项
4. 安全风险
5. 推荐修改
6. 尚需实机确认的内容
"""
```

固件调查 Agent：

```
# .codex/agents/firmware_explorer.toml

name = "firmware_explorer"
description = "只读调查QGimbal STM32固件的控制流、通信和硬件驱动。"
sandbox_mode = "read-only"
model_reasoning_effort = "high"

developer_instructions = """
只读分析STM32固件。

重点关注：
- 中断与主循环边界
- UART DMA/中断接收
- 控制状态机
- IMU更新
- CAN电机输出
- Flash参数
- 通信超时和失效安全

不得修改、编译、烧录或操作硬件。
返回精简结论和精确文件位置，不返回大段源码。
"""
```

验证 Agent：

```
# .codex/agents/hardware_verifier.toml

name = "hardware_verifier"
description = "设计和审查嵌入式实机验证步骤。"
model_reasoning_effort = "high"

developer_instructions = """
负责验证设计，不默认执行危险动作。

必须区分：
- 静态检查
- 编译验证
- 软件模拟
- UART实机测试
- 电机实机测试
- 长时间稳定性测试

烧录、重启、激光和电机运动需要用户明确授权。
测试结果必须包含环境、版本、命令、观测结果和通过标准。
"""
```

## 10. 把多Agent规则写进根AGENTS.md

```
## Multi-agent policy

跨越固件、视觉和通信协议的任务，优先采用以下流程：

1. 主Agent创建任务范围和完成标准。
2. 并行启动只读调查Agent：
   - 固件调查
   - 视觉调查
   - 协议或安全审查
3. 等待全部调查完成，由主Agent统一决策。
4. 同一文件或同一模块只允许一个Agent负责修改。
5. 并行写入只允许发生在完全独立的工程或目录。
6. 所有修改完成后必须由独立reviewer检查。
7. 只有主Agent负责最终集成、Git提交和任务关闭。

子Agent返回格式：

- Scope
- Files inspected
- Findings
- Evidence
- Risks
- Recommendation
- Unresolved questions

所有Agent禁止自行：

- 烧录固件
- 重启树莓派
- 修改启动配置
- 驱动电机
- 开启激光
- 执行长时间硬件测试
```

这样以后你只需说：

```
按AGENTS.md中的多Agent流程分析并实现这个需求。
```

Codex就能按照项目约定拆分。

## 11. 如何把处理结果沉淀下来

每次功能完成后，主 Agent 必须做一个“上下文收尾”：

```
[ ] 更新对应Issue的根因、方案和验证结果
[ ] 有架构取舍则新增或更新ADR
[ ] 有可重复步骤则更新Runbook
[ ] 更新CURRENT_STATE的当前版本和已验证状态
[ ] 保存必要的原始测试日志
[ ] 记录固件、视觉工程的Git commit
[ ] 删除或标记已经失效的结论
[ ] 创建原子Git提交
```

建议提交信息带问题编号：

```
QG-003 修复视觉锁定后的周期漂移
QG-003 记录自稳与视觉闭环冲突决策
QG-004 增加UART控制超时保护
```

Issue中再反向引用：

```
相关提交：

- Firmware: `abc1234`
- Vision: `7900a15`
- Documentation: `def5678`
```

这样可以从“问题→方案→代码→测试”双向追踪。

## 12. 最重要的管理原则

- 对话不是项目事实来源，Git文档才是。
- 保存结论和证据，不保存所有闲聊。
- 被否决的方案要记录原因，避免重复踩坑。
- 每条测试结论必须绑定代码版本、硬件版本和运行参数。
- 主 Agent 管理需求和决策，子 Agent 隔离噪声。
- 优先并行调查和审查，谨慎并行修改代码。
- 同一个文件只交给一个写入 Agent。
- 烧录和实机运动始终作为独立授权阶段。
- `AGENTS.md` 保持短小；细节放 Issue、ADR 和 Runbook。
- 每完成一个需求，都执行一次文档收尾。

这套方式能让后续 Agent 即使没有看到以前的聊天，也能通过 `AGENTS.md → CURRENT_STATE → 相关Issue/ADR → 代码和测试证据` 快速恢复上下文。