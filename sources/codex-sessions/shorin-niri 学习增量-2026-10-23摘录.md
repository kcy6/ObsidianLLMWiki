# shorin-niri 学习增量

会话 ID：`01a162f1-41b8-7c63-a018-3ba8b4eabbfc`。2026-10-23 从本机持久会话日志提取用户消息与 assistant final_answer；不含工具输出、推理、图片与临时侧聊。仅保存当前可见日志增量，不把历史助手声明当作独立验证。为公开阅读替换本机路径并隐藏代理出口；原会话不变。

## 用户

```arduino
default-column-width { proportion 0.66667; }
gaps 16
```


## 助手

正确，这两行都应放在 `layout { ... }` 内：

```kdl
layout {
    default-column-width { proportion 0.66667; }
    gaps 16
}
```

在现有文件中修改对应值即可，无需再添加一个 `layout` 块。代码块标记用 `kdl` 更准确。

接下来学习**窗口规则**。项目的 `rule.kdl` 中有：

```kdl
window-rule {
    opacity 0.97
}

window-rule {
    match app-id="mpv"
    opacity 1.0
}
```

第一条没有 `match`，对所有窗口设置透明度；第二条匹配 `app-id` 为 `mpv` 的窗口，将其设为完全不透明。

如果希望 **Kitty 终端完全不透明**，参照第二条，你会怎样写？

## 用户

```python
window-rule {
    match app-id="kitty"
    opacity 1.0
}
```


## 助手

对，这条规则会将 `app-id` 匹配 `kitty` 的窗口设为完全不透明：

```kdl
window-rule {
    match app-id="kitty"
    opacity 1.0
}
```

把它放在全局透明度规则之后即可。代码内容正确，代码块标记应使用 `kdl`。

这里还有一个关键点：**`app-id` 是应用向桌面报告的标识，不一定等于程序名。** 项目启动临时终端时使用：

```kdl
spawn "kitty" "--single-instance" "--class" "quickterminal";
```

`--class "quickterminal"` 会让这个 Kitty 窗口使用 `quickterminal` 作为 app-id，方便单独设置窗口规则。

如果只想让这个临时终端**浮动打开且完全不透明**，你会怎样写？提示：浮动配置是 `open-floating true`。

## 用户

window-rule {
    match app-id="kitty"
    opacity 1.0
    open-floating true
}


## 助手

`opacity` 和 `open-floating` 都写对了。需要将匹配目标改为 `quickterminal`：

```kdl
window-rule {
    match app-id="quickterminal"
    opacity 1.0
    open-floating true
}
```

因为启动命令中的 `--class "quickterminal"` 为这个临时终端指定了独立的 app-id。你原来的规则会匹配普通 Kitty 窗口。

现在你已经掌握了三层关系：**快捷键启动程序 → 启动参数指定窗口标识 → 窗口规则匹配标识并设置行为**。

## 用户

用niri msg pick-window不久好了吗为什么要设置spawn "kitty" "--single-instance" "--class" "quickterminal";


## 助手

对，**用 `niri msg pick-window` 可以查看已有窗口的 app-id**，写规则前这样确认很合适。我之前省略了这个步骤。

但查看标识与指定标识是两个用途：

- `niri msg pick-window`：查看窗口已经使用的 app-id。
- `--class "quickterminal"`：启动时主动给这个窗口指定独立的 app-id。

如果所有 Kitty 窗口都使用 `kitty`，规则就难以区分“普通终端”和“临时终端”。指定不同标识后，可以分别配置：

```kdl
// 普通终端保持平铺
window-rule {
    match app-id="^kitty$"
    open-floating false
}

// 临时终端浮动打开
window-rule {
    match app-id="^quickterminal$"
    open-floating true
}
```

所以，**如果你希望所有 Kitty 都采用相同行为，直接查看 app-id 后写规则就够了；只有需要区分用途时，才有必要指定 `--class`。**

另外，`--single-instance` 是 Kitty 的进程复用选项，与窗口规则匹配是独立的，也不表示只允许打开一个窗口。

## 用户

下一步


## 助手

下一步学习 **配置如何从项目进入你的桌面**。先理解这条路径，后面修改才不会改错地方。

这个项目存在三份用途不同的文件：

| 位置 | 用途 |
|---|---|
| 克隆仓库中的 `dotfiles/` | 项目源码，供阅读和修改 |
| `/usr/share/shorin-niri/` | 安装软件包后提供的部署模板 |
| `~/.config/niri/` 等目录 | 当前桌面实际读取的配置 |

