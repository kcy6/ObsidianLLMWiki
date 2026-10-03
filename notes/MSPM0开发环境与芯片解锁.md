

# Keil环境搭建

## 快速上手
直接使用Keil_transplant中提供的空项目工程，参考文档修改根目录下syscfg.bat文件中的SYSCFG_PATH路径为自己电脑的安装路径，若需要在keil中打开图形化配置页面还需要修改安装SDK时的tools/keil/MSPM0_SDK_syscfg_menu_import.cfg并在Keil中配置好

![[20260717-205923_MSPM0开发环境与芯片解锁_ba24d7c2ba40.png]]



## 前置说明

>[!error]
>不能使用 ST-LINK 进行下载，会被锁芯片! 下载会显示 PDSC.

examples就是官方例程，source是库文件，tools是配置TI芯片用到的sysconfig软件，sysconfig可以简单理解为开发STM芯片时用的CubeMX，想在Keil中随时使用sysconfig，需要进行一些配置

![[20260504-170324_MSPM0开发环境与芯片解锁_321df54a7796.png]]

![[20260504-170324_MSPM0开发环境与芯片解锁_7bca68d7a268.png]]

## 移植空项目

全局配置更改
```
进入mspm0_sdk_1_30_00_03/tools/keil文件夹找到MSPM0_SDK_syscfg_menu_import.cfg，syscfg.bat两个文件通过记事本打开参考以下文档修改这两个文件，配置完成后在keil中导入同样参考立创该文档，也可参考本文档最后的图文教程

https://wiki.lckfb.com/zh-hans/tmx-mspm0g3507/keil-beginner/install.html#_2-4-%E5%AE%89%E8%A3%85sysconfig  立创提供的移植参考
以及SDK安装目录下的TI官方文档
```

首先介绍移植一个空项目，参考我的路径"E:\tools\CCS_20.5.0.00028_win\SDK\mspm0_sdk_2_10_00_04\examples\nortos\LP_MSPM0G3507\driverlib\empty"将这个空例程复制到一个单独路径下，开始将其与SDK目录隔离
```
1.回到SDK文件夹，找到source文件夹，这里存放着库文件夹，把它直接复制到我们刚复制出来的示例空项目中\empty\source，打开Keil
2.配置头文件路径
点击项目配置(Options for Target)点击C/C++
../../../../../../source/third_party/CMSIS/Core/Ilnclude
../../../../../../source两项修改为
../source/third_party/CMSIS/Core/Ilnclude
../source
3.移除原本Driverlib下的driverlib.a文件（若存在，笔者提供的两个版本中通过mspm0_sdk_1_30_00_03移植才有该项，另一个版本有driverlib.a这是是通过静态库链接后续介绍），从刚刚复制过来的source文件夹里打开ti/driverlib，把里面的文件添加到Keil中去（仅文件，不包含文件夹）
4.编译试一下，可以看到零错误，零警告。但是前面有一条“系统找不到指定的路径”，这个其实是跟sysfig相关的地址，也需要对其进行配置。将之前配置好的syscfg.bat文件复制到当前移植项目根目录
5.点击魔法棒，选择User一栏，看到图示区域，这里展开后全文是cmd.exe /C "$P../../../../../../tools/keil/syscfg.bat '$P' empty.syscfg"，改为
cmd.exe /C "$P../syscfg.bat '$P' empty.syscfg"（千万不要改错多数问题都是这里没改正确！！）
这一步相当于将sysconfig喝keil联动起来后续我们可以通过keil来打开sysconfig进行配置并更新新文件
6.再编译一次试试，可以看见先前“系统找不到指定的路径”的问题已经解决了，但又出现了新的问题，提示找不到.metadata文件夹中的product.json文件，再次回到mspm0_sdk_1_30_00_03文件夹，其实.metadata就在这里。该文件属于隐藏项目，把 .metadata文件夹复制到我们的示例空项目中，再编译所有问题全部解决
7.gcc、iar、ticlang这三个文件暂时用不到，可以将其删除，节省空间
```

>在上述移植流程3中若打开Keil没有Driverlib项则库文件是通过静态库链接的，这种版本（新版）只需要修改项目配置中的Linker下的
>../../../../../../source/ti/driverlib/lib/keil/m0p/mspm0g1x0x_g3x0x/driverlib.a改为
>../source/ti/driverlib/lib/keil/m0p/mspm0g1x0x_g3x0x/driverlib.a
>添加Linker后不需要Driverlib文件下添加库文件
>或直接在项目中添加一个driverlib项目文件夹，删去Linker中的Misc controls内的静态链接库


