`LC_MESSAGES`:指定菜单、提示、报错等文字的语言
`LANGUAGE`:告诉支持它的翻译系统先用哪种语言
`LANG` :各项语言环境的“默认值”


`locale`:当前终端里实际生效的语言环境
`localectl`:系统默认 locale、控制台及 X11 键盘设置
`locale -a`:系统已提供的 locale

### 本地化设置(设置系统底层为en_US.UTF-8)
1. 编辑配置文件
    ```shell
    vim /etc/locale.gen
    ```
剪切掉 `en_US.UTF-8 UTF-8` 和 `zh_CN.UTF-8 UTF-8` 的前面代表注释的井号
2. 生成本地化配置
    ```shell
    locale-gen
    ```
3. 设置系统语言
    ```shell
    vim /etc/locale.conf
    ```
写入 `LANG=en_US.UTF-8` 设置系统语言为英文；

> `/etc/locale.conf` 这个文件是系统级的语言设置，写入 `zh_CN.UTF-8` 可以设置系统语言为中文，但是会导致 TTY 的中文字符全部变成豆腐块，所以不建议这么做。后面安装完桌面环境后在用户空间修改系统语言。

### niri配置文件设置用户环境为中文
vim ~/.config/niri/config.kdl
利用配置文件提供的环境变量功能设置系统语言。
```
environment {
    LANG "zh_CN.UTF-8"
    LANGUAGE "zh_CN"
}
```



### Fcitx5相关配置总结

#### 1. 安装基础框架

```bash
sudo pacman -S fcitx5-im
```

> [!info] 说明
> `fcitx5-im` 包含 Fcitx5 的基本包。

#### 2. 安装中文输入方案

可以自行选择要安装的输入方案。本文主要介绍全拼方案。

##### 方案一：中文输入合集

`fcitx5-chinese-addons` 包含拼音、五笔、双拼等常用中文输入方案。

```bash
sudo pacman -S fcitx5-chinese-addons
```

##### 方案二：RIME 中州韵引擎 + 雾凇拼音

本文选择雾凇拼音作为全拼方案，也可以根据个人习惯选择万象等方案。

###### 2.1 安装 RIME + 雾凇拼音

```bash
sudo pacman -S fcitx5-rime rime-ice-git
```

> [!warning] 软件包来源
> `fcitx5-rime` 是输入法引擎。
>
> `rime-ice-git` 是雾凇输入方案，需要从 AUR 或 archlinuxcn 安装。上面的 `pacman` 命令需要已配置提供该包的软件源；从 AUR 安装时应使用相应的 AUR 安装方式。

> [!info]- 其他输入方案
> - `rime-wanxiang-pinyin`：万象拼音，原文使用 archlinuxcn 源。
> - `rime-wanxiang-flypy`：万象小鹤双拼，原文使用 archlinuxcn 源。
> - `fcitx5-mozc`：日语输入法。
> - `rime-wubi`：五笔输入法。

安装完成后：

1. 打开 `fcitx5-configtool`。
2. 将 **RIME（中州韵）** 添加到输入法列表。
3. 重启输入法。
4. 按 `Ctrl + 空格` 切换到 RIME，等待自动初始化。

默认输入方案为繁体的 **明月拼音**，可按 `F4` 打开菜单调整为简体。下面将默认方案改为雾凇拼音。

###### 2.2 启用雾凇拼音

创建配置目录，然后编辑配置文件：

```bash
mkdir -p ~/.local/share/fcitx5/rime
vim ~/.local/share/fcitx5/rime/default.custom.yaml
```

> [!info] 命令说明
> - `mkdir -p`：目录不存在时创建目录。
> - `vim`：打开并编辑配置文件。

在 `default.custom.yaml` 中写入：

```yaml
patch:
  # 使用雾凇方案的默认预设
  __include: rime_ice_suggestion:/
```

重启输入法后，默认输入方案变为雾凇拼音。

###### 2.3 可选：使用 F4 切换多个输入方案

查看当前可用的输入方案：

```bash
ls /usr/share/rime-data/*.schema.yaml
```

去掉文件名末尾的 `.schema.yaml`，就是对应的 `schema` 名称。

将需要的方案写入 `default.custom.yaml`。下面是配置示例，请按实际安装的方案选择：

```yaml
patch:
  __include: rime_ice_suggestion:/
  schema_list:
    - schema: luna_pinyin_simp
    - schema: rime_ice
    - schema: wanxiang
    - schema: double_pinyin_flypy
    - schema: wubi86
    - schema: bopomofo
```

