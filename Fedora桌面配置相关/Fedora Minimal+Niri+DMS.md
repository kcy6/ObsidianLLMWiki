
## iso最小化系统安装



## 网络连接





## 中文环境
```bash
mkdir /home/y/.config/environment.d
vim /home/y/.config/environment.d/10-locale.conf

LANGUAGE=zh_CN:en_US
```

## 中文输入法
### Fcitx5+rime+雾凇输入方案+万象输入模型安装
```bash
sudo dnf install git curl fcitx5 fcitx5-rime fcitx5-configtool google-noto-sans-cjk-fonts google-noto-color-emoji-fonts

fcitx5-configtool
#让系统重新扫描字体并更新缓存
fc-cache -f

#正式安装
git clone https://github.com/rime/plum.git ~/plum
cd ~/plum
env rime_frontend=fcitx5-rime bash rime-install iDvel/rime-ice
env rime_frontend=fcitx5-rime bash rime-install iDvel/rime-ice:others/recipes/grammar:schema=rime_ice

#日常更新雾凇和词库
cd ~/plum
env rime_frontend=fcitx5-rime bash rime-install iDvel/rime-ice
#需要单独更新万象模型时
cd ~/plum
env rime_frontend=fcitx5-rime bash rime-install iDvel/rime-ice:others/recipes/grammar:schema=rime_ice
#更新 Plum 工具本身
git -C ~/plum pull --ff-only

添加Fcitx5启动到niri配置内使其自启动
```
|名称|是什么|负责什么|
|---|---|---|
|**Fcitx5**|输入法框架|连接应用、切换输入法、显示候选框；可以搭载 Rime 等输入法|
|**Rime／中州韵**|输入法引擎|按方案处理输入编码、查询词典、组织候选，并记录个人用词|
|**雾凇拼音**|Rime 的方案和配套配置|提供全拼／双拼规则、词库、Lua 扩展等；你选中的是全拼 `rime_ice`|
|**万象语法模型**|Rime 可使用的语言模型数据|提供词语搭配的统计信息，辅助候选排序；不是独立输入法|
|**Plum／东风破**|安装和更新工具|下载方案、词库和模型，应用配置补丁；日常打字不需要运行它|
### 配置
- 设置默认为雾凇输入方案
```bash
mkdir -p ~/.local/share/fcitx5/rime
vim ~/.local/share/fcitx5/rime/default.custom.yaml #添加如下内容

patch:
  # 这里的 rime_ice_suggestion 为雾凇方案的默认预设
  __include: rime_ice_suggestion:/
```
- 配置F4提供的快捷切换方案
`ls /usr/share/rime-data/*.schema.yaml` 命令可以看到当前所有可用的输入方案，去掉文件名的 `.schema.yaml` 就是 `schema` 名，写进 `default.custom.yaml` 后可以在 F4 菜单里切换不同的输入方案
```
patch:
  schema_list:
    - schema: luna_pinyin_simp
    - schema: rime_ice
    - schema: wanxiang
    - schema: double_pinyin_flypy
    - schema: wubi86
    - schema: bopomofo
```
>`luna_pinyin_simp` 是 RIME 自带的明月拼音；`wanxiang` 是万象拼音；`double_pinyin_flypy` 是小鹤双拼（由 `rime-ice-git` 提供）；`bopomofo` 是注音输入法。

- 添加万象输入法联想模型
```
vim ~/.local/share/fcitx5/rime/rime_ice.custom.yaml

patch:
  "grammar/language": wanxiang-lts-zh-hans
```
- 默认使用英文标点
雾凇拼音默认输出中文标点（，。？！）。如果你日常聊天、写代码更习惯英文标点，可以让它默认就处于英文标点状态，不用每次手动切换：

```shell
vim ~/.local/share/fcitx5/rime/rime_ice.custom.yaml
```

```yaml
patch:
  # switches 是方案里的开关列表，@1 即第二项「中英标点」开关
  # reset: 1 表示每次启动都重置到第二个状态，也就是英文标点
  "switches/@1/reset": 1
```

