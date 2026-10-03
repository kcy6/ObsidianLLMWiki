

### vcgencmd
**`vcgencmd` 是树莓派（Raspberry Pi）官方操作系统中一个非常强大的命令行工具**，它==主要用于与树莓派的视[[fedora新机配置]]频核心图形处理器（VideoCore GPU）进行通信==。通过它，用户可以实时获取和控制树莓派的硬件状态、温度、电压、时钟频率以及各种硬件配置信息。

1. 硬件状态与监控（最常用）

- **查看 CPU 核心温度：**  
    `vcgencmd measure_temp`  
    _返回示例：`temp=45.0'C`。这是监控树莓派是否过热最准确的命令。_

- **查看当前各组件电压：**  
    `vcgencmd measure_volts <组件名称>`  
    _例如查看核心电压：`vcgencmd measure_volts core`（默认）。也可以查看 `sdram_c`、`sdram_i`、`sdram_p` 等。_

- **查看实时时钟频率：**  
    `vcgencmd measure_clock <组件名称>`  
    _例如查看 CPU 频率：`vcgencmd measure_clock arm`。常用于检查系统在低负载时是否自动降频，或超频是否生效。_

2. 系统异常与节流状态检查（排查电源问题）

- **查看系统节流/欠压状态：**  
    `vcgencmd get_throttled`  
    _这是一个非常关键的命令。它会返回一个十六进制值（如 `0x50000` 或 `0x0`）。如果返回值不是 `0x0`，说明树莓派当前或曾经发生过供电不足（欠压）或温度过高导致的强制降频。_

3. 内存分配与硬件支持查询

- **查看 CPU 和 GPU 的内存分配：**  
    `vcgencmd get_mem arm` （查看分配给 CPU 的内存）  
    `vcgencmd get_mem gpu` （查看分配给 GPU 的内存）

- **查看编解码器（Codec）是否启用：**  
    `vcgencmd codec_enabled <编解码器名称>`  
    _例如：`vcgencmd codec_enabled H264`（检查是否支持 H.264 硬件解码）。_

4. 屏幕与显示控制

- **控制 HDMI 输出开关：**  
    `vcgencmd display_power 0` （关闭 HDMI 显示输出，可用于省电）  
    `vcgencmd display_power 1` （开启 HDMI 显示输出）

- 显示特定的配置值：`vcgencmd get_config`
示例：`vcgencmd get_config arm_freq`
- 列出所有已设置的整数配置选项（非零）
`vcgencmd get_config int`
- 列出所有已设置的字符串配置选项（非零）
`vcgencmd get_config str`
### nmcli
查看WiFi启用状态命令：nmcli radio wifi
开启WiFi状态命令：nmcli radio wifi on
关闭WiFi状态命令：nmcli radio wifi off
查找网络命令：sudo nmcli dev wifi list
==连接网络命令：sudo nmcli --ask dev wifi connect <example_ssid>==

|操作目的|对应命令|
|---|---|
|**查看网络设备状态**|`nmcli device status`|
|**查看所有网络连接**|`nmcli connection show`|
|**查看某一网卡的详细信息**|`nmcli device show eth0`|
|**激活某个网络连接**|`nmcli connection up my-office`|
|**断开某个网络连接**|`nmcli connection down my-office`|
|**添加静态 IP 连接**|`nmcli connection add type ethernet con-name my-eth0 ifname eth0 ipv4.addresses 192.168.1.100/24 ipv4.gateway 192.168.1.1 ipv4.method manual`|
|**扫描周围的 Wi-Fi**|`nmcli device wifi list`|
|**连接到指定的 Wi-Fi**|`nmcli device wifi connect "WiFi名称" password "密码"`|