> [!warning] 注意缩进
> YAML 使用空格缩进，不要使用 Tab。
>
> 如果文件中已经有 `patch:`，将配置合并到已有的 `patch:` 下，不要重复添加。

> [!info]- 方案名称说明
> - `luna_pinyin_simp`：明月拼音简化字方案。
> - `rime_ice`：雾凇拼音。
> - `wanxiang`：万象拼音。
> - `double_pinyin_flypy`：小鹤双拼，原文使用 `rime-ice-git` 提供的方案。
> - `wubi86`：五笔 86。
> - `bopomofo`：注音输入法。

配置后，可通过 `F4` 菜单切换输入方案。

###### 2.4 可选：配置语言模型

可以尝试为雾凇拼音接入万象语言模型，以改善长句输入效果。

例如，配置前后分别输入“苍茫的天涯是我的爱”，比较候选结果。

**第一步：安装模型**

使用 AUR 安装：

```bash
yay -S rime-wanxiang-gram-zh-hans
```

也可以[手动下载模型](https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram)，然后放入：

```text
~/.local/share/fcitx5/rime/
```

**第二步：编辑雾凇拼音配置**

```bash
vim ~/.local/share/fcitx5/rime/rime_ice.custom.yaml
```

写入：

```yaml
patch:
  "grammar/language": wanxiang-lts-zh-hans
```

**第三步：重新启动输入法**
再次输入“苍茫的天涯是我的爱”，检查效果。
```shell
fcitx5 -r
```
###### 2.5 可选：接入 LLM 云拼音

项目地址：[rime-llm-translator](https://github.com/SHORiN-KiWATA/rime-llm-translator)。

该项目为 RIME 接入大模型，将拼音传给模型生成候选句子，并提供安装与 TUI 配置界面。

###### 2.6 可选：默认使用英文标点

如果更习惯英文标点，可以调整雾凇拼音的默认标点状态。

编辑配置文件：

```bash
vim ~/.local/share/fcitx5/rime/rime_ice.custom.yaml
```

写入：

```yaml
patch:
  # switches 为方案中的开关列表
  # @1 表示第二项开关；此配置假定它是中英标点开关
  # reset: 1 表示重置到第二个状态
  "switches/@1/reset": 1
```

> [!tip] 与语言模型配置合并
> 如果前面已经配置了语言模型，在同一个 `patch:` 下添加即可：
>
> ```yaml
> patch:
>   "grammar/language": wanxiang-lts-zh-hans
>   "switches/@1/reset": 1
> ```

重启输入法后生效。按照原文的快捷键设置，可按 `Ctrl + Shift + 3` 临时切换标点状态。

#### 3. 调整系统设置

按自己使用的桌面环境选择对应配置。

##### GNOME
但GNOME更推荐使用iBus框架
1. 打开 Fcitx5 配置，添加 RIME。
2. 安装 **Extension Manager** 扩展管理器。
3. 安装 [Input Method Panel](https://extensions.gnome.org/extension/261/kimpanel/) 扩展。

##### KDE

1. 打开 **系统设置 → 键盘 → 虚拟键盘**。
2. 选择 **Fcitx5 Wayland 启动器**，点击 **应用**。
3. 打开 **系统设置 → 语言和时间 → 输入法**。
4. 添加 **RIME（中州韵）**。

可进一步调整：

- **配置全局选项**：设置输入法切换快捷键。
- **配置附加选项**：调整其他自定义设置。

##### Wayland 合成器

1. 打开 **Fcitx5 配置**进行设置。
2. 在合成器配置文件中添加 Fcitx5 自动启动配置。

以 Niri 为例：

```kdl
spawn-at-startup "fcitx5"
```

#### 4. 可选：美化输入法

1. 搜索并下载喜欢的 Fcitx5 主题。
2. 将主题放入以下目录：

   ```text
   ~/.local/share/fcitx5/themes
   ```

3. 打开 **Fcitx5 配置 → 经典用户界面**。
4. 选择并应用主题。
#### 5.可选:RIME自定义词库



### niri关于输入法相关配置
在niri配置文件内修改以下:
1. 在 Niri 配置文件的 `environment{}` 里面写入 `XMODIFIERS "@im=fcitx"` 即可
2. 添加自启动spawn-at-startup "fcitx5" "-d"
3. 设置开关输入法的快捷键Mod+F1 {spawn-sh "pkill fcitx5 || fcitx5";}