> 如果前面配置语法模型时已经创建过这个文件，把 `"switches/@1/reset": 1` 加进已有的 `patch:` 里即可，不要出现两个 `patch:`。
重启输入法生效。之后想临时切回中文标点，按 `Ctrl+Shift+3` 即可。
- 配置自己的快捷短语
```bash
cp -a ~/.local/share/fcitx5/rime/custom_phrase.txt \
  ~/.local/share/fcitx5/rime/my_custom_phrase.txt

vim /home/y/.local/share/fcitx5/rime/rime_ice.custom.yaml

# 在现有patch下添加
  "custom_phrase/user_dict": my_custom_phrase
```
- 添加特定词库
```bash
cd ~/.local/share/fcitx5/rime

curl -fL --retry 3 \
  https://raw.githubusercontent.com/gaboolic/rime-frost/master/cn_dicts_cell/computer.dict.yaml \
  -o computer.dict.yaml

curl -fL --retry 3 \
  https://raw.githubusercontent.com/scomper/Rime/master/dicts/IT.dict.yaml \
  -o IT.dict.yaml
  
head -n 16 computer.dict.yaml
head -n 16 IT.dict.yaml

cat > ~/.local/share/fcitx5/rime/rime_ice_work.dict.yaml <<'EOF'
# Rime dictionary
# encoding: utf-8
---
name: rime_ice_work
version: "2026-09-24"
sort: by_weight
import_tables:
  - cn_dicts/8105
  - cn_dicts/base
  - cn_dicts/ext
  - cn_dicts/tencent
  - cn_dicts/others
  - rime_ice
  - computer
  - IT
...
EOF

vim ~/.local/share/fcitx5/rime/rime_ice.custom.yaml

#在patch下添加
  "translator/dictionary": rime_ice_work
  "translator/user_dict": rime_ice
  
#更新和维护
#将rime_ice.custom.yaml中的  "translator/dictionary": rime_ice_work改为rime_ice
#要添加或减少词库时主要维护 rime_ice_work.dict.yaml 中的 import_tables 列表
#查看其名字name: electronics写入import_tables如  - electronics
cat /home/y/.local/share/fcitx5/rime/electronics.dict.yaml
```
- 兼容性
```bash
# 创建用户家里的环境变量配置目录，编辑输入法环境变量
mkdir -p ~/.config/environment.d/
vim ~/.config/environment.d/fcitx5.conf

XMODIFIERS=@im=fcitx
QT_IM_MODULES="wayland;fcitx"
QT_IM_MODULE=fcitx
SDL_IM_MODULE=fcitx
```