## 图文教程

导航至 SDK 文件夹中的 <SDK路径下>/tools/keil/，然后打开 syscfg.bat 进行编辑（不是执行）
在打开的文件中，修改下面以绿色显示的 SYSCFG_PATH，以匹配在我们之前安装SYSCFG的路径

![[20260504-170324_MSPM0开发环境与芯片解锁_c383e4b92bab.png]]

修改后效果如下

![[20260504-170324_MSPM0开发环境与芯片解锁_650e21a86ce1.png]]

然后打开MSPM0_SDK_syscfg_menu_import.cfg修改如下五个点位，根据自己的版本号修改

![[20260504-170324_MSPM0开发环境与芯片解锁_a0496bb87874.png]]

修改后效果如图(对于新版本sdk与其他教程路径有所不同，注意甄别)

![[20260717-204635_MSPM0开发环境与芯片解锁_c36ef51b9547.png]]

回到<SDK路径下>\examples\nortos\LP_MSPM0G3507\driverlib\empty复制一个空路径到一个自己的目录下，回到<SDK路径下>文件夹，找到source文件夹，这里存放着库，把它直接复制到我们刚复制出来的示例空项目中，打开Keil
更改头文件路径

![[20260504-170325_MSPM0开发环境与芯片解锁_dd7fa35143d8.png]]

移除原本的driverlib.a添加sourc/ti/driverlib下文件后效果如下

![[20260504-170325_MSPM0开发环境与芯片解锁_16726ed0100f.png]]

![[20260504-170325_MSPM0开发环境与芯片解锁_1b188666715b.png]]

第一次编译后效果如下零错误，零警告提示找不到路径，将之前配置好的syscfg.bat文件复制到当前移植项目根目录

![[20260504-170325_MSPM0开发环境与芯片解锁_121f05cb3209.png]]

更改User处，效果如下

![[20260504-170325_MSPM0开发环境与芯片解锁_07ac3786f2fe.png]]

编译一次又出现了新的问题，提示找不到.metadata文件夹中的product.json文件，再次回到<SDK路径下>.metadata就在这里。该文件属于隐藏项目，把.metadata文件夹复制到我们的示例空项目中，再编译所有问题全部解决

![[20260504-170325_MSPM0开发环境与芯片解锁_d1622f1a6386.png]]

最后关联.syscfg点击Customize Tools Menu点击Import添加配置文件

![[20260504-170325_MSPM0开发环境与芯片解锁_2a31a0b7b8da.png]]



点击以下位置即可打开empty.syscfg

![[20260504-170325_MSPM0开发环境与芯片解锁_8347d789e4cc.png]]

注意当前鼠标焦点需要确保在Keil中的empty.syscfg文件下，然后在点击工具打开配置页面否则会报错

![[20260504-170325_MSPM0开发环境与芯片解锁_6d4d208513ef.png]]

简单写一个LED翻转程序，使用Keil环境有一个好处是可以使用DAP等下载器下载

![[20260504-170325_MSPM0开发环境与芯片解锁_ae80400f60a7.png]]

![[20260504-170325_MSPM0开发环境与芯片解锁_adc44eb8604a.png]]

![[20260504-170325_MSPM0开发环境与芯片解锁_d6aaa9e015df.png]]

使用JLink下载效果如下，需要选择SW

![[20260504-170325_MSPM0开发环境与芯片解锁_6f9dd1e4b8c2.png]]

![[20260504-170325_MSPM0开发环境与芯片解锁_bff5b5a6dbe0.png]]


## BUG

测试过程中发现有时候使用Keil打开编辑后不能使用CTRL+S保存会弹出另存为，只能点击左上角File来保存

![[20260504-170325_MSPM0开发环境与芯片解锁_a754ccc369c4.png]]






# vscode环境搭建


## EIDE插件+Keil


## vscode编辑，ccs编译烧录

