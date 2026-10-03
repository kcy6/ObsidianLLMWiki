---
type: sources
status: draft
updated: 2026-10-03
sources: []
---

# 来源台账

“已处理范围”仅表示本次实际阅读并写入的章节，不代表原文件已完整消化。子模块属于独立仓库，页面引用时用主仓库内的相对路径。

| 来源 | 类型 | 已处理范围 | 关联 Wiki |
| --- | --- | --- | --- |
| [[sources/Shorin-ArchLinux-Guide/README|Shorin 教程总入口]] | Git 子模块，提交 `d8772456749981c0de3417a84c2783578603cfc6`，工作区有未提交改动 | 目录与 Arch Linux 章节索引 | [[wiki/topics/Arch Linux 与桌面环境]] |
| [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装ArchLinux|Shorin：安装 Arch Linux]] | 子模块教程 | 概念、方案简述、手动安装步骤标题 | [[wiki/guides/Arch Linux 安装资料阅读路线]] |
| [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装桌面环境前的准备|Shorin：桌面前准备]] | 子模块教程 | 目录、用户与软件源章节 | [[wiki/guides/Arch Linux 安装资料阅读路线]] |
| [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/快照和系统维护|Shorin：快照和系统维护]] | 子模块教程 | 目录与 Snapper 起始部分 | [[wiki/topics/Arch Linux 与桌面环境]] |
| [[sources/Shorin-ArchLinux-Guide/wiki/archlinux/安装Niri|Shorin：安装 Niri]] | 子模块教程 | 目录、Niri 介绍、安装入口 | [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]] |
| [[notes/ArchLinux|自己的 Arch Linux 笔记]] | 可修改笔记 | 安装与桌面章节结构，部分步骤 | [[wiki/guides/Arch Linux 安装资料阅读路线]] |
| [[Fedora桌面配置相关/Fedora Minimal+Niri+DMS|Fedora Minimal + Niri + DMS]] | 可修改笔记 | 输入法、DMS 与 Niri 配置相关章节 | [[wiki/questions/Arch 与 Fedora 的 Niri 配置如何复用]] |
| [[角度传感器-姿态解算MPU6050/MPU6050汇总|MPU6050 汇总]] | 可修改笔记 | 全文 | [[wiki/topics/姿态解算与 MPU6050]] |
| [[notes/姿态解算|姿态解算]] | 可修改笔记 | 全文；其中“9 轴”说法待查 | [[wiki/concepts/MPU6050 的姿态数据从哪里来]] |
| [[角度传感器-姿态解算MPU6050/MPU6050姿态解算方式1-DMP|MPU6050 DMP 剪藏]] | 网页剪藏 | 基础、DMP、四元数转欧拉角章节 | [[wiki/concepts/MPU6050 的姿态数据从哪里来]] |
| [[角度传感器-姿态解算MPU6050/MPU6050姿态解算2-欧拉角&旋转矩阵|MPU6050 软件解算剪藏]] | 网页剪藏 | IMU、旋转约定、加速度计章节 | [[wiki/concepts/MPU6050 的姿态数据从哪里来]] |
| [[notes/移植DMP库|移植 DMP 库]] | 可修改笔记 | 标题结构；代码尚未逐段核验 | [[wiki/topics/姿态解算与 MPU6050]] |

## 待处理

- Shorin 子模块中其余 Arch Linux 章节，以及已列文件的未处理正文；更新子模块后要复查相关页面。
- `Clippings/` 的 Kalman 滤波剪藏、MPU6050 其他教程和附件图示。
- `notes/` 中嵌入式、Linux、网络和电赛等主题资料。
