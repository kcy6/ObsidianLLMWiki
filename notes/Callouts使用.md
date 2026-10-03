# 标识符

| **类型标识符**                                    | **颜色** | **建议用途**  |
| -------------------------------------------- | ------ | --------- |
| `[!note]` / `[!info]`                        | 蓝色     | 普通备注、额外信息 |
| `[!hint]` / `[!important]`                   | 绿色     | 技巧、核心要点   |
| `[!warning]` / `[!caution]` / `[!attention]` | 黄色     | 重点关注、潜在风险 |
| `[!failure]` / `[!danger]` / `[!error]`      | 红色     | 错误警告、危险操作 |
| `[!question]` / `[!help]`                    | 紫色     | 疑问、待解决的问题 |
| `[!quote]` / `[!cite]`                       | 灰色     | 引用文献、他人观点 |
| `[!example]`                                 | 紫色     | 代码示例、案例演示 |
| `[!abstract]` / `[!summary]` / `[!tldr]`     | 青色     | 摘要、简述     |


# 折叠功能

这是 Callouts 最实用的功能，非常适合在 PID 笔记中隐藏复杂的公式或代码，保持页面整洁。

- **默认折叠（点击展开）**：在类型后面加一个减号 **`-`**。   
- **默认展开（点击折叠）**：在类型后面加一个加号 **`+`**。

**示例：**

> [!example]- 点击查看 PID C语言伪代码
> ```c
> float error = setpoint - pv;
> output = kp * error + ki * integral + kd * derivative;
> ```

# 嵌套用法

你可以在一个 Callout 里面再放一个 Callout。这在处理复杂逻辑时非常有用。

**示例：**

> [!info] 控制系统概览
> 控制系统分为开环和闭环。
> > [!tip] 核心区别
> > 闭环系统拥有反馈环节（Feedback）。
# 快捷方式

> [!abstract] 核心定义
> 这里写传感器原理或算法定义（如：什么是积分饱和？）。

> [!example]+ 代码实现 (C语言)
> ```c
> // 增量式 PID 伪代码
> float error = setpoint - feedback;
> float duty = Kp * (error - last_error) + Ki * error + Kd * (error - 2*last_error + prev_error);
> ```

> [!tip] 调参技巧
> 先调 **P** 到震荡，再调 **D** 抑制震荡，最后加 **I** 消除静差。

> [!warning] 硬件风险
> 注意：$K_p$ 过大会导致电机堵转或驱动电路发热。