### 美化fcitx5
fcitx5-configtool中选 **Noto Sans CJK SC，Regular**,安装完主题后选择Catppuccin Latte Blue,Catppuccin Mocha Blue
```bash
mkdir -p ~/.local/share/fcitx5-theme-sources

git clone https://github.com/catppuccin/fcitx5.git \
  ~/.local/share/fcitx5-theme-sources/catppuccin

cd ~/.local/share/fcitx5-theme-sources/catppuccin

bash enable-rounded.sh

mkdir -p ~/.local/share/fcitx5/themes

cp -r src/. ~/.local/share/fcitx5/themes/
```
后续更新:
```bash
cd ~/.local/share/fcitx5-theme-sources/catppuccin

git pull --ff-only

bash enable-rounded.sh

cp -r src/. ~/.local/share/fcitx5/themes/
```
重启输入法
```
fcitx5 -r
```
## obsidian
[obsidian官网](https://obsidian.md/)
[obsidian官网文档](https://obsidian.md/help/)

|               | 位置                                             |
| ------------- | ---------------------------------------------- |
| 应用程序          | `~/Applications/Obsidian.AppImage`             |
| 菜单启动器快捷方式     | `~/.local/share/applications/obsidian.desktop` |
| 笔记库（示例，可自行选择） | `~/Documents/Obsidian`/                        |

`AppImage`方式安装,本节指令使用bash执行,其他shell可能不适配
```bash
#缺少依赖补上:
sudo dnf install fuse fuse-libs -y

url=$(curl -fsSL https://obsidian.md/download |
  grep -oE 'https://github\.com/obsidianmd/obsidian-releases/releases/download/[^/]+/Obsidian-[0-9.]+\.AppImage' |
  head -n 1)

printf '%s\n' "$url"

mkdir -p ~/Applications
curl -fL --retry 3 "$url" -o ~/Applications/Obsidian.AppImage.download &&
chmod +x ~/Applications/Obsidian.AppImage.download &&
mv -f ~/Applications/Obsidian.AppImage.download ~/Applications/Obsidian.AppImage

#启动
~/Applications/Obsidian.AppImage

```
### 添加到系统的应用菜单/fuzzel程序启动器
```bash
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/obsidian.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Obsidian
Comment=Markdown Knowledge base
Exec="$HOME/Applications/Obsidian.AppImage" %U
Icon=obsidian
Terminal=false
Categories=Office;
EOF
```
> [!info]- 快捷方式字段说明
>
> | 字段 | 作用 |
> | --- | --- |
> | `[Desktop Entry]` | 主配置段的固定名称，告诉读取者下面是应用入口信息 |
> | `Type=Application` | 表示这是可以运行的应用 |
> | `Name=Obsidian` | 菜单中显示的名称 |
> | `Comment=…` | 应用说明，可能用于提示文字或搜索，不是代码注释 |
> | `Exec=…` | 启动命令；这里执行指定的 AppImage |
> | `%U` | 多个 URL 的参数占位符；没有传入 URL 时会移除 |
> | `Icon=…` | 图标的绝对路径，也可以是图标主题中的名称 |
> | `Terminal=false` | 不要求在终端窗口中运行 |
> | `Categories=Office;` | 将应用归入办公类；分类列表使用分号分隔 |

### 解决obsidian图标未显示问题
```bash
mkdir -p ~/.local/share/icons
curl -fL https://obsidian.md/favicon.svg -o ~/.local/share/icons/obsidian.svg

sed -i "s|^Icon=.*|Icon=$HOME/.local/share/icons/obsidian.svg|" ~/.local/share/applications/obsidian.desktop
#这条命令会直接修改 Obsidian 快捷方式文件，把图标设置为你下载的 SVG 图片,将图片下载到~/.local/share/icons/。
#修改前Icon=obsidian，修改后Icon=/home/y/.local/share/icons/obsidian.svg
#fuzzel没有显示图标但应用管理器已经显示了图标,同时本机图标路径正确，但 Fuzzel 未显示图标，疑似与该 SVG 的 CSS 样式和 Fuzzel的NanoSVG 渲染兼容性有关。可尝试将 CSS 类名对应的颜色直接写入图形属性。
sed -i 's/class="purple"/fill="#9974F8"/g' ~/.local/share/icons/obsidian.svg
#9974F8取自官网图标,官网以后更改图标结构，命令就不合适了
```

> [!tip]- 补充信息
> Fuzzel 和 DMS 分别读取什么？
> 两者都使用 XDG 标准的应用入口，默认来源相同,就fuzzel,dms菜单这种情况而言读取是相同的,但隐藏规则、排序、搜索和刷新方式可能不同，最终显示的列表不一定完全一样
> `~/.local/share/applications/`当前用户的应用入口,如`obsidian.desktop`
> `/usr/local/share/applications/`本机额外安装的应用入口
> `/usr/share/applications/`系统软件包安装的应用入口`Alacritty.desktop`,`org.mozilla.firefox.desktop`等
> - **Fuzzel**：收集这些目录中的 `.desktop` 文件，生成可搜索的应用列表。[Fuzzel 手册](https://man.archlinux.org/man/fuzzel.1.en)
> - **DMS 菜单**：通过 Quickshell 的 `DesktopEntries` 获取应用列表
> Fuzzel 通常是每次调用时启动，选完应用就退出，不是一直运行的后台服务。修改后及时刷新
> 如果卡死了执行`pkill -x fuzzel`,`fuzzel` 
> DMS 会响应应用列表变化，但图标内容或缓存未必立即刷新；先重新打开菜单，仍未更新可执行 dms restart。注销重登录作为最后的处理方式。

### 快捷键


### 页面美化


### 一键安装配置脚本bash install-obsidian.sh
[[Fedora Minimal+Niri+DMS文档对应脚本#obsidian.sh]]

## 命令的别名
### ll=ls -alh
`bash`
```bash
echo "alias ll='ls -alh'" >> ~/.bashrc
source ~/.bashrc
```
`zsh`
```
echo "alias ll='ls -alh'" >> ~/.zshrc
source ~/.zshrc
```
`fish`
```
alias --save ll='ls -alh'
```
## 安装vscode
**1. 导入微软签名密钥：**

```
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
```

**2. 添加 VS Code 软件源：**

```
sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
```

**3. 安装并启动：**

```
sudo dnf install code
code
```



## 截图相关功能
我的需求:区域截图,长截图,全屏截图,窗口截图,贴图(贴图即识别剪贴板最新项,要求能实现图片和文字的贴图以及多个贴图共存,贴图后能编辑图片(对标Windows下的pixpin效果),能OCR图片中的文字,贴图中的文字,能调用接口或原生支持翻译贴图和截图的内容,以及录屏功能,各类截图默认仅存放到剪贴板不保存
> [!tip]- grim+slurp搭配截图
> grim：真正负责“抓取屏幕像素”
> slurp：让你用鼠标“框选区域”

> [!info]- niri+dms默认存在三种截图方式(选择niri原生截图)
|对比项|niri 原生截图|DMS 调用 niri 并编辑|DMS 自带截图命令|
|---|---|---|---|
|典型命令|`niri msg action screenshot`|`dms ipc call niri screenshot`|`dms screenshot`|
|谁负责截图|niri|仍然是 niri|DMS 截图工具，具体捕获方式依环境而定|
|是否自动打开编辑器|否|正常保存截图后打开 Swappy 等编辑器|默认不打开编辑器|
|默认保存行为|由 `screenshot-path` 控制|DMS 显式指定文件路径|默认保存文件并复制到剪贴板|
|`screenshot-path null` 是否管用|管用|不能阻止 DMS 指定路径保存|不控制该命令的输出策略|
|只复制、不保存|设置 `null`，或截图界面按 `Ctrl + C`|按 `Ctrl + C`，但不会自动打开编辑器|使用 `--no-file`|
|适合什么需求|简单截图、只复制|截图后立即标注，接受保留原图|用命令控制截图类型、格式和输出|

> [!tip]- Satty/Swappy编辑标注

> [!info]- imv图片查看器(可用于贴图)

> [!tip]- wl-copy剪贴板
> 

 

### 基础截图
**基础截图功能同时默认不保存到本地仅剪贴板**
`~/.config/niri/config.kdl`搜索screenshot,如果希望**所有 niri 截图默认都不保存**，则把配置文件中原有的 `screenshot-path "..."` 那一行替换为：screenshot-path null,其含义为:不为 niri 截图设置默认保存路径
```
// 区域截图
Mod+Shift+S { screenshot; }

// 当前显示器截图
Mod+Shift+A { screenshot-screen; }

// 当前窗口截图
Mod+Shift+W { screenshot-window; }
```
**配置打开剪贴板的快捷键。** `Win + V` 已用于切换窗口浮动。
可以在 `/home/y/.config/niri/config.kdl` 的 `binds {}` 内加入：
```
Mod+Ctrl+V { spawn "dms" "ipc" "call" "clipboard" "toggle"; }
```
**使用Swappy编辑剪贴板截图**
在 `/home/y/.config/niri/config.kdl` 的现有 `binds {}` 内加入：
```
Mod+Ctrl+E {
    spawn-sh "wl-paste --type image/png | swappy -f -";
}
```
在 `/home/y/.config/swappy/config` 中设置
```
[Default]
save_dir=/home/y/Pictures/Screenshots
save_filename_format=swappy-%Y%m%d-%H%M%S.png
show_panel=true
auto_save=false
```









## Firefox
### 插件安装
划词翻译,篡改猴,Dark Reader,Global Speed,uBlock Origin
 






## 终端美化
### 安装starship
Starship 是一款用 Rust 语言编写的跨平台、跨 Shell 的开源终端提示符（Prompt）定制工具。它可以让你的命令行界面变得非常美观、轻量且高效。
Starship 主题常使用 Nerd Fonts 提供的图标字形（glyph）。为了避免图标显示为方框或乱码，建议在终端模拟器中使用 Nerd Font。
```
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerd
fc-cache -fv

fc-list | grep -i "JetBrainsMono.*Nerd" | head
fc-match "JetBrainsMono Nerd Font"
正常应该看到类似：JetBrainsMonoNerdFont-Regular.ttf: "JetBrainsMono Nerd Font" "Regular"
```

```
curl -sS https://starship.rs/install.sh | sh
starship --version
```
### 配置 Alacritty
```bash
mkdir -p ~/.config/alacritty
nano ~/.config/alacritty/alacritty.toml

vim ~/.config/alacritty/alacritty.toml
```
字体 + 字号 + 边距 + 透明度 + 光标。[主题设计参考网站](https://github.com/alacritty/alacritty-theme)
> [!NOTE]- 参考配置
> ```toml
> # ── 窗口 ──────────────────────────────────
> [window]
> padding = { x = 10, y = 10 }
> dynamic_padding = true
> opacity = 0.95
> 
> # ── 字体 ──────────────────────────────────
> [font]
> size = 11.0
> 
> [font.normal]
> family = "JetBrainsMono Nerd Font"
> style = "Regular"
> 
> [font.bold]
> family = "JetBrainsMono Nerd Font"
> style = "Bold"
> 
> [font.italic]
> family = "JetBrainsMono Nerd Font"
> style = "Italic"
> 
> # ── 光标 ──────────────────────────────────
> [cursor]
> style = { shape = "Beam", blinking = "On" }
> 
> # ── Shell ─────────────────────────────────
> [terminal.shell]
> program = "/usr/bin/fish"
> 
> # ── 基础配色 ──────────────────────────────
> [colors.primary]
> background = "#1a1b26"        # Tokyo Night 深蓝背景
> foreground = "#cdd6f4"        # Mocha 浅灰蓝文字
> dim_foreground = "#7f849c"
> bright_foreground = "#e6e9ff"
> 
> # 淡紫色光标
> [colors.cursor]
> text = "#1a1b26"
> cursor = "#b4befe"
> 
> [colors.vi_mode_cursor]
> text = "#1a1b26"
> cursor = "#a6e3a1"
> 
> # 选中文字：蓝灰底，亮色文字
> [colors.selection]
> text = "#e6e9ff"
> background = "#3b4261"
> 
> # 搜索结果：普通匹配用蓝色，当前匹配用奶油黄
> [colors.search.matches]
> foreground = "#1a1b26"
> background = "#89b4fa"
> 
> [colors.search.focused_match]
> foreground = "#1a1b26"
> background = "#f9e2af"
> 
> # 链接提示标签
> [colors.hints.start]
> foreground = "#1a1b26"
> background = "#f9e2af"
> 
> [colors.hints.end]
> foreground = "#1a1b26"
> background = "#b4befe"
> 
> # ── 标准 ANSI 调色板 ──────────────────────
> [colors.normal]
> black = "#32344a"
> red = "#f38ba8"               # 柔和粉红
> green = "#a6e3a1"             # 浅绿
> yellow = "#f9e2af"            # 奶油黄
> blue = "#7aa2f7"              # Tokyo Night 蓝
> magenta = "#bb9af7"           # Tokyo Night 紫
> cyan = "#94e2d5"              # 薄荷青
> white = "#bac2de"
> 
> # ── 明亮 ANSI 调色板 ──────────────────────
> [colors.bright]
> black = "#737aa2"             # 灰色文字保持可读性
> red = "#ff9eb5"
> green = "#b5edb0"
> yellow = "#ffedc2"
> blue = "#89b4fa"
> magenta = "#c7a9ff"
> cyan = "#a6eee2"
> white = "#e6e9ff"
> 
> # 部分程序使用的扩展颜色
> [[colors.indexed_colors]]
> index = 16
> color = "#fab387"             # 桃橙
> 
> [[colors.indexed_colors]]
> index = 17
> color = "#f5e0dc"             # 浅玫瑰
> ```

### Kitty配置
```bash
mkdir -p ~/.config/kitty
vim ~/.config/kitty/kitty.conf
```

> [!NOTE]- 参考配置
> ```conf
> # 普通文字使用的字体
> font_family JetBrainsMono Nerd Font
> 
> # 自动选择与上面字体匹配的粗体、斜体、粗斜体
> bold_font auto
> italic_font auto
> bold_italic_font auto
> 
> # 字号：11 pt（点）
> font_size 11.0
> 
> # 文字与窗口边缘之间的留白：四边各 10 pt
> window_padding_width 10
> 
> # 背景不透明度：95%，即轻微透明
> background_opacity 0.95
> 
> # 文本光标形状：竖线 |
> cursor_shape beam
> 
> # 光标闪烁间隔：0.5 秒
> cursor_blink_interval 0.5
> 
> # Kitty 默认启动的 Shell
> shell /usr/bin/zsh
> ```

### 初始化starship
```bash
echo 'eval "$(starship init bash)"' >> ~/.bashrc
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fish需要手动修改
vim ~/.config/fish/config.fish
starship init fish | source

# 注意这部分指令应该分别在其对应的shell环境下运行
# Bash 中
source ~/.bashrc
# Zsh 中
source ~/.zshrc
# Fish 中
source ~/.config/fish/config.fish

nano ~/.config/starship.toml
```
starship.toml用于配置starship美化项[参考主题](https://starship.rs/presets/)
```zsh
starship preset nerd-font-symbols -o ~/.config/starship.toml
```
显示当前使用的是哪个shell
```toml
[shell]
disabled = false
bash_indicator = "bash"
zsh_indicator = "zsh"
fish_indicator = "fish"
unknown_indicator = "shell"
style = "bold #b4befe"
format = "[$indicator]($style) "
```
## shell美化
### fish
关闭欢迎提示信息:
```bash
set -U fish_greeting
```
### zsh
```bash
#设置为默认shell
chsh -s /usr/bin/zsh
#安装插件来提供语法检查、自动补全、Tab 选择、历史记录,
sudo dnf --repo=fedora --repo=updates install zsh-autosuggestions zsh-syntax-highlighting
mkdir -p ~/.local/share/zsh
git clone --depth 1 https://github.com/zsh-users/zsh-completions.git \
    ~/.local/share/zsh/zsh-completions
    
vim ~/.zshrc

#检查zsh配置并生效
zsh -n ~/.zshrc && exec zsh

#以后更新这套补全规则时执行
git -C ~/.local/share/zsh/zsh-completions pull --ff-only
```

> [!NOTE]- 参考配置
> ```
> ZSH_AUTOSUGGEST_STRATEGY=(history completion)
> 
> # 蓝灰色，与实际输入的文字区分
> ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#737aa2'
> 
> source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
> 
> # ── Starship 提示符 ───────────────────────
> eval "$(starship init zsh)"
> 
> # ── 输入高亮配色 ──────────────────────────
> typeset -A ZSH_HIGHLIGHT_STYLES
> 
> # 普通文字
> ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
> 
> # 有效命令：薄荷青
> ZSH_HIGHLIGHT_STYLES[command]='fg=#94e2d5'
> ZSH_HIGHLIGHT_STYLES[builtin]='fg=#94e2d5'
> ZSH_HIGHLIGHT_STYLES[function]='fg=#94e2d5'
> ZSH_HIGHLIGHT_STYLES[alias]='fg=#94e2d5'
> ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#94e2d5'
> 
> # 未识别的命令：柔和粉红
> ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
> 
> # 关键字：淡紫
> ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#bb9af7'
> ZSH_HIGHLIGHT_STYLES[precommand]='fg=#bb9af7'
> 
> # 参数选项：蓝色
> ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#89b4fa'
> ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#89b4fa'
> 
> # 字符串：浅绿
> ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'
> ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'
> 
> # 路径：浅蓝，并带下划线
> ZSH_HIGHLIGHT_STYLES[path]='fg=#89b4fa,underline'
> 
> # 管道、重定向等符号
> ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#b4befe'
> ZSH_HIGHLIGHT_STYLES[redirection]='fg=#b4befe'
> 
> # 语法高亮最后加载
> source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
> 
> ```

## niri美化及部分效率配置
### `~/.config/niri/config.kdl`配置文件修改
	- Mod+Shift+S    区域截图
	- Mod+Shift+A    当前显示器截图
	- Mod+Shift+W    当前窗口截图
	- Mod+Ctrl+V     打开剪贴板
	- Mod+Ctrl+E     打开swappy图片编辑器

#### 窗口圆角
```
window-rule {
    geometry-corner-radius 12
    clip-to-geometry true
}
```

- `12` 是圆角半径，可以改成 `8`、`16` 等。
- `clip-to-geometry true` 才会实际裁剪窗口圆角，否则只影响边框和焦点框。
- 不写 `match` 就应用到所有窗口。[官方说明](https://niri-wm.github.io/niri/Configuration%3A-Window-Rules.html#geometry-corner-radius)

#### 隐藏整个标题栏
```
prefer-no-csd
```

#### 启动Fcitx5
`spawn-at-startup "fcitx5"`


#### niri 的焦点环 `focus-ring`
```
focus-ring {
    width 2
    active-color "#b4befe"
    inactive-color "#3b4261"
}
```

- `width 2`：边框变细。
- `active-color`：活动显示器上焦点窗口的边框颜色。
- `inactive-color`：非活动显示器上焦点环的颜色。
#### 鼠标相关
鼠标移到哪个窗口，哪个窗口就自动获得焦点，无需点击在`input` 块里面添加：
```
input {
    focus-follows-mouse
}
```
如果不希望聚焦时带动桌面横向滚动，改用：
```
input {
    focus-follows-mouse max-scroll-amount="0%"
}
```
#### 替换锁屏,swaylock
改为使用dms greeter的锁屏(如果使用的是dms项目的登录管理器)
```
Super+Alt+L hotkey-overlay-title="Lock the Screen: dms" { spawn "dms" "ipc" "call" "lock" "lock"; }
```





## 卸载程序




# 一些概念
## Electron
Electron 让开发者用 HTML、CSS、JavaScript 这些网页技术开发桌面软件
把 **Chromium + Node.js + Web 前端技术**打包成桌面应用，本质更接近“桌面版 Web 应用运行环境”。

## xdg-user-dirs-update
是 Linux 上用来**初始化和维护用户常用目录**的小工具，属于 `xdg-user-dirs` 软件包。
- 创建桌面、下载、文档、图片、音乐、视频等文件夹。
- 将这些目录的位置写入 `~/.config/user-dirs.dirs`，方便应用查找。
```
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_TEMPLATES_DIR="$HOME/Templates"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_VIDEOS_DIR="$HOME/Videos"
```
## GTK
是一个开源的、跨平台的**图形用户界面（GUI）开发工具包**,原生 GUI 工具包，GNOME/Linux 生态最典型
```
gsettings set org.gnome.desktop.wm.preferences button-layout ':'
```
## QT
更完整的跨平台 C++ 应用开发框架，KDE 生态最典型。