
封装、焊盘设计统一采用公制系统（mm）
精度要求：采用 mil 为单位时，精确度为 2；采用 mm 为单位时，精确度为 4。

## 封装基本组成元素
封装组成元素包含：沉板开孔尺寸、尺寸标注、倒角尺寸、焊盘、阻焊、孔径、花焊盘、反焊盘、Pin_number、Pin 间距、Pin 跨距、丝印线、装配线、禁止布线区、禁止布孔区、位号字符，装配字符、1 脚标识、安装标识、占地面积、器件高度。

一个完整的封装是由许多不同元素组合而成的；不同的器件所需的组成元素也不同。
在封装设计过程中，下面几项是必须包含的：
1、焊盘（包括阻焊、孔径等内容）
2、丝印
3、装配线（针对 Allegro 软件）
4、位号字符
5、1 脚标识
6、安装标识
7、占地面积（针对 Allegro 软件）
8、器件最大高度
9、极性标识
10、原点


## 焊盘简介
==1、焊盘分类及作用==
**Regular Pad**：规则焊盘，在正片中看到的焊盘，也是基本的焊盘。
**Thermal Relief**：热风盘，也叫花焊盘，在负片中有效，设计用于在负片中焊盘与敷铜的接
连方式，防止焊接时散热太快，影响工艺。
**Anti Pad**：隔离焊盘，焊盘与敷铜的间距，负片工艺中有效。
**Soldermask**：阻焊层，规定绿油开窗大小，以便进行焊接。
**Pastemask**：钢网层，定义钢网开窗大小，贴片的时候会按照钢网的位置和大小，进行锡膏
涂敷。

==2、贴片类焊盘==
**（1）常规焊盘**
Regular Pad = 器件管脚尺寸+补偿值。（补偿值请参考“封装管脚补偿”处理，在后面）
Solder Mask = Regular Pad + 0.15 mm= Regular Pad + 0.10 mm （For BGA）
Paste Mask= Regular Pad
**（2）Shape 类型**
Regular Pad = Shape 大小
Solder Mask = Regular Pad
Paste Mask= Regular Pad
==3、通孔类焊盘==
Drill Size = Physical_Pin（参考“管脚补偿计算规则”，在后面）
Regular Pad = Drill_Size + 0.4 mm (Drill_Size ＜ 0.8mm)
= Drill_Size + 0.6 mm ( 3 mm ≥ Drill_Size ≥ 0.8 mm )
= Drill_Size + 1 mm (Drill_Size > 3 mm )
Thermal Pad = Thermal Pad（参考“Flash 计算规则”）
Anti Pad= Drill_Size + 0.8 mm
Solder Mask = Regular Pad + 0.15 mm

![[20260603-090853_PCB封装设计规范_a1caaaf538d8.png]]

![[20260603-091014_PCB封装设计规范_4338cc755367.png]]

## 封装管脚补偿
**1、无引脚延伸型SMD封装**

![[20260603-092534_PCB封装设计规范_dc823e96bafa.png]]

![[20260603-092546_PCB封装设计规范_c6876c96626b.png]]

**2、翼形引脚型SMD封装**

![[20260603-092606_PCB封装设计规范_9fb98d9a2a27.png]]

**3、平卧型SMD封装**

![[20260603-092627_PCB封装设计规范_8d94feb58eae.png]]

4、J形引脚SMD封装

![[20260603-092648_PCB封装设计规范_32f51b828425.png]]

 **5、圆柱式引脚SMD封装** 

![[20260603-092718_PCB封装设计规范_47276c6c99d1.png]]

**6、BGA类型封装**

![[20260603-092735_PCB封装设计规范_340bd82ea60a.png]]

![[20260603-092806_PCB封装设计规范_69324d978564.png]]

## 封装设计基本要求

![[20260603-152331_PCB封装设计规范_3dc53c30e0b3.png]]

![[20260603-152412_PCB封装设计规范_2fc7647d4b85.png]]

