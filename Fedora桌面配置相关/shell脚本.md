# shell

```bash
set -euo pipefail
-e #某个命令失败时，通常立即终止脚本
-u #使用未定义变量时报错
-o pipefail #针对管道符,通常一串管道符指令只判断最后一个是否执行成功来确定整条语句的成功失败,添加该参数后会对每一小节判断,更严格
```






# Bash 脚本：Obsidian 备份、迁移与安装

以 `backup-obsidian.sh`、`restore-obsidian.sh`、`install-obsidian.sh` 为例，整理使用方法和代码知识点。对应脚本版本：2026-09-22。

## 一、三个脚本如何配合

```text
旧电脑：backup-obsidian.sh
  └─ 生成迁移包：笔记库＋图标＋安装脚本＋恢复脚本＋校验清单
                  ↓ 整体复制到新电脑
新电脑：restore-obsidian.sh
  ├─ 校验文件、检查目标目录
  ├─ 调用 install-obsidian.sh 安装程序和菜单入口
  └─ 复制笔记库到目标目录
```

| 脚本 | 作用 |
| --- | --- |
| `backup-obsidian.sh` | 复制笔记库、收集迁移文件、生成校验清单 |
| `restore-obsidian.sh` | 校验迁移包，调用安装脚本，恢复笔记库 |
| `install-obsidian.sh` | 下载程序、处理图标、创建菜单入口，也可用于更新 |

> [!important]
> 自动安装和恢复面向常规 Fedora x86_64／ARM64，不支持 Fedora Atomic。先关闭 Obsidian，以普通用户运行；只有安装依赖时调用 sudo。脚本提示关闭程序，但不会自动检测或关闭 Obsidian。

## 二、使用方法

### 旧电脑备份

先将三个脚本放在同一目录。在该目录打开终端执行：

```bash
bash backup-obsidian.sh "$HOME/Documents/Obsidian备份"
```

默认笔记库是 `~/Documents/Obsidian/master/`。也可依次指定备份输出目录、笔记库和图标：

```bash
bash backup-obsidian.sh \
  "$HOME/Documents/Obsidian备份" \
  "$HOME/Documents/Obsidian/master" \
  "$HOME/.local/share/icons/obsidian.svg"
```

输出目录不能放在笔记库内部。生成的目录结构：

```text
Obsidian迁移备份-日期-时间-进程号/
├── master/                 # 完整笔记库，包括隐藏的 .obsidian
├── obsidian.svg
├── install-obsidian.sh
├── restore-obsidian.sh
├── SHA256SUMS              # 文件内容校验清单
└── 迁移说明.txt
```

将整个迁移包复制到移动硬盘或新电脑。输出到本机只是本地复制，还需要保存到重装不会清除的位置。

### 新电脑恢复

在迁移包目录执行：

```bash
bash restore-obsidian.sh
```

默认恢复到 `~/Documents/Obsidian/master/`。指定其他位置：

```bash
bash restore-obsidian.sh "$HOME/Documents/我的笔记"
```

目标目录已经存在（即使为空）时停止，不合并覆盖。安装阶段需要网络和依赖安装权限。完成后，在 Obsidian 中打开恢复的目标文件夹作为笔记库。

### 单独安装或更新

```bash
bash install-obsidian.sh
```

指定备份图标：

```bash
env OBSIDIAN_ICON="$PWD/obsidian.svg" bash install-obsidian.sh
```

`env` 将变量传给本次启动的进程，不永久修改终端环境。以上调用方式在 fish 中也能执行，因为脚本正文由 Bash 解释。

## 三、基础语法

### 解释器与执行权限

```bash
#!/usr/bin/env bash
```

这是 shebang，用于直接执行文件时选择解释器。

- `bash script.sh`：让 Bash 读取脚本，不要求文件有执行权限。
- `./script.sh`：直接执行，需要执行权限，由 shebang 指定解释器。
- `chmod +x script.sh`：增加执行权限。

### 错误处理

```bash
set -euo pipefail
```

| 选项 | 含义 |
| --- | --- |
| `-e` | 普通命令失败时通常退出；条件判断及部分 `&&`、`||` 上下文等存在例外 |
| `-u` | 使用未设置的变量时通常报错退出 |
| `pipefail` | 管道中任一命令失败时，整个管道返回失败，不只看最后一个命令 |

它不是自动回滚机制：已经安装的依赖、已经替换的文件不会因后续失败而自动撤销。

### 参数、变量和默认值

```bash
vault=${2:-$HOME/Documents/Obsidian/master}
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}"
```

> [!info]- 符号速查
>
> | 写法 | 含义 |
> | --- | --- |
> | `$1`、`$2`、`$3` | 第一、第二、第三个位置参数 |
> | `$#` | 位置参数数量 |
> | `${变量:-默认值}` | 变量未设置或为空时使用默认值，不给原变量赋值 |
> | `${OBSIDIAN_ICON:-}` | 未设置时使用空字符串，避免 `set -u` 报错 |
> | `$HOME` | 当前用户主目录 |
> | `$PWD` | 当前工作目录 |
> | `$EUID` | 有效用户 ID，0 通常表示 root |
> | `$$` | 当前 shell 进程号 |
> | `$(命令)` | 捕获命令标准输出，去掉末尾换行 |