ccs生成编译烧录工程，vscode编写代码需要添加一个.vscode文件到根目录同时添加**c_cpp_properties.json**文件才能识别到库文件，头文件使用代码补全
```json
{
    "configurations": [
        {
            "name": "MSPG3507_Config",
            "includePath": [
                "E:/tools/CCS_20.5.0.00028_win/SDK/mspm0_sdk_2_10_00_04/source",
                "E:/tools/CCS_20.5.0.00028_win/SDK/mspm0_sdk_2_10_00_04/source/third_party/CMSIS/Core/Include",
                "E:/tools/CCS_20.5.0.00028_win/ccs/tools/compiler/ti-cgt-armllvm_4.0.4.LTS/include",
                "${workspaceFolder}",
                "${workspaceFolder}/Debug"
            ],
            "defines": [
                "__MSPM0G3507__",
                "__USE_SYSCONFIG__"
            ],
            "compilerPath": "E:/tools/CCS_20.5.0.00028_win/ccs/tools/compiler/ti-cgt-armllvm_4.0.4.LTS/bin/tiarmclang.exe",
            "cStandard": "c11",
            "cppStandard": "c++17",
            "intelliSenseMode": "windows-clang-arm"
        }
    ],
    "version": 4
}
```
也可以使用clangd作为语法服务器
```
# This is an auto-generated file - do not add it to source-control

CompileFlags:
   CompilationDatabase: Debug/.clangd

Diagnostics:
   Suppress: '*'


```

# 芯片解锁
## LaunchPad烧录芯片部分两个LED亮灭含义
|绿灯|红灯|含义|
|---|---|---|
|灭|灭|XDS110 没上电、正在启动，或处于调试器固件刷写模式|
|亮|灭|XDS110 正常工作，但当前没有有效 Debug 连接|
|亮|亮|XDS110 正常工作，并且已经有活动的 Debug 连接|
|亮|红灯快速闪烁|正在处理 Debug/SWD 通信事务，比如下载、擦写、单步、读写寄存器/内存|

## XDS110相关问题
烧录程序提示没有XDS110调试器连接，即为XDS110问题(连接线松动，XDS110芯片内固件损坏如第一次使用时提示升级固件但是中途中断等造成，XDS110芯片损坏)

![[20260504-170325_MSPM0开发环境与芯片解锁_70818b15393d.png]]

需要进入DFP模式(Device Firmware Upgrade设备固件升级)，使用官方软件重新烧固件，进入软件安装文件夹...\ccs_base\common\uscif\xds110，需要用到xdsdfu.exe，在该文件夹下打开powershell，

![[20260504-170325_MSPM0开发环境与芯片解锁_6f05b5182cba.png]]



```powershell
PS E:\tools\CCS_20.5.0.00028_win\ccs\ccs_base\common\uscif\xds110> ./xdsdfu.exe

...

Examples:

   xdsdfu -m

Switches the device into DFU mode.

   xdsdfu -f firmware_3.0.0.8.bin -r

...

ERROR: No file name was specified. The file name is required.
```
可以看到指令xdsdfu -m即为进入DFU模式，通常XDS110芯片异常会自动进入DFU模式，可以通过设备管理器查看，如果设备损坏比较严重可能无法自动进入DFU模式，参考E:\tools\CCS_20.5.0.00028_win\ccs\ccs_base\common\uscif\xds110路径下的readme.pdf中介绍的强制进入DFU模式
```
Recovering a Bricked XDS110 without JTAG
In the case that your XDS110 fails to enumerate as a USB device, or it fails to enter DFU
programming mode, you can attempt the following steps to force it into DFU mode to recover:
1. Ground the JTAG TDO pin of the XDS110's Tiva CPU. This is pin 97 on the 128 pin
device. (Check the TM4C1294NCPDT datasheet for the pin location; it is located on a
corner and easy to access.)
2. Unplug and re-plug the XDS110 into the host computer while the pin is grounded.
3. The XDS110 should now be in DFU programming mode.
4. Remove the connection to ground while the XDS110 remains powered.
5. Use the xdsdfu utility to update the firmware as detailed above
```
简而言之将ITDO接地后重新插入设备(左上角1和4号脚)，如果通过该方法仍不能进入DFU模式大概率XDS110芯片损坏需要更换芯片

![[20260504-170325_MSPM0开发环境与芯片解锁_7fd63ed8ce4a.jpg]]

终端可以先查看当前连接设备的状态



烧录时参考xdsdfu -f firmware_3.0.0.41.bin -r，注意版本需与你相同，同时要添加上./（这取决于所用终端）

![[20260504-170325_MSPM0开发环境与芯片解锁_1c81c0710ea2.png]]

以下为最终效果演示(成功烧录进固件后会自动识别到设备，记得拔掉杜邦线)

![[20260704-165214_MSPM0开发环境与芯片解锁_b208fc449846.png]]

![[20260504-170325_MSPM0开发环境与芯片解锁_536075c31712.png]]


## MSPM0G3507芯片解锁方式
若芯片被锁需要进入BSL模式下载一个正常程序
参考提供的文档Unlock MSPM0 instructions.pdf

  该文档介绍了 3 种解锁 MSPM0 微控制器的方法，均基于 XDS110 调试器：