`shorinniri` 脚本负责把部署模板复制到你的家目录。看 脚本中的路径定义（本地路径，见上下文）：

```bash
TEMPLATE_DIR="/usr/share/shorin-niri"
```

因此，**修改刚克隆仓库里的 `dotfiles/.config/niri/layout.kdl`，不会直接改变当前桌面**；脚本默认也不会从这个克隆目录读取模板。

再看两种部署操作：

- `init`：全量复制模板，已有目标文件先备份。
- `update`：先读取保护规则，跳过受保护的路径，再复制其他文件。

这个项目默认保护整个 `.config/niri`，所以执行 `update` 通常不会覆盖你已经修改的 Niri 配置。

先做一道判断题：你修改了 `~/.config/niri/binds.kdl`，随后执行 `shorinniri update`，按照当前项目的默认规则，这些快捷键修改会被覆盖吗？

## 用户

不会


## 助手

对，`binds.kdl` 位于内置保护目录 `.config/niri` 下，`update` 会跳过它。

现在进一步看脚本**怎样判断路径受保护**：

```bash
is_ignored() {
    local target_path="$1"
    local ignore_rule
    for ignore_rule in "${ALL_IGNORES[@]}"; do
        if [[ "$target_path" == "$ignore_rule" ||
              "$target_path" == "$ignore_rule/"* ]]; then
            return 0
        fi
    done
    return 1
}
```

这里有三个 Bash 知识点：

- `"$1"`：函数收到的第一个参数，例如 `.config/niri/binds.kdl`。
- `"${ALL_IGNORES[@]}"`：逐项遍历保护规则数组。
- `return 0`：表示判断成功，也就是“该路径受保护”；`return 1` 表示未匹配。

匹配条件分为两种：

```bash
"$target_path" == "$ignore_rule"      # 路径本身
"$target_path" == "$ignore_rule/"*    # 目录下的子路径
```

第二种特意加了 `/`，因此规则 `.config/niri` 会保护 `.config/niri/binds.kdl`，却不会误匹配 `.config/niri-backup/binds.kdl`。

小练习：如果保护规则是 `.config/waybar`，那么 `.config/waybar/scripts/screenshot.sh` 会被保护吗？

## 用户

会


## 助手

对，`.config/waybar/scripts/screenshot.sh` 以 `.config/waybar/` 开头，所以受保护。

接着看**同步函数怎样使用这个判断**：

```bash
if [[ "$mode" == "update" ]] && is_ignored "$rel_path"; then
    ((skip_count++))
    continue
fi

backup_and_copy "$TEMPLATE_DIR" "$rel_path"
```

按执行顺序理解：

1. 判断当前是否为 `update` 模式。
2. 如果是，再调用 `is_ignored` 检查当前文件。
3. 匹配保护规则，就增加跳过计数，并用 `continue` 进入下一轮循环。
4. 其余文件交给 `backup_and_copy` 备份并复制。

这里的 `&&` 是**短路执行**：左侧成功，才执行右侧。因此 `init` 模式连 `is_ignored` 都不会调用。

这也意味着：**保护规则只防止 `update` 覆盖配置，不能阻止 `init` 覆盖。**

下一步我们读 `backup_and_copy`，看看它怎样把旧配置备份，再部署新文件。

## 用户

继续，引导我思考，完成一次任务后安排下一次，不要我再提示继续


## 助手

好，之后每轮你完成练习，我会直接讲解结果并安排下一项；遇到理解偏差，就先用一个小例子帮你弄清楚。

现在读 backup_and_copy 函数（本地路径，见上下文）。先看路径构造：

```bash
local base_dir="$1"
local rel_path="$2"
local src_file="$base_dir/$rel_path"
local dest_file="$HOME/$rel_path"
local dest_dir="$(dirname "$dest_file")"
```

假设传入：

```bash
base_dir="/usr/share/shorin-niri"
rel_path=".config/waybar/config.jsonc"
HOME="~"
```

同一个 `rel_path` 接在不同根目录后面，就把模板文件与用户配置对应起来。`dirname` 则取出文件所在的目录，供后面的 `mkdir -p` 创建。

本轮任务：写出这三个变量最终的值：

```text
src_file = ?
dest_file = ?
dest_dir = ?
```

完成后，我们接着分析“目标文件已经存在”时的备份流程。