使用 `$HOME` 使命令适应不同用户名。不要将 HOME 等系统环境变量重新用作临时变量。

### 引号和路径

```bash
cp -- "$icon" "$stage/obsidian.svg"
```

- 双引号允许变量展开，同时防止带空格的路径被拆分。
- 单引号保留字面内容，不展开变量。
- `--` 表示选项结束，避免以 `-` 开头的路径被误当成选项，具体命令须支持该约定。
- 行末反斜杠 `\` 用于续行，后面不要添加空格。
- `~/Documents` 会展开主目录，但 `"~/Documents"` 不会；需要引号时写 `"$HOME/Documents"`。

### 找到脚本所在目录

```bash
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
```

`BASH_SOURCE[0]` 提供脚本来源路径，`dirname` 取父目录，再通过 `cd` 和 `pwd` 得到目录路径。这样从其他工作目录调用脚本，也能找到与脚本放在一起的文件。

这个 `cd` 在命令替换的子 shell 中执行，不改变外层目录。该写法不完整解析脚本文件自身的符号链接，建议运行实际脚本文件。

## 四、判断、循环与退出

```bash
[[ -d "$vault/.obsidian" ]] || {
    echo "未找到笔记库配置：$vault/.obsidian" >&2
    exit 1
}
```

| 写法 | 含义 |
| --- | --- |
| `[[ -f 路径 ]]` | 是普通文件，可以跟随符号链接 |
| `[[ -d 路径 ]]` | 是目录 |
| `[[ -e 路径 ]]` | 路径存在，断开的符号链接通常不满足 |
| `[[ -L 路径 ]]` | 路径本身是符号链接，包括断开的链接 |
| `[[ -n 字符串 ]]` | 字符串非空 |
| `!` | 条件取反 |
| `&&` | 前者成功才继续 |
| `||` | 前者失败才继续 |
| `>&2` | 将输出写入标准错误 |
| `exit 1` | 非零退出状态，表示失败 |

恢复脚本同时检查 `-e` 和 `-L`，避免遗漏断开的目标符号链接。

```bash
for required in SHA256SUMS obsidian.svg install-obsidian.sh; do
    [[ -f "$base/$required" ]] || exit 1
done
```

`for` 逐个处理列表项。`case` 用于多分支匹配：

```bash
case "$(uname -m)" in
    x86_64|aarch64) ;;
    *) echo '不支持的架构' >&2; exit 1 ;;
esac
```

`command -v dnf >/dev/null` 检查命令能否被找到，并隐藏正常输出。这是包管理器检查，不是完整的发行版身份验证。

## 五、临时目录、复制与防覆盖

```bash
stage=$(mktemp -d "$destination/.obsidian-backup.XXXXXX")
trap 'rm -rf -- "$stage"' EXIT
```

`mktemp -d` 创建唯一临时目录；`trap ... EXIT` 注册退出时清理动作。单引号让 `$stage` 在清理动作执行时展开。SIGKILL 或断电时不能保证清理执行。

先完成临时副本，再移动到正式位置，可以减少将未完成备份误认为成功的情况。`trap - EXIT` 取消已注册的退出处理。

| 命令 | 当前用途 |
| --- | --- |
| `cp -aL` | 备份目录，尽量保留属性，并跟随符号链接复制目标数据 |
| `cp -a` | 恢复目录，递归复制并尽量保留属性 |
| `cp -p` | 保存旧文件和部分属性 |
| `mkdir -p` | 创建目录，必要时创建父目录；已有目录不报错 |

完整复制目录会包含 `.obsidian` 等隐藏文件。`cp -aL` 将符号链接转为实际内容；如果指向大目录，备份会变大，断开或循环链接可能导致失败。笔记正文中的外部路径和远程 URL 不会被自动收集。

恢复时：

```bash
mv -T --no-clobber -- "$stage/vault" "$target"
[[ ! -e "$stage/vault" ]] || exit 1
```

`-T` 将目标当作确切路径，`--no-clobber` 防止覆盖，随后检查源是否仍存在，以确认移动没有被跳过。这些参数按 Fedora 的 GNU 工具行为使用。

临时目录放在目标父目录附近，一般有利于同一文件系统内移动。但程序、图标、菜单入口的三次替换不是整体事务，部分失败不会自动全部回滚。

## 六、SHA-256 校验

```bash
(cd -- "$stage" && find . -type f ! -name SHA256SUMS -print0 |
  LC_ALL=C sort -z |
  xargs -0 sha256sum > SHA256SUMS)