---
  Method 0：进入 BSL 模式解锁

  通过硬件操作使 MCU 进入 BSL（引导加载程序）模式：

  - 连接 GND、DIO、CLK 到目标板
  - 断开 MCU 电源
  - 将 PA18 引脚拉高（LaunchPad 上插好 PA18 跳线帽）
  - 重新上电
  - 在 10 秒内保持 PA18 拉高状态进行烧录；若失败则转向 Method 1

---
  Method 1：强制 DSSM 批量擦除

  通过 CCS（Code Composer Studio）软件 + XDS110 进行强制批量擦除：

  硬件连接：GND、3.3V、DIO、CLK、RST（使用 LaunchPad 则无需额外接线和去跳线帽）

  软件步骤（CCS）：
  1. 打开 Target Configurations
  2. 找到对应工程的 .ccxml 文件
  3. 点击 Launch
  4. 显示所有核心（Show all cores）
  5. 连接 DAP（若不成功则换 Method 2）
  6. 执行 Mass Erase
  7. Console 出现提示后按 XDS110 的 Reset 按钮
  8. Console 提示后点击 Pause → Debug → 重新烧录代码
  9. 若报错，选择 Force Reset 并确保复位连接正常

---
  Method 2：BSL 解锁+专门配套的解锁工具MSPM0_BSL_GUI

  通过 UART 接口 + BSL 软件工具解锁：

  硬件连接：GND、3.3V、RXD、TXD、RST、BSL（PA18）

  ┌──────────┬──────┬──────┬──────┐
  │ 芯片型号 │ TXD  │ RXD  │ BSL  │
  ├──────────┼──────┼──────┼──────┤
  │ L1306    │ PA23 │ PA22 │ PA18 │
  ├──────────┼──────┼──────┼──────┤
  │ G3507    │ PA10 │ PA11 │ PA18 │
  └──────────┴──────┴──────┴──────┘

  软件步骤：
  10. 下载 MSPM0 SDK
  11. 打开 BSL 解锁软件
  12. 根据芯片型号选择对应固件（位于 input 文件夹）
  13. 更新 XDS110 固件
  14. 下载固件并解锁设备

---

有XDS110烧录器使用Method2最简单，次之选Method0

## uniflash烧录常见问题
### 1. 下载报错：Image loading falled: Try manual Bootloader invocation...

使用串口下载，在下载时报错Image loading falled: Try manual Bootloader invocation...，这个是这个下载软件的问题，实际上已经下载进去了。

![[20260717-155511_MSPM0开发环境与芯片解锁_b2ee3a475c39.gif]]

### 2. 下载报错：Image loading failed: Flash Generic, Loading lmages... Error: -9

![[20260717-155511_MSPM0开发环境与芯片解锁_76c0a4acb746.png]]

芯片没有正常进入升级模式。请重新进行以下操作：

操作步骤

在开发板保持通电的情况下，一直按住BSL，然后按一下RST键大概1秒，松开RST键，就可以正常进入升级模式。这时也可以松开BSL键。

按照以上操作之后，开发板就会进入升级模式。回到uniflash中，点击 Load image 即可下载。

**如果下载还是失败。**

请确保当前开发板除了一个数据线接到了USB口外，开发板上的TX RX引脚没有接入任何东西。

### 3. 下载报错：Image loading failed: Flash Generic, Loading lmages... Error: -6

![[20260717-155511_MSPM0开发环境与芯片解锁_0ed497b3debc.png]]

没有选择正确的下载端口。请通过设备管理器查看当前开发板的端口号是多少，然后手动输入到Uniflash中的 **COM Port** 选项栏。

![[20260717-155511_MSPM0开发环境与芯片解锁_45453e069901.png]]

### 4. 下载报错：Image loading failed: Flash Generic, Loading lmages... Error. -3

![[20260717-155511_MSPM0开发环境与芯片解锁_caf6bc6744eb.png]]

中文路径导致的。只要将要烧录的固件放到英文路径下就可以，放中文路径就报错。电脑用户名也不可以是中文，如果是中文请使用管理员打开这个软件。

### 5. 下载一直等待：Please Wait... Initialization Complete

![[20260717-155511_MSPM0开发环境与芯片解锁_23e882a73809.png]]

电脑的用户名不能是中文，中文必卡。修改电脑用户名的方法参考：[https://blog.csdn.net/weixin_42570192/article/details/126981939](https://blog.csdn.net/weixin_42570192/article/details/126981939)



