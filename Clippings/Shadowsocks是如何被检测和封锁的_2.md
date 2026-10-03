---
title: "Shadowsocks是如何被检测和封锁的"
source: "https://gfw.report/publications/imc20/zh/"
author:
published: 2022-01-28
created: 2026-05-27
description:
tags:
  - "clippings"
---
**作者:** Alice, Bob, Carol, Jan Beznazwy, Amir Houmansadr

[Internet Measurement Conference (IMC) 2020](https://conferences.sigcomm.org/imc/2020/schedule/)

English Version: [How China Detects and Blocks Shadowsocks](https://gfw.report/publications/imc20/en)

- [论文](https://gfw.report/publications/imc20/data/paper/shadowsocks.pdf)
- [演讲视频及幻灯片](https://gfw.report/talks/imc20/zh/)
- [开源代码及数据集](https://github.com/gfw-report/imc20-shadowsocks)
- 社交媒体:
	- [中文推文](https://x.com/gfw_report/status/1321296272486223873), [英文推文](https://x.com/gfw_report/status/1321296083440586752)
- 媒体报道:
	- [Wire China](https://www.thewirechina.com/2020/08/30/security-rift/)
- 奖项:
	- 🏆 ACM Internet Measurement Conference 2020 Best Paper Award Runner-up (3/216)

首次发布日期: 2020年10月07日, 星期三

最后修改日期: 2025年3月1日, 星期六

## Shadowsocks是如何被检测和封锁的

## 摘要

Shadowsocks是中国最流行的“翻墙”工具之一。自2019年5月以来，出现了许多关于封锁Shadowsocks导致用户无法使用这款工具的轶事。在这项研究中，我们揭示了中国的防火长城（GFW）是如何检测并封锁Shadowsocks及其变种的。通过网络测量实验，我们发现GFW会根据每个连接中的第一个数据包的长度和熵来识别Shadowsocks流量；然后再向被怀疑是Shadowsocks的服务器分阶段地发送7种不同的主动探测，来验证其怀疑。

我们开发了一个主动探测模拟器，并用它来分析不同的主动探测对不同版本的Shadowsocks的作用，从而猜出不同种的主动探测分别利用了Shadowsocks的哪些弱点。我们还分析了GFW主动探测的指纹，并与之前关于GFW主动探测的研究所发现的指纹比较了异同。分析TCP层的旁道信息，我们还发现：来自上千个不同IP地址的主动探测，其实很有可能是受一小撮中心化结构的集中控制。

根据我们从实验中获得的理解，我们展示了一个成功缓解流量分析的方法。我们还讨论了对抗主动探测所必要的策略。我们向Shadowsocks开发者们负责任地披露了我们的发现和建议，从而已经让Shadowsocks变得更加地难以封锁。

## 1 引言

Shadowsocks是一种规避互联网审查的协议，在中国特别常见。根据2015年7月的一项调查， 在清华大学371名教职员工和学生中，21% 的人使用 Shadowsocks 绕过中国的审查制度 \[[^28], §4.1\]。Shadowsocks的流行源于它简单易用的特性。其轻量级设计将代理流量的开销降至最低，并且使其易于在各种平台上实施。较大的盈利型代理服务器经销市场，以及海量的使用教程和一键安装脚本，降低了安装和使用Shadowsocks的难度，甚至在非技术用户中也很受欢迎。早在2017年10月，已有中国用户报告他们使用的Shadowsocks服务器变得不可靠，或被防火墙 (GFW)封锁，特别是在政治敏感期 \[[^21]\]。最近的一次此类事件发生在2019年9月中旬，当时Shadowsocks中国用户报告称，封锁力度突然增强 \[[^17]\]。总结了过去的封锁事件。尽管有轶事证据表明GFW能够检测和封锁Shadowsocks服务器，但关于GFW实际如何做到这一点，人们对此知之甚少。Shadowsocks在规避审查方面的重要作用，以及GFW的神秘行为，促使我们探索和理解其检测和拦截的内在机制。

我们通过系统研究发现，GFW已经开始结合使用 *被动流量分析* 和 *主动探测* 来识别Shadowsocks服务器。 [图1](#fig:1-active-probing) 阐明了一般概念：GFW首先通过每个连接中第一个数据包的大小和熵等特征检测到可疑的Shadowsocks流量。一旦服务器受到怀疑，GFW在不同的阶段，发送主动探测确认服务器是否真的是Shadowsocks。探测可能是对过去合法连接的重放，也可能是字节长度不一的随机探测。我们怀疑，这些探测旨在攻击不同Shadowsocks实施中的检测漏洞。据我们所知，自2011年以来，GFW对各种“翻墙”工具使用主动探测 \[[^14]\]，但是现在针对Shadowsocks采用的是新技术并且比之前报告的更加复杂。

![[20260527-211855_Shadowsocks是如何被检测和封锁的_2_86fef0815ce7.png]]

图1： 主动探测的工作原理。正版Shadowsocks客户端连接到Shadowsocks服务器；一旦GFW被动地判断此连接 可能 是Shadowsocks，它会指示主动探测器来确认这个猜测。

总之， 我们的工作做出了以下贡献：

- 通过系统研究揭示了GFW用于封锁Shadowsocks的最新秘密武器。
- 通过指纹读取识别了不同类型的主动探测，然后推断其背后的可能意图。
- 推导了一个更现实的重放攻击对手模型。
- 针对检测引入了一种临时但有效的缓解措施，并提供了防御主动探测的建议。
- 与不同Shadowsocks实施的开发人员合作，增强Shadowsocks抵抗主动检测攻击的能力。

## 2 Shadowsocks背景简介

Shadowsocks是一种加密代理协议。它试图规避监测，但不是通过模仿其他协议，而是通过加密显示为均匀随机的字节流。它有两个组件：客户端与服务器。服务器通常安装在不由审查员控制的某个网络上。客户端将加密的目标规范发送到服务器。然后服务器连接到目标并开始为客户端代理流量。客户端与服务器之间的所有流量均已加密。

为了理解 [第3.2节](#sec:3.2-probe-types) 中描述的探测构造，了解Shadowsocks加密工作原理的一些详细信息至关重要。Shadowsocks指定了两类主要的加密结构，在协议的上下文中称为“流加密”和“AEAD加密” \[[^45]\]。流加密结构从密码学角度而言很弱，它只提供机密性，不提供完整性或身份验证，并因此遭到弃用。AEAD加密结构（相关数据经过身份验证加密）开发用于修复流加密结构的缺陷，而且提供机密性、完整性和身份验证。两种结构都由客户端与服务器共享的主密码键控，并且都要求客户端证明其了解共享密码然后才能使用代理服务器（尽管正如我们看到的，对于流加密，要求比较宽松）。

如果使用流加密，则两个方向的网络流是一个长密文，它前面则是一个随机初始化向量：

> ```
> [长度可变 IV][已加密负载...]
> ```

客户端与服务器使用相同的加密密钥，但使用不同的初始化向量。初始化向量的长度可能是8、12或16字节，具体取决于配置的密码。

如果使用AEAD加密，则网络流是一系列以长度为前缀的块，每个块都使用AEAD标记进行加密和身份验证。为避免引入任何明文供审查员匹配，长度前缀本身会经过加密和标记处理。

> ```
> [长度可变加密盐]
> [2字节已加密长度][16 字节长度标记][已加密负载][16 字节负载标记]
> [2 字节已加密长度][16 字节长度标记][已加密负载][16 字节负载标记]...
> ```

整个流前面有一个加密盐，与共享的秘密密码搭配使用可为每个方向生成一个会话密钥。加密盐可能是16、24或32字节。

在两种结构中，客户端通过隧道发送的第一条数据是host:port目标规范，其结构借鉴了SOCKS代理协议。第一个字节是地址类型，指示后面字节的格式。三种地址类型是：

> ```
> [0x01][4 字节 IPv4 地址][2 字节端口]
> [0x03][1 字节长度][主机名][2 字节端口]
> [0x04][16 字节 IPv6 地址][2 字节端口]
> ```

Shadowsocks有多种实施 \[[22](##cite:goShadowsocks2), [^24], [^40], [^43], [^44], [^46]\]，它们支持的功能各不相同。并非每种实施都支持所有可能的加密构造；例如，OutlineVPN \[[^24]\]仅支持AEAD加密，不支持流加密。一些实施采取措施来减轻重放攻击，而另一些实施则不会。这意味着，探测对手时可能会遇到不同的探测反应，具体取决于所采用的Shadowsocks实施。在本次研究中，我们主要侧重于两种更常见的实施，Shadowsocks-libev \[[^44]\]和OutlineVPN \[[^24]\]，但是，我们描述的漏洞也可能适用于其他实施。

### 2.1 历史漏洞与防御措施

2015年8月，BreakWa11发现Shadowsocks流加密因缺乏完整性保护而导致的一个主动探测漏洞 \[[^8], [^15]\]。攻击者可以与可疑的Shadowsocks服务器建立许多连接，并利用密文的延展性尝试使用与目标规范中的地址类型相对应的字节的每个可能值。因为只有0x01、0x03和0x04是有效的地址类型，已知部分的连接与其他连接的超时不同。Shadowsocks开发人员通过让服务器在目标规范包含未知地址类型时不立即终止连接来缓解该漏洞 \[[^29]\]。

Shadowsocks开发人员还尝试通过引入“一次性验证”模式来进一步缓解该问题，其中每个数据块都将携带自己的身份验证程序。但是，由于块长度前缀缺乏完整性保护，导致出现了另一个主动探测漏洞 \[[^15], [^36]\]。2017年2月，AEAD加密成为协议规范的一部分，这个身份验证问题得以修复。

2020年2月，彭峙酿披露了Shadowsocks流加密中一个极具破坏力的漏洞 \[[^16], [^35]\]。使用Shadowsocks服务器作为解密预言库，攻击者即使是在不知道共享主密码的情况下，也可以完全解密记录的Shadowsocks连接。

### 2.2 过去的Shadowsocks封锁事件

早在2017年10月，已有中国互联网用户报告Shadowsocks服务器遭到端口或IP地址封锁 \[[^21], [^37], [^41]\]。值得注意的封锁事件发生在2017年10月和2018年1月，适逢两场重要的政治性会议在中国召开 \[[^21]\]。这两场会议结束后，许多用户报告称，他们的服务器已解除封锁。Wiley等人则列出了相反的证据，在那段时间里，他们每天都在世界各地的不同地点测试Shadowsocks的连接情况，但却表示没有看到Shadowsocks在任何地方遭到封锁的证据 \[[^52]\]。

报告的大规模封锁事件通常发生在政治敏感期，包括1989年天安门事件30周年、中华人民共和国成立70周年以及中国共产党第十九届四中全会。最近的多起封锁报告开始于2019年9月16日前后 \[[^17]\]。

## 3 探测表征描述与探测基础设施

本节介绍了为收集和了解GFW的主动探测机制而进行的实验。基于在多组实验中观察到的51837次主动探测的一堆数据，我们回答了以下问题：

- 观察到哪些类型的探测，以及探测的条件？
- 探测来源于哪里？
- 探测是否有任何“指纹”，可用于揭示有关底层探测基础设施的信息？
- 探测是否有任何“指纹”，可用于揭示有关底层探测基础设施的信息？合法连接与对其做出反应的探测之间存在多长的时间延迟？

### 3.1 Shadowsocks服务器实验

我们设置了自己的Shadowsocks服务器，并试图引诱GFW对这些服务器进行探测。为此，我们使用Shadowsocks客户端连接服务器，并以Web浏览器和curl作为自动化驱动程序，通过加密代理隧道发送HTTP和HTTPS流量。我们在两端捕获数据包进行分析。全部实验均使用未经修改的客户端和服务器，未创建任何特定防火墙规则，未安装任何混淆插件。如 [表1](#tbl:1-experiment-timeline "Table 1: 2. Background on Shadowsocks – How China Detects and Blocks Shadowsocks") 中所述，实验为期4个月，从2019年9月29日到2020年1月21日。

| 实验 | 时间跨度 |
| --- | --- |
| Shadowsocks | Shadowsocks 2019年9月29日至2020年1月21日（4个月） |
| Sink | Sink 2020年5月16日至5月31日（2周） |
| Brdgrd | Brdgrd 2019年11月2日至11月19日（403个小时） |

[**表1：**](#tbl:1-experiment-timeline) **所有实验时间表。三组实验持续了数周和数月。Shadowsocks、Sink和Brdgrd分别参考了 [第3.1节](#sec:3.1-shadowsocks-server-experiments) 、 [4.1节](#sec:4.1-experiments) 和 [7.1节](#sec:7.1-defense-against-traffic-analysis) 中的实验。**

因为无法预知GFW可能使用哪些特征来识别Shadowsocks，我们通过两种途径尽可能地扩大实验覆盖范围：一是采用不同的Shadowsocks实施和版本，二是选用不同的加密算法。所用的两种实施分别是Shadowsocks-libev \[[^44]\]和 OutlineVPN \[[^24]\]。

**Shadowsocks-libev。** 在腾讯云北京数据中心的五个虚拟专用服务器(VPS)上，我们安装了Shadowsocks-libev客户端，并在DigitalOcean英国数据中心的五个VPS上安装了Shadowsocks-libev服务器。每个客户端均配置为仅与其中一个服务器连接。其中，两组客户端和服务器使用Shadowsocks-libev v3.1.3，另三组使用v3.3.1。作为实验对照，在同一英国数据中心另设置了一个VPS，并且该VPS未与任何客户端连接，仅捕获所有传入流量。

使用curl生成客户端流量，我们通过Shadowsocks代理，以既定频率持续获取其中一个网站的数据： [https://www.wikipedia.org](https://www.wikipedia.org/) 、 [http://example.com](http://example.com/) 以及 [https://gfw.report](https://gfw.report./) 。

**OutlineVPN。** 在一所美国大学网络中，我们安装了OutlineVPN v1.0.7服务器。 使用2019年10月的最新版OutlineVPN客户端，并该客户端位于中国居民网络中。客户端流量由Firefox实例提供，配置为自动浏览在中国受到审查的Alexa前100万个网站的子集。

**局限性。** 由于实验地点不够多样化，我们不太可能在探测系统中观察到，因地理位置引起的任何潜在不一致。

### 3.2 探测类型

对运行Shadowsocks的服务器端口的所有连接进行分析并使用对照主机接收的流量，用以验证观察到的探测均由我们自己的连接触发，而不是互联网“背景辐射”扫描的结果。在所有实验中观察到总计51837次主动探测。我们将探测分为两种类别：基于重放与貌似随机；并进一步区分这两种类别下的探测类型。第一类基于重放的探测包含一个负载，源自某些先前记录的合法连接的第一个数据传输包。我们将这一类探测的名称指定为以“R”（表示“重放”）开头：

- **R1型：** 相同的重放。
- **R2型：** 重放，字节0已更改。
- **R3型：** 重放，字节0-7和62-63已更改。
- **R4型：** 重放，字节16已更改。
- **R5型：** 重放，字节6和16已更改。

R3、R4和R5型探测，仅在OutlineVPN实验中出现，但在Shadowsocks-libev实验中未出现。R5型探测在实验中仅出现两次。

另一类貌似随机的探测，具备不同的长度。其内容在任何方面都不同于之前我们可识别的合法连接。我们将这一类探测的名称指定为以“NR”（表示“非重放”）开头：

- **NR1型：** 探测长度为7-9、11-13、15-17、21-23、32-24、40-42或48-50字节。
- **NR2型：** 探测长度恰好为221字节。

[图2](#fig:2-random-probe-length-distribution "Figure 2") 展现了NR1型和NR2型探测的分布。 NR1型探测的长度呈三重奏式分布，集中于8、12、16、22、33、41和49字节。有关这种分布的更多说明，请参阅 [第5.2节](#sec:5.2-intention-behind-random-probes "5.2. Intention Behind Random ProbesP") 。

![[20260527-211856_Shadowsocks是如何被检测和封锁的_2_c512b4394881.png]]

图2： 随机探测（NR1型与NR2型）的出现次数（按长度统计）。请注意查看两个垂直轴不同。NR1型探测的长度以三重奏 的方式均匀分布，其中 。 NR2型探测的长度为221个字节，并且大约是所有NR1型探测总和的三倍。

### 3.3 探测器来源

对于主动探测，一种简单的防御策略，就是发现并禁止探测器的IP地址。我们接下来将介绍，实施这样的防御可能是一件极具挑战性的事，因为GFW从大量不同的IP地址池中进行探测，并且周转率较高。

![[20260527-211855_Shadowsocks是如何被检测和封锁的_2_282cd9e6b5fb.png]]

图3： 每个探测器IP地址的累计探测次数。

**IP地址。** 51837次主动探测发自12300个独立来源IP地址，这些IP地址均位于中国。 [图3](#fig:3-cumulative-number-of-probes "Figure 3><span") 显示了每个独立IP地址发送的探测数量的分布。以前的研究发现“95%的地址只出现一次” \[[^14], §5.3\]，与此形成对比的是，我们的测试发现，75%的地址发送一次以上的探测。 [表2](#tbl:2-IP-addresses "Table 2") 列出了最常见的探测器IP地址。

| 探测器IP地址 | 计数 |
| --- | --- |
| 175.42.1.21 | 44 |
| 223.166.74.207 | 38 |
| 124.235.138.113 | 36 |
| 113.128.105.20 | 36 |
| 221.213.75.88 | 33 |
| 112.80.138.231 | 32 |
| 116.252.2.39 | 32 |
| 124.235.138.231 | 32 |
| 221.213.75.126 | 32 |
| 223.166.74.110 | 31 |

[**表2：**](#tbl:2-IP-addresses) **最常见的探测器IP地址及其出现次数。**

将我们的探测器IP地址列表，分别与下述地址进行了比较：Dunna等人在2018年观察到的向Tor服务器发送主动探测的934个地址 \[[^13]\]，以及Ensafi等人在2010年至2015年期间观察到的发送各种类型主动探测的22000个地址 \[[^14]\]。 [图4](#fig:4-comparison-with-other-probe-source "Figure 4: IP addresses.") 表明，这三组地址仅略有重叠。我们注意到，在以前的实验中负责发送大量探测的IP地址202.108.181.70 \[[^14], §5.3\]，并未出现在我们的观察数据中。鉴于以前的研究中观察到探测器IP地址周转率较高，这种仅有小部分重叠的结果实属意料之中。

![[20260527-211855_Shadowsocks是如何被检测和封锁的_2_609817186618.png]]

图4： 独立收集的不同数据集之间探测器来源IP地址的重叠。

**自治系统。** 探测器自治系统(AS)分布如 [表3](#tbl:3-counts-of-unique-prober-IP-addresses) 。大部分Shadowsocks探测来自AS4837(CHINA169-BACKBONE CNCGROUP China169 Backbone)和AS4134(CHINANET-BACKBONENo.31, Jin-rong Street)这两个AS。二者在以前的研究 \[[^14], [^55]\] 中也是最常见的。与以前的研究重叠的其他AS还包括AS17816、AS9808、AS56046、AS17638、AS56047和AS17622。AS17622(CNCGROUP-GZ China Unicom Guangzhou network)发送探测所占比例比之前的研究高出不少 \[[^14] Figure 7\]。其他以前观察到的AS未出现在我们的数据中，包括AS7497 (CSTNET-AS-AP Computer Network Information Center)，这是Ensafi等人观察到的第三常见的探测来源 \[[^14]\]。数据集中还有一些AS，以前未曾作为主动探测来源留下记录。

| AS4837 | 6262 | AS58563 | 44 |
| --- | --- | --- | --- |
| AS4134 | 5188 | AS17638 | 17 |
| AS17622 | 315 | AS9808 | 2 |
| AS17621 | 263 | AS4812 | 1 |
| AS17816 | 104 | AS24400 | 1 |
| AS4847 | 101 | AS56046 | 1 |
| AS56047 | 1 |  |  |

[**表3：**](#tbl:3-counts-of-unique-prober-IP-addresses) **覆盖所有实验，每个自治系统独立探测器IP地址的计数。**

### 3.4 对探测进行指纹读取

与以前的研究一样，我们对主动探测的数据包层的特征进行了指纹读取。在IP层，我们检查了ID和TTL字段。在TCP层，我们查看了源端口和时间戳。

**IP、ID和TT。** 我们对探测器发送的PSH/ACK数据包的IP、ID和TTL进行了指纹读取。与Ensafi等人 \[[^14], §5.5\]的实验结果一样，我们在IP ID序列中未找到明显的模式，而且TTL保持在46–50秒内。

**TCP源端口。** 约90%的探测源端口属于32768–60999。 [图5](#fig:5-CDF-source-port) 中着重指出的这个范围，其恰好是许多Linux内核的默认源端口范围。探测从未使用低于1024的源端口（我们在一项实验中看到的精确最低值是1212）\[[^14], §5.5\]。这些结果与以前的研究不同，当时观察的结果是：探测使用所有端口，并且某个端口范围并未比其他更常见。

![[20260527-211855_Shadowsocks是如何被检测和封锁的_2_5b3fc2659dd9.png]]

图5： 一次实验中探测TCP源端口号的累积分布函数，包括1,576 次探测。

**TCP时间戳(TSval)。** TCP时间戳是以固定速率增加的32位计数器，附加到每个非RST TCP段 \[[^7], §3\]。时间戳并不是一个绝对值，但与计数器的初始化方式和时间有关，而且其增长率因操作系统而异。 [图6](#fig:6-tsval-lon) 显示每次探测SYN段附带的时间戳值。该图显示，虽然探测器使用了成千上万个源IP地址，但是这些地址无法完全独立，因为它们共享少量的TCP时间戳序列。在这种情况下，至少有七个不同的物理系统或进程，绝大多数的探测类型，属于这七个类型其中的一种。之所以说“至少”七个，是因为我们无法区分TSval序列非常接近的两个进程（例如，如果两个进程几乎同时重新启动，可能发生这种情况）。 我们测量得出的线性序列斜率几乎正好是250Hz，除了22个间距较近的点，它们组成了一个小集群，其斜率接近1000Hz。有两种情况，序列达到最大值 232−1 $232−1$ $2^{32} -
  1$ 并重置为0。将 [图6](#fig:6-tsval-lon) 与Ensafi等人提供的图11(c)进行比较 \[[^14]\]，后者也显示了250Hz和1000Hz序列。

![[20260527-211856_Shadowsocks是如何被检测和封锁的_2_c6b0aa053118.png]]

图6： 常见TCP时间戳序列揭示了非独立进程。带标签的标记线斜率恰好是250Hz和1000Hz。1000Hz线上的22次非重放探测小集群局部斜率达到1009Hz，但此处的测量并非确凿无疑，因为它们仅持续了约3.5秒。即使连接到左侧零星分布的某个非重放数据点，1000Hz线条也不会变成250Hz。

### 3.5 重放攻击的延迟

GFW可能记录真正的客户端连接的第一个数据传输包，然后稍作修改，将其作为主动探测进行重放。 [图7](#fig:7-delay-of-replay) 显示了从建立合法连接到GFW发送源于该连接基于重放的探测，二者之间的延迟变化。因为可能会多次重放探测负载（在一种情况下，最多达47次），我们展示了两种分布，一种包含重复负载，一种不含重复负载。橙色线代表每个重放探测负载 *首次* 发生的延迟，而蓝色线代表 *全部* 重放探测的延迟，包括重复负载。探测总计：首次发生有3269次，全部发生有11137次。

超过20%的探测首次重放在一秒内到达；超过50%的探测首次重放在一分钟内到达；超过75%的探测首次重放在15分钟内到达。基于重放的探测可能会立即发送，也可能会存储很长时间然后再发送。我们观察到的最短延迟时长为0.28秒，最长延迟时长为570小时。

![[20260527-211856_Shadowsocks是如何被检测和封锁的_2_f3cba084a3fc.png]]

图7： 基于重放的探测延迟累积分布函数。注意查看对数 轴。

## 4 触发主动探测的条件

关于GFW如何发现Shadowsocks服务器，存在着对立的假设。一种假设是大规模的 *主动* 端口扫描； 另一种假设是由合法连接触发 *被动* 探测。但是，基于 [上一节](#sec:3-characterization "3. Characterization of Probes and the Probing Infrastructure") 中未使用的对照主机没有收到任何主动探测这一事实，我们抛弃了主动扫描这种假设。相反，我们提出这样一种假设：仅当探测系统发现可疑的Shadowsocks连接时才会发送探测。

那么，从GFW的角度来看，什么内容构成可疑的Shadowsocks连接？在本节中，我们主要探讨以下这些问题：

- 触发主动探测需要多少流量？
- 为什么R3型、R4型和R5型探测仅发送到OutlineVPN服务器，而未发送到Shadowsocks-libev服务器？
- GFW是否考虑数据包长度？
- GFW是否考虑数据包负载的熵？
- 外部到内部连接（客户端在中国境外，服务器在中国境内）是否引起与内部到外部连接一样多的主动探测？

### 4.1 实验

为展示GFW使用何种特征进行流量分析，最令人信服的做法是提出触发主动探测的最低且可复现的一组条件。毫无疑问，完成这项工作是本次研究最具挑战性的任务，因为这要求我们从无数的可能性中找到GFW真正使用的少数特征。

两种观察结果有助于我们的分析。第一，根据设计，Shadowsocks客户端与服务器之间发送的字节流与随机字节流无法区分。这意味着，我们不必使用真正的客户端Shadowsocks实施；可通过发送随机数据来触发主动探测。第二，如 [第3.5节](#sec:3.5-delay-of-replay-attacks "3.5. Delay of Replay Attacks") 中所述，发送合法数据包后，重播探测最快可在0.28秒后发送。GFW在确定流量可疑之前，可能只看到了客户端到服务器流最开始的部分。

在这两个观察结果的启发下，我们实施了一个TCP客户端，将其连接到TCP服务器并发送一个具有指定长度和香农熵的数据包。我们实施了具有两种运行模式的服务器：接收模式和响应模式。在接收模式下，服务器接受TCP连接但不响应任何数据，并在30秒后关闭连接。在响应模式下，服务器以1到1000字节的随机数据响应探测器——但不响应我们实施的客户端。

[表4](#tbl:4-summary-of-random-data-experiments "Table 4") 总结了随机数据实验的设计。 [表1](#tbl:1-experiment-timeline "Table 1: Background on Shadowsocks and How China Detects and Blocks Shadowsocks") 显示了实验的时间跨度。客户端在北京同一腾讯数据中心内的不同 VPS 上运行。所有服务器都在美国同一Digital Ocean数据中心运行。各组实验中未重复使用客户端与服务器 IP 地址。

| 实验# | 长度（字节） | 熵 | 模式 |
| --- | --- | --- | --- |
| 1.a | \[1, 1000\] | \> 7 | 接收 |
| 1.b | \[1, 1000\] | \> 7 | 响应 |
| 2 | \[1, 1000\] | < 2 | 接收 |
| 3 | \[1, 2000\] | \[0, 8\] | 接收 |

[**表4：**](#tbl:4-summary-of-random-data-experiments) **随机数据实验总结。"\[x, y\]"表示每个连接各自从一个范围内均匀随机采样的值。在实验1中，服务器在310小时后从接收模式切换到响应模式；我们将这两个阶段分别标记为实验1. a和实验1.b。**

### 4.2 实验结果与分析

**触发主动探测所需的流量极少。** 我们的接收服务器，尽管不是真正的Shadowsocks服务器并且从不发送数据，但接收了许多与 [第3.1节](#sec:3.1-shadowsocks-server-experiments "3.1. Shadowsocks Server Experiment") 中描述的Shadowsocks服务器实验相同类型的探测。在完成TCP握手之后，单个从客户端到服务器的数据包足以触发主动探测。

**仅某些长度被重放。** 虽然客户端发送的数据包长度介于1至2000字节之间，但是几乎所有被判断为重放的探测，其负载长度都介于160至700字节之间，最大长度为999字节。 [图8](#fig:8-CDF-payload-length "Figure 8") 显示了实验1.a中探测长度的分布。长度分布呈阶梯状，反映了某些长度更有可能重放的事实。也就是说，重放探测长度除以16后的余数往往是特定值。对于R1型探测（R2型类似），在长度介于168-263字节区间的376次探测中，72%的长度除以16后余数是9；在长度介于384-687字节区间的1558次探测中，96%的长度除以16后余数是2；在长度介于264-383字节区间的749次探测中，余数可能是9(37%)或2(32%)。这些结果表明，GFW在对Shadowsocks流量进行归类时会考虑数据包长度。数据包长度是一个可利用的合理特性，因为Shadowsocks不填充隧道的内容，只是通过添加地址头前缀（请参阅 [第2节](#sec:2-background "2. Background on Shadowsocks") ）以及使用AEAD加密、长度前缀和标签来附带地更改底层数据包长度分布。因此，Shadowsocks流量的负载长度分布类似于底层流量，通常为HTTP或TLS。

![[20260527-211856_Shadowsocks是如何被检测和封锁的_2_12460cea8a88.png]]

图8： 实验1. a中310小时内重放探测负载长度的累积分布函数。重放探测长度呈阶梯状分布。

**高熵的数据包更可能被重放。** 有两个证据支持这一结论。第一， [图9](#fig:9-replayed-ratio "Figure 9") 显示，虽然各种熵的数据包都可能被重放，但是每字节高熵值为7.2的数据包被重放的可能性，几乎是低熵值为3.0的数据包的四倍。第二，实验1.a和实验2仅在数据包的熵上有所不同，在同一时间段内，实验1.a中服务器接收的探测显著多于实验2中服务器。

![[20260527-211856_Shadowsocks是如何被检测和封锁的_2_1bc3c3d51f8e.png]]

图9： 根据合法连接的每字节熵，实验3中重放探测与合法连接的比率。

**除非服务器之前已响应R1型和R2型探测，否则不会发送R3型和R4型探测。** 实验1.a、实验2和实验3中收到的数千次探测均可归类为R1型、R2型或NR2型。换言之，在这些实验中，我们无法触发R3型、R4型、R5型或NR1型探测。这个结果提醒我们，在 [第3.1节](#sec:3.1-shadowsocks-server-experiments "3.1. Shadowsocks Server Experiment") 的实验中，只有OutlineVPN服务器接收到R3型、R4型和R5型探测，而Shadowsocks-libev服务器没有接收到。

如 [第5.3节](#sec:5.3-intention-behind-replay-based-probes "5.3. Intention Behind Replay-based Probes") 中的详细阐述，我们使用的Shadowsocks-libev与OutlineVPN版本之间的一个主要区别是Shadowsocks-libev具有防御重放的过滤器，而OutlineVPN没有。（至少在我们使用的版本中没有，此后OutlineVPN添加了重放防护 \[[^25]\]。）因此，Shadowsocks-libev服务器不响应早期连接的精确重放，而OutlineVPN服务器响应。

因而我们提出假设：除非服务器已经响应R1型和R2型探测，否则GFW不会发送R3型、R4型和R5型探测。在接收模式下运行310个小时后，我们将实验1.a中的服务器切换到响应模式。服务器开始响应R1型和R2型探测之后，随即开始接收大量R3型和R4型探测。服务器同时继续接收R1型和R2型探测。

这些结果表明，主动探测系统分阶段运行。在观察到特定条件之前，它不会进入下一个阶段。这一实施的详细信息表明，审查员在设计主动探测系统时可能不仅仅考虑了Shadowsocks，其他具有类似行为的协议也可能是探测目标。

在四个随机数据实验中未出现R5型和NR1型探测，我们不知其原因。

**观察到新探测类型。** 接收/响应服务器收到的探测与之前在Shadowsocks-libev和OutlineVPN的实验中看到的探测类型不匹配。在实验1.b中，我们看到11个基于重放的探测，其中字节16到32已更改。在所有四个实验中，还出现许多非重放探测。总体而言，有9个长度为53字节的探测、5个长度为56字节的探测、3个长度为169字节的探测、1个长度为180字节的探测以及1个长度为402字节的探测。

**GWF不区分流量方向。** 我们在中国设置了一个Shadowsocks服务器，并从境外连接自动浏览Alexa排名前100万网站的子集，由此生成代理流量。服务器收到大量主动探测。这个结果表明，无论服务器是在中国境内还是境外，GFW都会对可疑服务器进行探测。这种双向触发探测的行为，与Winter和Lindskog的观察不同，他们在研究中发现外部到内部的Tor连接不会触发主动探测 \[[^55], §4.4\] 。另一方面，对于许多协议，GFW已知不作流量方向的区分，其中包括DNS \[[^1], §2\]，HTTP \[[^11], §3\]和TLS \[[^9], §3.1\]。甚至已知，GFW对方向的敏感度会随着时间而变化，如TLS ESNI的封锁案例，其中有两周是双向然后变成单向 \[[^6]\]。

## 5 探测背后的意图

如 [第3.2节](#sec:3.2-probe-types "3.2. Probe Types") 中所述，针对Shadowsocks服务器，我们发现了七种不同类型的主动探测。本能的疑问就是：GFW可以从这些探测中获得什么信息？与以前的研究不同 \[[^14], [^55]\]，在我们看来，简单地观察探测无法回答这个问题。我们推测，如果探测引发的Shadowsocks服务器反应与非Shadowsocks服务器不同，GFW可肯定地将服务器归类为Shadowsocks。

因此，关键在于理解这些探测对Shadowsocks服务器的影响。我们开发了一个探测模拟器，用于观察Shadowsocks服务器如何对诸如GFW之类的探测进行反应。我们进一步查看Shadowsocks实施的源代码，以了解其内在逻辑。基于这一分析，我们进行推测：何种可辨识的服务器反应可用于归类。

### 5.1 探测模拟器实验

我们开发了一个探测模拟器，可向Shadowsocks服务器发送全部七种类型的探测，并记录各自的反应。借助探测模拟器，可在本地高效测试各种不同配置的Shadowsocks实施。此外，探测模拟器可令实验涵盖实施的临界情况，并发现一些可能尚未被GFW利用的可识别指纹特征。

**基于重放的探测。** 为模拟基于重放的探测，模拟器记录Shadowsocks客户端与服务器连接中的第一个数据携带包，然后通过单独的连接发送数据到服务器。为发送字节已更改的探测，模拟器随机将负载的某些字节更改为不同的值。

**非重放探测。** 为模拟非重放探测，模拟器只发送特定数量的随机字节。这是因为对于GFW非重放探测与随机探测，服务区反应并无不同。为确保全面性，模拟器发送随机探测的长度为1到99字节以及221字节。

**服务器的选择。** 我们选用了一组Shadowsocks实施，涵盖大多数Shadowsocks规避生态系统。确切地说，我们测试了满足以下任一条件的Shadowsocks实施：1)可在主要Linux发行版的存储库中获取；2)可在pip存储库中获取；3)是最新版本；4)在任何流行的一键安装脚本中广泛使用；5)基于这些攻击的初步报告，最近对任何可辨识反应进行了修复；或者6)由开发人员向我们推荐。按照这个筛选流程，我们选择了Shadowsocks-libev（v3.0.8、v3.1.3、v3.2.5、v3.3.1和v3.3.3）以及OutlineVPN（v1.0.6、v1.0.7和v1.0.8）。

### 5.2 随机探测背后的意图

### 5.2.1 服务器对于随机探测的反应

[图10](#fig:10-reactions-to-random-probes "Figure 10") 概述了不同Shadowsocks实施对不同长度的随机探测的反应。对于每一实施，我们对其可用加密方法进行划分首先是流加密与AEAD加密，其次是初始化向量(IV)或加密盐的尺寸。例如，Shadowsocks-libev支持的流加密包括“aes-128-ctr”和“aes-256-cfb”。二者的初始化向量都是16字节，因此将其划分到“16字节”行。有关在Shadowsocks协议上下文中，初始化向量和加密盐的含义，请参阅 [第2节](#sec:2-background "2. Background on Shadowsocks") 。

![[20260527-211856_Shadowsocks是如何被检测和封锁的_2_80b44e5b6396.png]]

**[(a) 流加密](#fig:10a-stream-ciphers)**

![[20260527-211856_Shadowsocks是如何被检测和封锁的_2_4529841254a6.png]]

**[(b) AEAD加密](#fig:10b-AEAD-ciphers)**

[**图10：**](#fig:10-reactions-to-random-probes) **Shadowsocks服务器对不同长度人工随机探测的反应。([a](#fig:10a-stream-ciphers "(a) ‣ Figure 10"))是使用流加密结构的服务器，([b](#fig:10b-AEAD-ciphers "(b)"))是AEAD加密结构。已观察到的 GFW 发送的探测负载长度标记为红色。 “TIMEOUT”指服务器等待，直至探测器或服务器自身超时。 “RST”指服务器立即发送 TCP RST。 “FIN/ACK”指服务器率先发送 FIN/ACK 以关闭连接。**

[图10](#fig:10-reactions-to-random-probes "Figure 10") 中的服务器反应由“TIMEOUT”、“RST”和“FIN/ACK”代码表示。TIMEOUT是指服务器等待接收更多数据，直至服务器本身或探测器超时。GFW通常在不到10秒内超时，许多Shadowsocks实施的默认超时值为60秒。因此，TIMEOUT通常表示探测器而非服务器，首先发送FIN/ACK以关闭连接。FIN/ACK和RST表示服务器立即发送FIN/ACK或RST。选择FIN/ACK或RST，取决于操作系统层的套接字处理。Frolov等人指出 \[[^19], §IV.C\]在Linux上关闭套接字时，如果应用程序已从其内核套接字缓冲区读取所有数据，将发送FIN/ACK；否则发送RST。

[图10](#fig:10-reactions-to-random-probes "Figure 10") 显示，使用不同加密方式的不同实施对长度各异的探测做出了可识别指纹的反应。接下来将论述GFW如何在每一种Shadowsocks实施中利用这些反应。

**使用流加密的Shadowsocks-libev v3.0.8--v3.2.5。** 以图10([a](#fig:10a-stream-ciphers "(a)"))中的第一行为例，根据随机探测的长度，Shadowsocks-libev v3.0.8--v3.2.5服务器（具有8字节的初始化向量）展现了三种反应。当探测长度为1-8字节时，服务器总是超时。这是因为服务器只收到（部分）初始化向量并且仍在等待接收目标规范。

当探测长度为9-14字节时，服务器通常会立即发送RST，因为服务器未收到完整的目标规范。随机探测可解密为有意义规范最短长度是15字节，该长度满足完整IPv4规范的最低要求（请参阅 [第2节](#sec:2-background "2. Background on Shadowsocks") ）。仅当1字节主机名长度字段恰好解密为值1或2时，主机名规范可能略短于15字节。

当探测长度不低于15字节时，服务器可能出现以下三种反应之一：RST、TIMEOUT或FIN/ACK。反应取决于随机负载是否解密为有意义的目标规范。有意义的目标规范首先要求地址类型必须是值0x01、0x03或0x04； 任何其他值将导致立即发送RST。因为地址类型是1字节字段，我们可能预期在 1−3256 $1−3256$ $1-\frac{3}{256}$ 。实际看到的比率更接近于 1−316 $1−316$ $1-\frac{3}{16}$ 。这是因为Shadowsocks-libev屏蔽了该字段的前4字节（请参阅 [第2.1节](#sec:2.1-historical-vulnerabilities "2.1. Historical Vulnerabilities and Defenses") ）。探测越长，RST反应的概率越低，因为较长的探测更可能包含完整的IPv6地址规范或与包长一致的主机名长度。

一旦收到完整的目标规范，Shadowsocks服务器将尝试连接到指定目标。确切地说，当地址类型字段解密为0x04时，服务器将尝试解析主机名；当地址类型字段值为0x01或0x03时，服务器将向目标IP地址和端口发送SYN数据包。该行为连接到本质随机的IP地址或主机名，因此连接几乎总是失败；当出现这种情况时，服务器向客户端发送FIN/ACK以关闭连接。如果该远程连接没有立即失败（例如，如果远程主机不响应，Shadowsocks服务器花时间重新传输SYN数据包），那么GFW的探测器会率先发送FIN/ACK以关闭连接。

**使用AEAD加密的Shadowsocks-libev v3.0.8--v3.2.5。** 使用AEAD加密，服务器有一组不同的可指纹识别反应。图10([b](#fig:10b-AEAD-ciphers "(b)"))中的第一行表示具有16字节加密盐的AEAD加密。当探测长度不超过50字节时，服务器等待更多数据时超时。服务器期望的数据至少足以用于加密盐（16字节）、加密长度前缀（2字节）、加密长度标记（16字节）以及另一个标记（16字节，用于首个加密数据负载）。一旦收到不低于51字节的数据，服务器将尝试解密收到的数据，但总是会因身份验证错误而失败。服务器因身份验证错误将立即发出RST。

**Shadowsocks-libev v3.3.1--v3.3.3的变化。** Shadowsocks-libev v3.3.1--v3.3.3的解析逻辑与上述Shadowsocks-libev v3.0.8--v3.2.5非常相似。如图10([b](#fig:10b-AEAD-ciphers "(b)"))所示，唯一的区别是服务器总是超时，而不是服务器有时立即发送RST的情况 \[[^31]\]。

**OutlineVPN v1.0.6。** OutlineVPN仅使用Shadowsocks的AEAD加密结构，且仅使用“chacha20-ietf-poly1305”方法，它包含32字节加密盐。在OutlineVPN v1.0.6中，如果探测长度少于50字节，服务器将超时。服务器需要50字节来解析以下结构：

> ```
> [32 字节加密盐][2 字节已加密长度][16 字节长度标记]
> ```

不同于Shadowsocks-libev，OutlineVPN服务器不会额外等待足够的数据来产生第二个标记。更独特的是，当OutlineVPN接收到正好50字节的探测时，服务器会立即发送FIN/ACK。当探测长度超过50字节时，服务器因身份验证失败而立即发送RST。

**OutlineVPN v1.0.7–v1.0.8。** 从OutlineVPN v1.0.7开始，开发人员修复了服务器的可识别反应 \[[^19], [^47]\]。与使用AEAD加密的较新版Shadowsocks-libev一样，无论探测长度如何，服务器总是超时。

### 5.2.2 攻击者如何使用来自随机探测的信息

本节使用通用术语“攻击者”而不是“GFW”。原因有二：首先，攻击的执行不仅可能来自GFW，而且可能来自任何具备观察Shadowsocks流量能力的审查员。其次，由于GFW的黑盒特性，我们只能猜测其内在逻辑且无法证实我们的猜想。

通过对随机探测反应进行统计分析，攻击者可高可信度地识别Shadowsocks服务器。确切地说，攻击者可以向服务器发送一组不同长度的探测并记录其反应。在收集足够的反应数据后，攻击者可进行统计分析。如果服务器反应符合 [图10](#fig:10-reactions-to-random-probes "Figure 10") 的一行，它很可能就是Shadowsocks服务器。GFW只需一次探测即可检测并封锁Tor服务器 \[[^55]\]，而需一组多次探测方可封锁Shadowsocks服务器，这一事实意味着，GFW进行此类统计分析来检测Shadowsocks。

攻击者甚至能够推断在较早的Shadowsocks实施中初始化向量的长度。而且，当初始化向量长度被推断为12字节时，攻击者即可获知所用加密为“chacha20-ietf”，因为这是12字节初始化向量的加密唯一支持的方式 \[[^45], §Stream Cipher\]。

通过类似的推理，攻击者也许能够推断正在使用何种Shadowsocks实施及其大致版本。例如，根据身份验证错误导致导致立即发送RST或TIMEOUT，可推断服务器正在运行较旧或较新的Shadowsocks实施 \[[^19]\]。RST概率接近或 决定Shadowsocks实施是否对地址类型字段应用掩码。

在实际研究中，我们观察到GFW向同一服务器发送一组NR1型和NR2型探测。而且GFW每小时发送一些探测，而不是一次性发送所有探测。我们推测，GFW这样做是为了使探测不那么引人注目，同时增加通过指纹识别探测的难度。这样的设计同时令GFW能够更为平衡与高效地利用资源。

[图10](#fig:10-reactions-to-random-probes "Figure 10") 中红色标记的GFW探测长度，与某些Shadowsocks实施中反应变化所处的阈值一致。例如，使用8字节初始化向量加密的服务器，将对8字节探测超时，并立即RST9字节探测。通过发送长度为7、8和9字节的探测，GFW覆盖了该转换点。不过，值得注意的是，32-34和40-41字节的NR1型探测，以及221字节的NR2型探测，与任何服务器阈值均不一致。但是，这些信息可能仍然有助于识别Shadowsocks服务器。根据实施，这些探测可用于计算服务器发送RST的实验概率。如果这个概率接近于 or ，攻击者可能推断Shadowsocks服务器使用流加密。

### 5.3 重放探测背后的意图

**重放探测的服务器反应。** [表5](#tbl:5-servers-reactions "Table 5") 概述了重放探测的各种服务器反应。此表仅涵盖重放长度足以包含完整目标规范的情况。因为在没有外部流量调整的情况下，重放所依据的真实负载其长度足以包含该信息。

<table><tbody><tr><td><p>实施</p></td><td><p>加密模式</p></td><td><p>相同重放</p></td><td><p>字节更改重放</p></td></tr><tr><td rowspan="2"><p>Shadowsocks-libev v3.0.8–v3.2.5</p></td><td><p>流</p></td><td><p>R</p></td><td><p>R/T/F</p></td></tr><tr><td><p>AEAD</p></td><td><p>R</p></td><td><p>R</p></td></tr><tr><td rowspan="2"><p>Shadowsocks-libev v3.3.1, v3.3.3</p></td><td><p>流</p></td><td><p>T</p></td><td><p>T/F</p></td></tr><tr><td><p>AEAD</p></td><td><p>T</p></td><td><p>T</p></td></tr><tr><td><p>OutlineVPN</p></td><td><p>AEAD</p></td><td><p>D</p></td><td><p>T</p></td></tr></tbody></table>

[**表5：**](#tbl:5-servers-reactions) **服务器对相同重放（R1 型）的反应，与对字节更改的重放（R2--R5 型）的反应不同，具体取决于重放检测和流/AEAD加密。R：重置、T：超时、F：FIN/ACK、D：正在发送数据。此处我们假设，所有重放长度足以包含完整的初始化向量和目标规范。**

**不含重放防御机制的实施。** 服务器对R1型相同重放的反应，取决于它是否含有重放防御机制。不含重放防御机制的服务器，例如OutlineVPN v1.0.6--v1.0.8，通过一个或多个数据包的数据流响应相同重放。一旦接收到数据，探测器回复ACK并发送FIN/ACK以关闭连接。

通过检查给定重放负载的服务器响应时长是否始终相同，攻击者甚至可以猜测到代理的是什么协议。虽然Shadowsocks服务器的响应是加密的，但一致的响应时长可能表明，例如，底层消息是HTTP响应或TLS ServerHello。

一个关键的观察结果是，在R2型、R3型和R5型探测中发生变化的字节偏移量包含初始化向量或加密盐。这表示，Shadowsocks服务器对这些探测的反应与 [第5.2节](#sec:5.2-intention-behind-random-probes "5.2. Intention Behind Random Probes") 中所述的随机探测没有不同。R4型探测可能是挑选的密文攻击，目标是具有16字节初始化向量的流加密Shadowsocks服务器。与R2型、R3型和R5型探测对比，这三者本质上也是挑选的密码攻击，但R4型探测更加精细化，因为通过列举全部255个更改的字节值，审查员可获取每个反应的确切概率。

**具有重放防御机制的实施。** 即使具有重放防御机制，Shadowsocks实施的行为可能也是可辨识的。例如，Shadowsocks-libev通过Bloom过滤器来记住已接收何种初始化向量和加密盐，由此实施重放探测防御机制 \[[^39]\]。

表5中所示，使用AEAD加密时，服务器对相同重放与字节更改重放的反应一致。然而，使用流加密时，服务器对相同重放与字节更改重放的反应不一致。对于相同重放，Shadowsocks-libev v3.0.8--v3.2.5保证立即发送RST；而接收字节更改重放的同一服务器，将作出以下三种不同反应之一：RST、TIMEOUT或FIN/ACK。

此外，使用流加密时，攻击者可以检测是否存在重放过滤器。例如，攻击者可以向服务器发送两次相同的随机探测。如果第一次探测碰巧导致传出连接至某个远程服务器，而第二次探测被重放过滤器拦截，那么通过这种响应时间的差异，攻击者可以判断是否部署了重放过滤器。虽然无法确认这就是GFW使用的确切逻辑，但我们确实观察到，大约10%的NR2型探测被多次发送到同一台服务器。

## 6 GFW的封锁模块

自2019年7月以来，我们在中国、美国、英国、荷兰和新加坡的63个观测点展开实验。每个地点被用作服务器或客户端。我们使用了不同的Shadowsocks实施 \[[^24], [^43], [^44], [^46]\]和设置。有趣的是，尽管我们的许多VPS都遭受了密集的主动探测，但只有三个被封锁。本节将对GFW封锁与取消封锁机制的本质进行分析与推测。

**按端口还是按IP地址封锁？** 三台服务器不是以同样的方式被封锁。有的封锁是通过丢弃特定服务器端口的所有流量（按端口封锁），有的是通过丢弃所有端口的流量（按IP地址封锁）。在两种情况下，只有服务器到客户端的流量被封锁。这种单向丢包或空路由的方法，与以前的研究中GFW封锁Tor服务器的方式类似 \[[^55]\]。

从审查员的角度来看，封锁整个IP地址可能是合理的。运行Shadowsocks的服务器通常专门用于“翻墙”，并且不托管审查员想要保持访问的其他服务，所以完全封锁服务器对审查员影响甚微。

**何时封锁？** GFW已知每12小时探测一次被封的Tor服务器，并且，如果看起来Tor不再运行，则解除封锁 \[[^55]\]。相比之下，我们在实验中没有观察到定时检查， 以判断被封服务器是否仍在运行Shadowsocks。我们被封的一台服务器在超过一周后才解封。在被封后，该服务器仍然继续运行Shadowsocks，并且在GFW将其解封之前，我们没有观察到对该服务器的探测。原因可能在于，如 [第5.2节](#sec:5.2-intention-behind-random-probes "5.2. Intention Behind Random Probes") 中所述，相对于Tor，辨识Shadowsocks需要进行更多探测，导致封锁后的检查成本更高。

**我们的服务器为何很少被封？** 主动探测很明显是存在的，但是我们仍然不清楚主动探测与Shadowsocks服务器封锁之间的关系。几个收到探测的服务器被封锁。其中一台被封服务器只运行了大约15分钟，并且收到的探测远没有未被封服务器那么多。

我们提出了两种假设，试图阐释这种现象。其一是Shadowsocks封锁由人为因素控制。即，GFW可能维护着一份已检测或疑似Shadowsocks服务器的列表，并且是否封锁列表上的服务器由人来决定。这种假设可部分解释，为什么在政治敏感期报告的封锁事件更多一些 \[[^17], [^21]\]。

另一假设是，对大多数实验中使用的特定Shadowsocks实施和版本，主动探测是无效的。事实上，所有被封的三台服务器均运行ShadowsocksR \[[^46]\]或Shadowsocks-python \[[^43]\]，这与大多数实验中使用的Shadowsocks-libev \[[^44]\]和OutlineVPN \[[^24]\]实施不同。但是，大量用户报告表明，Shadowsocks-libev和OutlineVPN通常对于封锁并无免疫力。

## 7 规避

Shadowsocks检测出现在两个阶段：1)被动识别可疑的Shadowsocks连接，然后 2)主动探测服务器。因此，为防止被封锁，用户可以 1)避开被动探测器，或者 2)以不会导致被封的方式响应主动探测。下面将介绍并讨论这两种规避策略。 我们已与Shadowsocks-libev和OutlineVPN开发人员分享我们的发现与防御提议，这已推动这些工具的改善（请参阅 [负责任的披露](#sec:disclosure "Responsible Disclosure ‣ How China Detects and Blocks Shadowsocks") ）。

### 7.1 对流量分析的防御

**更改客户端到服务器流中的负载长度，是有效的。** 在 [第4.2节](#sec:4.2-experiment-result-and-analysis "4.2. Experiment Results and Analysis") 中，我们看到，为了识别Shadowsocks流量，GFW考虑了连接中第一个数据包的长度。这个发现表明，可以通过改变数据包长度来缓解GFW的流量分析攻击。

Brdgrd \[[^53]\](bridge guard)是一款可以在Shadowsocks服务器上运行的软件， 它可令客户端将其Shadowsocks握手拆分成几个较小的数据包。Brdgrd最初是为了迫使GFW进行复杂的TCP重组，破坏它对Tor网桥的检测 \[[^55]\]， 但此处利用它的这一能力，来调整客户端数据包的大小。

作为测试，我们搭建了Shadowsocks服务器，并设置客户端每5分钟进行16次服务器连接。随机启用和禁用brdgrd，并测量两种情况的主动探测比率。 [表1](#tbl:1-experiment-timeline "Table 1") 概述了实验的时间跨度。

[图11](#fig:11-effectiveness-of-brdgrd "Figure 11") 显示了Shadowsocks服务器随时间变化接收的探测数。该图显示，启用brdgrd几小时之内，探测将减少至零。一旦再次禁用brdgrd，主动探测立即恢复。第二次启用brdgrd后，探测完全停止约40小时，但随后又出现一些探测。 请注意，接收到一些主动探测并不一定意味着改变数据包大小是无效的，因为停用客户端50小时后，服务器仍收到少量探测。启用brdgrd时探测减少，并非偶然， 因为在未安装brdgrd的对照服务器中没有观察到主动探测数量的显著变化。

![[20260527-211856_Shadowsocks是如何被检测和封锁的_2_75fdca5b3fe8.png]]

图11： 当启用brdgrd时，主动探测的强度降低。

另外，我们搭建了一个从一开始就启用brdgrd的服务器，在启用之前没有Shadowsocks客户端与其连接。尽管两个服务器建立了相同数量的连接，相对于开始之后才启用brdgrd的服务器，该服务器收到的探测甚至更少。

这些观察结果进一步证实，在检测Shadowsocks流量时，GFW的流量分析模块将考虑客户端到服务器流量的TCP段大小。通过破环归类的第一步，修改数据包大小可显著缓解主动探测。

**Brdgrd的局限性。** 虽然brdgrd可以暂时有效减少主动探测，不可将brdgrd视为Shadowsocks封锁问题的永久解决方案，原因如下：

第一，为了降低brdgrd可指纹识别性，TCP窗口大小指定从一个范围内随机选取。 然而，TCP窗口大小不一致这一公告本身，可能就是可识别的特征。在一定时间内保持TCP窗口大小不变，可以缓解此问题。

第二，brdgrd必须宣布TCP窗口大小，与任何真正的TCP实施不同，该值小得异常。

第三，brdgrd可能导致某些Shadowsocks实施连接失败。如 [图10](#fig:10-reactions-to-random-probes "Figure 10") 所示，当第一个数据传输包的长度不足以包含完整的目标规范时，某些Shadowsocks实施将立即RST连接。因brdgrd切割数据包过小而导致触发即时RST连接，这种情况并不少见。

我们的结论是，为了防御流量分析同时保持可用性和效率，流量调整机制需要更为周全。

### 7.2 防御主动探测

即使流量调整机制是完善的，即对手根本无法被动地区分Shadowsocks规避流量与合法流量，对于主动探测的防御也是至关重要的。这是因为，资源充足的对手可以跳过流量分析步骤，对 *所有* 被观察到接收连接的IP-端口对进行探测。本节探讨并总结了针对重放探测和随机探测的防御策略。

**适当的身份验证。** 如 [第5节](#sec:5-intention-behind-probes "5. Intention Behind the Probes") 中所述，Shadowsocks流加密因缺乏身份验证而遭受利用密文延展性的探测攻击。Shadowsocks \[[^8], [^15], [^16], [^35], [^36]\]以及其他诸如V2Ray \[[^2], [^34]\]的规避工具，存在许多漏洞的原因正是这一设计缺陷。因此，我们建议用户仅使用AEAD加密，并鼓励规避工具开发人员完全弃用没有身份验证的加密结构。

**同时基于随机数(nonce)和计时的重放过滤。** 我们在 [第3.5节](#sec:3.5-delay-of-replay-attacks "3.5. Delay of Replay Attacks") 中指出，一个现实的主动探测对手模型应该允许审查员在经过任意时间的延迟后执行重放攻击。这样的模型揭示了纯粹基于随机数的重放防御机制存在着攻防不对称。记录 *一些* 合法负载并在相当长的延迟后对其重放，从资源角度来讲，GFW的成本并不高，但是，永远记住 *所有* 经过身份验证的连接的随机数，或者直至更改主密码，对于Shadowsocks服务器，则是成本高昂且比较复杂。即使重启之后，Shadowsocks服务器也必须记住这些随机数；否则，对于跨越重启的重放负载，重放过滤器将无效。幸运的是，通过添加基于计时的防御机制，可以扭转这种不公平的博弈：服务器仅响应经过身份验证的连接，并且它不是重放，其时间戳在过期时间范围内，类似于VMess服务器的处理方式 \[[^2]\]。如此，服务器只需在有限时间内而不是永远记住随机数。

**服务器反应保持一致。** 如 [第5节](#sec:5-intention-behind-probes "5. Intention Behind the Probes") 中所述，在正常运行以及发生错误时规避协议都应作出一致的反应。审查员可能蓄意触发协议临界情况，尝试对服务器进行指纹识别。使用类似于Shadowsocks-libev和OutlineVPN所发现的不一致，Frolov等人 \[[^19]\]论证了在服务器关闭连接后，使用TCP标志和计时元数据可以识别各种代理服务器，包括Shadowsocks-python和OutlineVPN。他们建议，在发生错误时，代理服务器应该一直读取，而不是终止连接。这样做不仅可以避免泄露特定的超时值，而且可以让服务器关闭连接，并使用与非错误情况一致的TCP标志。

## 8 相关研究

关于Shadowsocks流量分析的研究已有不少 \[[^4], [^12], [^27], [^56]\]。有些研究预设的对手，比我们现实观测到更强大。例如，曾雪梅等人提出假设：攻击者在构建检测模型时考虑了主机的DNS行为 \[[^56]\]。许多检测Shadowsocks流量的概念证明工具已被开发出来。Zhixin Wang提出了一种基于前几个高熵数据包的攻击 \[[^22]\]。Madeye使用了数据包长度的分布来识别Shadowsocks和ShadowsocksR流量 \[[^30]\]。此外，王亮等人论证了基于熵的流量分析可以准确识别一些“翻墙”协议，例如obfs3、obfs4和FTE \[[^50]\]。

许多研究和报告实证性地表明，GFW部署了主动探测技术用于发现审查规避工具。已知的目标协议包括Tor \[[^13], [^51], [^55]\]、obfs2 \[[^54]\]、VPN Gate \[[^33]\]以及其他VPN服务\[[^23]\]。Winter等人 \[[^55]\]早在2012年就研究了GFW如何通过主动探测发现Tor中继。Dunna等人 \[[^13]\]在2018年重新审视了针对Tor的主动探测。Ensafi等人 \[[^14]\]通过指纹识别GFW针对不同协议的探测，并推断探测机器的底层基础设施。V2Ray的开发人员报告称，V2Ray服务器早在2017年就开始遭受重放攻击 \[[^38]\]。据我们所知，针对Shadowsocks使用主动探测的最早记录是在2019年6月 \[[^5]\]。

研究人员提出了许多理论上的主动探测攻击类型和防御措施 \[[^2], [^8], [^10], [^15], [^32], [^34]\]。最值得注意的是，Frolov等人 \[[^19]\]通过服务器关闭连接后所用的TCP标志和计时信息，识别各种代理服务器。Frolov和Wustrow \[[^20]\]为主动探测防御指出一个有前景的方向，即将代理隐藏在热门应用程序后面。这个概念称为 *应用程序前置* ，已被许多热门的规避工具采用 \[[^26], [^42], [^48], [^49]\]。

## 9 未来研究

在本次研究中，我们着重介绍了GFW专门针对Shadowsocks的主动探测。然而，来自实验观测的若干证据表明，GFW针对其他未知规避协议也进行主动探测。首先，如 [第4.1节](#sec:4.1-experiments "Section 4.1") 中所述，我们能够使用随机数据触发主动探测。其他规避协议，如VMess，也对流量进行完全加密，因此也可能被检测。其次，如 [第4.2节](#sec:4.2-experiment-result-and-analysis "Section 4.2") 中所述，我们发现Shadowsocks和OutlineVPN服务器未收到的新型探测。如果这些探测不是针对Shadowsocks， 探测对象是什么？第三，2020年6月，VMess被发现对于主动探测的漏洞 \[[^2], [^32], [^34]\]。我们想要测试GFW是否真的利用了这个漏洞。

## 10 伦理

审查测量研究存在一定的风险，从敏感的记录，到法律上负面影响。在进行测量实验时，我们采取了措施将风险降至最低。首先，本次研究不涉及人类主体。所有网络流量均由我们控制的程序自动生成。其次，尽管审查员观察到敏感查询属于低风险，但我们仍尽力限制敏感查询的数量。确切地说，四个实验仅在一个实验中使用中国境内主机作为Shadowsocks服务器。在该实验中，最初服务器代理浏览Alexa排名前100万网站子集的流量。实验运行45小时之后，我们决定从浏览列表中删除被封网站，以便中国境内的主机不会连接到防火墙外的敏感网站。第三，我们的规避服务器使用专用IP地址，将封锁的潜在附带伤害降至最低。我们从VPS提供商租用的非审查网络主机，允许使用Shadowsocks和OutlineVPN，而且事实上甚至提供OutlineVPN自动安装。

## 11 结语

在该研究中，我们系统地研究并揭示了GFW针对Shadowsocks的最新武器。 我们发现，通过每个连接中第一个数据传输包的大小和熵，GFW来检测可能的Shadowsocks流量；然后，在不同的阶段，向可疑服务器发送主动探测。主动探测包括基于重放的探测，以及长度不同的随机探测。它们本质上是不同类型的攻击，针对不同Shadowsocks实施中的漏洞。我们对探测器进行了指纹读取，并且发现与以前主动探测实验的不同。网络层边信道显示，数千个IP地址发送的探测很可能由一组集中式结构控制。

最后，基于我们已获取的认知，提出了一种临时解决方法，用于缓解GFW的流量分析攻击。我们进一步探讨了防御主动探测的基本策略。我们与开发人员密切协作，提升Shadowsocks和相关工具的封锁抵御功能。

## 负责任的披露

我们向Shadowsocks-libev和OutlineVPN开发人员分享了我们的发现和建议。2020年2月，OutlineVPN发布了1.1.0版本，提供防御客户端数据重放的选项 \[[^25]\]。2020年9月，OutlineVPN进一步提供防御服务器数据重放的选项。2020年7月，OutlineVPN开发人员将头部和初始数据合并到一个数据包，以每个连接第一个数据包大小可变 \[[^18]\]。2020年9月初，OutlineVPN开发人员报告称，自从作出这些更改后，其服务器依然受到密集的探测，但是并未被封锁。此外，我们公开分享了初步调查结果 \[[^3]\]，潜在推动Shadowsocks-rustv1.8.5增加重放了防御功能 \[[^57]\]。

## 鸣谢

作者在此向以下人士表示诚挚的感谢：Shadowsocks-libev开发人员；参与Jigsaw项目的Vinicius Fortuna和其他OutlineVPN开发人员；以及科罗拉多大学的Eric Wustrow和其他研究人员。几位作者还要特别感谢Dave Levin为本论文提供指导。本次研究的部分经费来自 [NSF CAREER grant CNS-1553301](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1553301) 。

## 数据提供

为了保持实验再现性促进未来的研究，在不影响匿名性的情况下，我们已最大限度地发布了实验数据和源代码： [https://gfw.report/publications/imc20/en](https://gfw.report/publications/imc20/en) 。

## 参考文献

---

[Atom feed](https://gfw.report/isso/feed?uri=%2Fpublications%2Fimc20%2Fzh%2F)

#### 4 条评论

[^1]: Anonymous. Towards a Comprehensive Picture of the Great Firewall's DNS Censorship. In *Free and Open Communications on the Internet*, USENIX, 2014. [https://www.usenix.org/system/files/conference/foci14/foci14-anonymous.pdf.](https://www.usenix.org/system/files/conference/foci14/foci14-anonymous.pdf)

[^2]: Anonymous. 2020. *Summary on Recently Discovered V2Ray Weaknesses.* Retrieved September 2020 from [https://gfw.report/blog/v2ray\_weaknesses/en/](https://gfw.report/blog/v2ray_weaknesses/en/)

[^3]: Anonymous, Anonymous, Anonymous, David Fifield, and Amir Houmansadr. 2019. *How China Detects and Blocks Shadowsocks.* Retrieved September 2020 from [https://gfw.report/blog/gfw\_shadowsocks](https://gfw.report/blog/gfw_shadowsocks)

[^4]: Matthieu Baerts and Quentin De Coninck. 2015. *Multipath TCP with real Smartphone applications. Master’s thesis.* Université catholique de Louvain. [https://dial.uclouvain.be/memoire/ucl/object/thesis:366](https://dial.uclouvain.be/memoire/ucl/object/thesis:366)

[^5]: bluesky. 2019. *6.4期间翻墙观察.* Retrieved February 2020 from [https://pincong.rocks/article/2019](https://pincong.rocks/article/2019)

[^6]: Kevin Bock, iyouport, Anonymous, Louis-Henri Merino, David Fifield, Amir Houmansadr, and Dave Levin. 2020. *Exposing and Circumventing China’s Censorship of ESNI.* Retrieved September 2020 from [https://github.com/net4people/bbs/issues/43#issuecomment-673322409](https://github.com/net4people/bbs/issues/43#issuecomment-673322409)

[^7]: David Borman, Bob Braden, Van Jacobson, and Richard Scheffenegger. 2014. *TCP Extensions for High Performance.* RFC 7323. RFC Editor. [https://tools.ietf.org/html/rfc7323](https://tools.ietf.org/html/rfc7323)

[^8]: BreakWa11. 2015. *Shadowsocks协议的弱点分析和改进.* Retrieved August 2019 from [https://web.archive.org/web/20160829052958/https://github.com/breakwa11/shadowsocks-rss/issues/38](https://web.archive.org/web/20160829052958/https://github.com/breakwa11/shadowsocks-rss/issues/38)

[^9]: Zimo Chai, Amirhossein Ghafari, and Amir Houmansadr. 2019. On the Importance of Encrypted-SNI (ESNI) to Censorship Circumvention. In *Free and Open Communications on the Internet.* USENIX. [https://www.usenix.org/system/files/foci19-paper\_chai\_update.pdf](https://www.usenix.org/system/files/foci19-paper_chai_update.pdf)

[^10]: Jiaxing Cheng, Ying Li, Cheng Huang, Ailing Yu, and Tao Zhang. 2020. ACER: detecting Shadowsocks server based on active probe technology. *Journal of Computer Virology and Hacking Techniques 16,* 3 (2020), 217–227. [https://link.springer.com/article/10.1007/s11416-020-00353-z](https://link.springer.com/article/10.1007/s11416-020-00353-z)

[^11]: Richard Clayton, Steven J. Murdoch, and Robert N. M. Watson. 2006. Ignoring the Great Firewall of China. In *Privacy Enhancing Technologies.* Springer, 20–35. [https://www.cl.cam.ac.uk/~rnc1/ignoring.pdf](https://www.cl.cam.ac.uk/~rnc1/ignoring.pdf)

[^12]: Ziye Deng, Zihan Liu, Zhouguo Chen, and Yubin Guo. 2017. The Random Forest based Detection of Shadowsock’s Traffic. In Intelligent Human-Machine Systems and Cybernetics. *IEEE.* [https://www.directory-root.com/wp-content/uploads/2018/02/Shadowsocks-Sniffing.pdf](https://www.directory-root.com/wp-content/uploads/2018/02/Shadowsocks-Sniffing.pdf)

[^13]: Arun Dunna, Ciarán O’Brien, and Phillipa Gill. 2018. Analyzing China’s Blocking of Unpublished Tor Bridges. In *Free and Open Communications on the Internet.* USENIX. [https://www.usenix.org/system/files/conference/foci18/foci18-paperdunna.pdf](https://www.usenix.org/system/files/conference/foci18/foci18-paperdunna.pdf)

[^14]: Roya Ensafi, David Fifield, Philipp Winter, Nick Feamster, Nicholas Weaver, and Vern Paxson. 2015. Examining How the Great Firewall Discovers Hidden Circumvention Servers. In *Internet Measurement Conference.* ACM. [http://conferences2.sigcomm.org/imc/2015/papers/p445.pdf](http://conferences2.sigcomm.org/imc/2015/papers/p445.pdf)

[^15]: David Fifield. 2017. *Shadowsocks active-probing attacks and defenses.* Retrieved February 2020 from [https://groups.google.com/d/msg/traffic-obf/CWO0peBJLGc/Py-clLSTBwAJ](https://groups.google.com/d/msg/traffic-obf/CWO0peBJLGc/Py-clLSTBwAJ)

[^16]: David Fifield. 2019. *Decryption vulnerability in Shadowsocks stream ciphers.* Retrieved June 2020 from [https://github.com/net4people/bbs/issues/24](https://github.com/net4people/bbs/issues/24)

[^17]: David Fifield. 2019. *Intensive Shadowsocks blocking in China since mid-September.* Retrieved February 2020 from [https://github.com/net4people/bbs/issues/16](https://github.com/net4people/bbs/issues/16)

[^18]: Vinicius Fortuna. 2020. *Outline changes since the prelinimary report.* Retrieved September 2020 from [https://github.com/net4people/bbs/issues/22#issuecomment-670781627](https://github.com/net4people/bbs/issues/22#issuecomment-670781627)

[^19]: Sergey Frolov, Jack Wampler, and Eric Wustrow. 2020. Detecting Probe-resistant Proxies. In *Network and Distributed System Security.* The Internet Society. [https://www.ndss-symposium.org/wp-content/uploads/2020/02/23087.pdf](https://www.ndss-symposium.org/wp-content/uploads/2020/02/23087.pdf)

[^20]: Sergey Frolov and Eric Wustrow. 2020. HTTPT: A Probe-Resistant Proxy. In *Free and Open Communications on the Internet.* USENIX. [https://www.usenix.org/system/files/foci20-paper-frolov.pdf](https://www.usenix.org/system/files/foci20-paper-frolov.pdf)

[^21]: *How did GFW block circumvention tools during the 19th people’s congress?*[https://github.com/net4people/bbs/issues/1](https://github.com/net4people/bbs/issues/1)

[^undefined]: go Shadowsocks2 developers. \[n.d.\]. *go-Shadowsocks2.* [https://github.com/shadowsocks/go-shadowsocks2](https://github.com/shadowsocks/go-shadowsocks2)

[^undefined]: ↩

[^undefined]: ↩

[^undefined]: ↩

[^undefined]: ↩

[^22]: isofew. 2017. *sssniff.* [https://github.com/isofew/sssniff](https://github.com/isofew/sssniff)

[^23]: Andrew Jacobs. 2015. *China further tightens grip on the Internet.* The New York Times (Jan. 2015). Retrieved February 2020 from [https://www.nytimes.com/2015/01/30/world/asia/china-clamps-down-still-harder-on-internet-access.html](https://www.nytimes.com/2015/01/30/world/asia/china-clamps-down-still-harder-on-internet-access.html)

[^24]: Jigsaw. \[n.d.\]. *Outline.* [https://getoutline.org/](https://getoutline.org/)

[^25]: Jigsaw. \[n.d.\]. *Outline v1.1.0.* [https://github.com/Jigsaw-Code/outline-ss-server/releases/tag/v1.1.0](https://github.com/Jigsaw-Code/outline-ss-server/releases/tag/v1.1.0)

[^26]: klzgrad. \[n.d.\]. *NaïveProxy.* [https://github.com/klzgrad/naiveproxy](https://github.com/klzgrad/naiveproxy)

[^27]: Xiaolei Liu, Zhongliu Zhuo, Xiaojiang Du, Xiaosong Zhang, Qingxin Zhu, and Mohsen Guizani. 2019. Adversarial attacks against profile HMM website fingerprinting detection model. *Cognitive Systems Research 54* (2019), 83–89. [https://doi.org/10.1016/j.cogsys.2018.12.005](https://doi.org/10.1016/j.cogsys.2018.12.005)

[^28]: Zhen Lu, Zhenhua Li, Jian Yang, Tianyin Xu, Ennan Zhai, Yao Liu, and Christo Wilson. 2017. Accessing Google Scholar under Extreme Internet Censorship: A Legal Avenue. In *Middleware.* ACM. [https://censorbib.nymity.ch/pdf/Lu2017a.pdf](https://censorbib.nymity.ch/pdf/Lu2017a.pdf)

[^29]: madeye. 2016. *Changes between shadowsocks-libev v2.5.4 and v2.5.5.* [https://github.com/shadowsocks/shadowsocks-libev/compare/v2.5.4...v2.5.5](https://github.com/shadowsocks/shadowsocks-libev/compare/v2.5.4...v2.5.5)

[^30]: madeye. 2017. *sssniff.* [https://github.com/madeye/sssniff](https://github.com/madeye/sssniff)

[^31]: madeye. 2019. *Simplify the server auto blocking mechanism.* Retrieved September 2020 from [https://github.com/shadowsocks/shadowsocks-libev/commit/a99c39c7dd314939082348d96d06727570b514a8](https://github.com/shadowsocks/shadowsocks-libev/commit/a99c39c7dd314939082348d96d06727570b514a8)

[^32]: nametoolong. 2020. *Some extra ways of active probing.* Retrieved September 2020 from [https://github.com/v2ray/v2ray-core/issues/2539](https://github.com/v2ray/v2ray-core/issues/2539)

[^33]: Daiyuu Nobori and Yasushi Shinjo. 2014. VPN Gate: A Volunteer-Organized Public VPN Relay System with Blocking Resistance for Bypassing Government Censorship Firewalls. In *Networked Systems Design and Implementation. USENIX.* [https://www.usenix.org/system/files/conference/nsdi14/nsdi14-papernobori.pdf](https://www.usenix.org/system/files/conference/nsdi14/nsdi14-papernobori.pdf)

[^34]: p4gefau1t, studentmain, et al. 2020. *vmess协议设计和实现缺陷可导致服务器遭到主动探测特征识别(附PoC).* Retrieved September 2020 from [https://github.com/v2ray/v2ray-core/issues/2523](https://github.com/v2ray/v2ray-core/issues/2523)

[^35]: Zhiniang Peng. 2020. *Redirect attack on Shadowsocks stream ciphers.* Retrieved June 2020 from [https://github.com/edwardz246003/shadowsocks](https://github.com/edwardz246003/shadowsocks)

[^36]: printempw. 2017. *为何shadowsocks 要弃用一次性验证(OTA).* Retrieved February 2020 from [https://web.archive.org/web/20191002190325/https://printempw.github.io/why-do-shadowsocks-deprecate-ota/](https://web.archive.org/web/20191002190325/https://printempw.github.io/why-do-shadowsocks-deprecate-ota/)

[^37]: ProgramThink. 2017. *2017年10月翻墙快报(兼谈用I2P突破封锁).* Retrieved February 2019 from [https://program-think.blogspot.com/2017/10/gfw-news.html](https://program-think.blogspot.com/2017/10/gfw-news.html)

[^38]: projectv2ray. 2017. *Replay attack monitored by V2Ray.* Retrieved February 2020 from [https://github.com/shadowsocks/shadowsocks-org/issues/44#issuecomment-282525358](https://github.com/shadowsocks/shadowsocks-org/issues/44#issuecomment-282525358) (originally from [https://twitter.com/projectv2ray/status/833959357423448064](https://twitter.com/projectv2ray/status/833959357423448064)).

[^39]: riobard, madeye, Mygod, et al. 2017. *Defend against replay attack.* Retrieved February 2020 from [https://github.com/shadowsocks/shadowsocks-org/issues/44](https://github.com/shadowsocks/shadowsocks-org/issues/44)

[^40]: Shadowsocks rust developers. \[n.d.\]. *Shadowsocks-rust.* [https://github.com/shadowsocks/shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)

[^41]: Will Scott. 2017. Reports of China disrupting shadowsocks. Retrieved February 2019 from [https://groups.google.com/d/msg/traffic-obf/dqw6CQLR944/1Icd4691AQAJ](https://groups.google.com/d/msg/traffic-obf/dqw6CQLR944/1Icd4691AQAJ)

[^42]: Sergey Frolov and others. \[n.d.\]. *forwardproxy.* [https://github.com/caddyserver/forwardproxy](https://github.com/caddyserver/forwardproxy)

[^43]: Shadowsocks developers. \[n.d.\]. *Shadowsocks.* [https://github.com/shadowsocks/shadowsocks/tree/master](https://github.com/shadowsocks/shadowsocks/tree/master)

[^44]: Shadowsocks developers. \[n.d.\]. *Shadowsocks-libev.* [https://github.com/shadowsocks/shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev)

[^45]: Shadowsocks developers. 2019. *Shadowsocks whitepaper.* [https://github.com/shadowsocks/shadowsocks-org/blob/master/whitepaper/whitepaper.md](https://github.com/shadowsocks/shadowsocks-org/blob/master/whitepaper/whitepaper.md)

[^46]: shadowsocksr-csharp developers. \[n.d.\]. *shadowsocksr-csharp.* [https://github.com/shadowsocksrr/shadowsocksr-csharp](https://github.com/shadowsocksrr/shadowsocksr-csharp)

[^47]: tatianab, alalamav, et al. 2019. *Probing resistance via timeout.* Retrieved September 2020 from [https://github.com/Jigsaw-Code/outline-ss-server/commit/c70d512e78525eba36bb1e6ad7a0868593166cf9](https://github.com/Jigsaw-Code/outline-ss-server/commit/c70d512e78525eba36bb1e6ad7a0868593166cf9)

[^48]: trojan developers. \[n.d.\]. *trojan.* [https://github.com/trojan-gfw/trojan](https://github.com/trojan-gfw/trojan)

[^49]: V2Ray developers. \[n.d.\]. *V2Ray.* [https://github.com/v2fly/v2ray-core](https://github.com/v2fly/v2ray-core)

[^50]: Liang Wang, Kevin P. Dyer, Aditya Akella, Thomas Ristenpart, and Thomas Shrimpton. 2015. Seeing through Network-Protocol Obfuscation. In *Computer and Communications Security*. ACM. [http://pages.cs.wisc.edu/~liangw/pub/ccsfp653wangA.pdf](http://pages.cs.wisc.edu/~liangw/pub/ccsfp653wangA.pdf)

[^51]: Tim Wilde. 2012. *GFW actively probes obfs2 bridges.* Retrieved February 2020 from [https://blog.torproject.org/blog/knock-knock-knockin-bridges-doors](https://blog.torproject.org/blog/knock-knock-knockin-bridges-doors)

[^52]: Brandon Wiley. 2017. *Re: Reports of China disrupting shadowsocks.* Retrieved July 2019 from [https://groups.google.com/d/msg/traffic-obf/dqw6CQLR944/V5\_61SVTBAAJ](https://groups.google.com/d/msg/traffic-obf/dqw6CQLR944/V5_61SVTBAAJ)

[^53]: Philipp Winter. 2010. *brdgrd.* [https://github.com/NullHypothesis/brdgrd](https://github.com/NullHypothesis/brdgrd)

[^54]: Philipp Winter. 2013. *GFW actively probes obfs2 bridges.* Retrieved February 2020 from [https://bugs.torproject.org/8591](https://bugs.torproject.org/8591)

[^55]: Philipp Winter and Stefan Lindskog. How the Great Firewall of China is Blocking Tor. In *Free and Open Communications on the Internet*, USENIX 2012. [https://www.usenix.org/system/files/conference/foci12/foci12-final2.pdf](https://www.usenix.org/system/files/conference/foci12/foci12-final2.pdf)

[^56]: *IEEE Access 7* [https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8676111](https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8676111)

[^undefined]: Yankang Zhao, Xiaobo Ma, Jianfeng Li, Shui Yu, and Wei Li. 2018. Revisiting Website Fingerprinting Attacks in Real-World Scenarios: A Case Study of Shadowsocks. In *International Conference on Network and System Security. Springer*, 319–336.

[^undefined]: Zhongliu Zhuo, Yang Zhang, Zhi li Zhang, Xiaosong Zhang, and Jingzhong Zhang. 2018. Website Fingerprinting Attack on Anonymity Networks Based on Profile Hidden Markov Model. *IEEE Transactions on Information Forensics and Security* 13, 5 (May 2018), 1081–1095. [https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8067534](https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8067534)

[^undefined]: ↩

[^undefined]: ↩

[^57]: zonyitoo. \[n.d.\]. Shadowsocks-rust v1.8.5. [https://github.com/shadowsocks/shadowsocks-rust/releases/tag/v1.8.5](https://github.com/shadowsocks/shadowsocks-rust/releases/tag/v1.8.5)