```

流程是：列出文件 → 排序 → 计算内容摘要 → 写入清单。

- `( ... )` 创建子 shell，里面的 `cd` 不影响外层。
- `-print0`、`sort -z`、`xargs -0` 使用 NUL 分隔文件名，避免空格等字符拆分文件名。
- `LC_ALL=C` 为这次排序指定固定环境。
- 排除 `SHA256SUMS`，避免计算清单自身；当前写法也排除子目录中同名文件。

恢复时运行：

```bash
sha256sum --check --quiet SHA256SUMS
```

能发现清单所列文件缺失或内容变化，但不校验权限、空目录，也不拒绝所有额外文件。这是传输完整性检查，不是数字签名或可信来源认证。迁移包没有加密，插件配置可能包含账号相关信息。

## 七、curl 下载与 Python 协作

```bash
curl -fsSL --retry 3 --connect-timeout 30 --max-time 120 URL -o 文件
```

| 参数 | 含义 |
| --- | --- |
| `-f` | HTTP 错误状态时返回失败 |
| `-sS` | 隐藏进度，但保留错误信息 |
| `-L` | 跟随重定向 |
| `--retry 3` | 对符合条件的失败最多重试三次，不是所有错误都会重试 |
| `--connect-timeout 30` | 限制连接阶段时间 |
| `--max-time 120` | 限制单次传输时间；当前大文件下载没有设置该总时限 |
| `-o` | 指定输出文件 |

安装脚本从官网页面提取对应架构的链接，避免写死版本号；官网链接结构变化时仍可能需要更新匹配规则。

```bash
url=$(python3 - "$stage/download.html" "$architecture" <<'PY'
# Python 代码
PY
)
```

`python3 -` 从标准输入读取代码，后面的参数通过 `sys.argv[1]`、`sys.argv[2]` 取得。Python 的标准输出由 `$(...)` 捕获，非零退出会使调用失败。

Bash 负责组织步骤和调用系统工具；Python 处理 HTML、二进制文件头、SVG XML，以及桌面入口字符串转义。

## 八、Here Document：多行文本

```bash
cat > 文件 <<'EOF'
这里的 $HOME 会原样写入。
EOF
```

`<<'EOF'` 的结束标识被引用，正文不展开变量，适合说明文字或内嵌 Python。`<<EOF` 未引用，会进行变量及命令替换，适合写入当前用户路径。

结束标识必须独占一行；普通写法的结束标识前不能随意缩进。fish 不支持这种 Bash 语法，但可以用 `bash 文件名` 调用。

## 九、安装阶段的知识点

> [!info]- AppImage 文件头检查
>
> 脚本检查 ELF 标记、Type 2 AppImage 标记、64 位小端编码和机器类型。x86_64 对应 62，ARM64 对应 183。可以排除部分错误页面或架构错误，但不是完整文件校验，也不是发布者签名验证。

> [!info]- SVG 图标处理
>
> 读取当前图标 CSS 类中的颜色，将颜色写到图形的 `fill` 属性，删除样式和类名并设置尺寸，减少对渲染器 CSS 支持的依赖。没有固定使用 `#9974F8`。
>
> 这是针对当前图标结构的简化处理，不是完整 CSS 解析器，不适用于所有 SVG，也不会保留深浅主题自动换色。使用已验证的 SVG 备份可减少对官网样式变化的依赖。

> [!info]- 菜单入口与路径
>
> 按新电脑当前用户生成 `Exec` 和 `Icon` 的绝对路径，避免依赖启动器 PATH 或沿用旧用户名。`.desktop` 不是 shell 脚本，不应依靠它展开 `$HOME`、`~`。
>
> `%U` 是 URL 参数占位符，本身不注册协议处理器。`update-desktop-database` 更新桌面入口 MIME 信息缓存，不是万能的图标刷新命令。Fuzzel 通常重新打开即可，DMS 未刷新时可手动重启 DMS。

`chmod 755` 为程序设置执行权限；`install -m 644` 复制图标和菜单文件并设置权限。这里的 `install` 是文件工具，不是 dnf 包安装命令。

## 十、失败后如何理解脚本状态

| 情况 | 行为 |
| --- | --- |
| 缺少笔记库或必要脚本 | 提前退出 |
| 备份目录在笔记库内部 | 拒绝执行 |
| 备份复制中断 | 通常清理临时目录，不生成正式迁移包 |
| 恢复校验失败 | 停止，不调用安装程序 |
| 恢复目标已存在 | 停止，不合并覆盖 |
| 安装失败 | 不开始恢复笔记；可能已经安装依赖或建立目录 |
| 恢复复制失败 | 清理临时副本；已安装程序不会自动卸载 |
| 官网格式改变 | 停止，需要调整解析规则 |

目前采用临时笔记库及模拟安装程序测试过隐藏文件复制、含空格路径、安装调用、拒绝覆盖和校验失败拦截，并未替用户实际运行迁移。

这三个脚本可复用的设计顺序是：参数输入 → 环境检查 → 临时处理 → 校验 → 正式替换 → 提示结果。程序安装和笔记数据分别处理，便于定位失败阶段。
