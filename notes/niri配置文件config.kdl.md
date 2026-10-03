## 检查配置文件是否有效
```shell
niri validate
#也可以明确指定文件位置:
niri --config "$HOME/.config/niri/config.kdl" validate
```
## 修改默认终端
`alacritty`为默认终端
如果使用的不是 `alacritty` 可以编辑配置文件修改按键打开的终端。
```shell
vim ~/.config/niri/config.kdl
```

`/` 键，搜索 `alacritty`，找到下面这行内容：

```
Mod+T hotkey-overlay-title="Open a Terminal: alacritty" { spawn "alacritty"; }
```

> `hotkey-overlay-title="Open a Terminal: alacritty"` 设置 `Super+Shift+/` 打开的界面里的显示内容。改成 `=null` 可以隐藏。

以 kitty 举例，把 `spawn "alacritty"` 改成 `spawn "kitty" "-e" "fish"`
(设置kitty为默认终端模拟器且启动时默认使用fish shell)
- 关于 Niri 设置自定义快捷键
    
    当命令由多个部分组成时有两种写法。一种是 `spawn`，需要把命令分段写在多个引号里；
    
    ```
    spawn "kitty" "-e" "fish"
    ```
    
    另一种是 `spawn-sh`，命令不用分段，直接写在一个引号里；
    
    ```
    spawn-sh "kitty -e fish"
    ```
    
    `-sh` 的写法更方便，但是会有额外的性能开销，命令很长懒得分段或者命令中有 shell 符号时（如 `||`）使用 `-sh`。


## 显示器配置
1. 运行命令获取显示器信息
    ```shell
    niri msg outputs

    Output "BOE NE156QHM-NY1 Unknown" (eDP-1)
      Current mode: 2560x1440 @ 165.000 Hz (preferred)
      Variable refresh rate: supported, disabled
      Physical size: 340x190 mm
      Logical position: 0, 0
      Logical size: 1920x1080
      Scale: 1.3333333333333333
      Transform: normal
      Available modes:
        2560x1440@165.000 (current, preferred)
        2560x1440@60.000 (preferred)
    ……………………
    Output "Shenzhen KTC Technology Group H27T22C 0x00000001" (DP-2)
      Current mode: 2560x1440 @ 180.000 Hz
      Variable refresh rate: supported, disabled
      Physical size: 600x330 mm
      Logical position: 1925, 0
      Logical size: 2560x1440
      Scale: 1
      Transform: normal
      Available modes:
        2560x1440@59.951 (preferred)
        2560x1440@180.000 (current)
        2560x1440@164.999
    ………………
    ```
    
    记住 `eDP-1` 和 `DP-2` 这部分名称，然后在 `available modes` 里找到自己需要的模式，格式为 `分辨率@刷新率`。
    
2. 配置文件内修改 `output{}`
    
    左斜杠搜索 `output` 在示例配置下面自己写一个
    
    ```
    output "eDP-1"{
     //分辨率和刷新率
     mode "2560x1440@165"
     //缩放倍率
     scale 1.33
     //位置，x=0 y=0 代表最左上角
     position x=0 y=0
     //启动时聚焦此显示器
     focus-at-startup
     //取消下面这行的注释设置可变刷新率
     //variable-refresh-rate
     //取消下面这行的注释可以设置旋转，参数有：90, 180, 270, flipped（水平翻转）, flipped-90（水平翻转后旋转）, flipped-180 and flipped-270
     //transform "90"
    
    }
    ```
    
3. 多显示器的情况
    
    需要给每一个显示器都配置一个 `output{}`，通过 `DP-2` 这样的名称指定该配置生效的显示器。
    
    显示器的位置关系需要一些计算，根据你的显示器的摆放位置，把最左边或者最左上角的显示器的位置设置为 `position x=0 y=0`，然后以此为原点设置其他显示器的位置。
    
    我的 `eDP-1` 显示器位置在最左上角，所以位置设置成 `x=0 y=0`。我想把 DP-2 显示器放在它的右边，那就要更改 `x=0` 的值。eDP-1 的分辨率是 2560x1440，1.33 缩放，那横向像素就是 `2560/1.33=1924.81203008`，必须向上取整，那就是 `1925`。那我 DP-2 的位置就应该设置为 `x=1925 y=0`。以此类推，想放在下面就修改 y 轴的值，设置了旋转的话计算的时候横竖的值也要对应旋转。
    
    ```
     output "DP-2"{
     mode "2560x1440@180"
     scale 1
     position x=1925 y=0
    }
    ```

## 关闭鼠标加速
找到 `input{mouse{}}`，取消 `accel-profile "flat"` 的注释。

```
mouse {
    //取消下面这行注释修改鼠标速度，正数加快，负数减慢
    //accel-speed -0.2
    //鼠标加速是默认开启的，设置这一行可以关闭鼠标加速度
    accel-profile "flat"
    //滚轮滚动速度，如果是负号的话会变更方向
    //scroll-factor horizontal=2.0 vertical=-1.0
}
```

## 通知服务
```shell
sudo pacman -S libnotify mako polkit-gnome
```
> libnotify让应用程序能够发送桌面通知

> `mako` 精简好用的通知服务。

> `polkit-gnome` 需要管理员权限的软件会通过 polkit 询问权限，没有 polkit 的话就无法启动，例如 `btrfs-assistant`。

1. 搜索 `spawn-at-startup`，在合适的地方写入：
    
    ```
    spawn-at-startup "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
    
    spawn-at-startup "mako"
    ```
    
2. 现在启动
    
    ```shell
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & disown
    ```
    
    ```shell
    mako & disown
    ```
    
    > `&` 代表在终端后台运行。
    
    > `disown` 命令从终端解绑程序。
    

- 编辑 mako 的配置文件设置通知的显示时长
    
    ```shell
    # 创建目录
    mkdir -p ~/.config/mako
    # 编辑文件
    vim ~/.config/mako/config
    ```
    
    ```
    default-timeout=8000
    border-radius=8
    ```
    
    ```shell
    # 重新加载配置
    makoctl reload
    ```


## 修改系统语言为中文(niri桌面层面配置)
[[Linux中文环境及中文输入法#niri配置文件设置用户环境为中文]]