## 快速上手
```bash
#本地生成ssh密钥-C 设置注释文字，比如邮箱
ssh-keygen -t rsa -C "234939468+kcy6@users.noreply.github.com"

git init -b main #-b初始化时直接指定初始分支的名称
git config --local user.name "kcy6"
git config --local user.email "234939468+kcy6@users.noreply.github.com"
git config --global user.name "kcy6"
git config --global user.email "234939468+kcy6@users.noreply.github.com"

git remote add origin git@github.com:beiszhihao/test.git
git push -u origin main
```


## 修改最近一次提交的描述信息
```bash
#修改最近一次的提交信息(可通过git log先查看已由提交信息)
git commit --amend -m "新的提交备注"
本质是通过一个新的提交覆盖原提交可通过git reflog查看
```



## 子模块相关
[git文档](https://git-scm.com/book/zh/v2/Git-%e5%b7%a5%e5%85%b7-%e5%ad%90%e6%a8%a1%e5%9d%97)
```bash
git submodule update --remote -- sources/Shorin-ArchLinux-Guide #更新到子模块原仓库的的最新版本
git submodule update --init --recursive #将当前子仓库恢复到主仓库记录的版本

git clone --recurse-submodules git@github.com:kcy6/ObsidianLLMWiki.git
```


## 分支(branch)
`查看相关`
```bash
git branch #查看当前属于哪个分支,只列本地分支
git status #输出首行会显示分支情况,
git branch -a       # 本地 + 远程分支
git branch -r       # 只列远程分支
git branch -v #查看所有分支 + 每个分支最新提交 + 当前所在
git branch -vv #查看所有分支 + 每个分支最新提交 + 当前所在(带上游跟踪信息)  
```
`切换相关`
```bash
git checkout master #切换到分支master
git checkout -b dev #创建分支并切换过去
```
`更改分支名`
```bash
git branch -m 分支名 新的分支名
```


## 查看当前配置config
```bash
git config --list #查看所有生效的配置（合并系统、全局、本地后最终生效的值）
git config --global --list #查看全局配置（当前用户的所有仓库通用）
git config --local --list #查看当前仓库配置（只对当前项目生效）
git config --system --list #查看系统配置（对电脑所有用户生效）
```
**查看配置来源**：在命令后加上 `--show-origin`，可以显示每个配置项来自于哪一个配置文件路径
```
git config --list --show-origin
```



## 回滚代码仓库
git reset --hard只恢复 Git 已经跟踪的文件不会删除未跟踪文件。
如果想把未跟踪文件也删除，可以使用：`git clean -n`查看将要删除的未跟踪的文件`git clean -f`确认删除
git reset --hard    → 处理已跟踪文件
git clean -f        → 删除未跟踪文件
如果你的目标是让整个工作目录尽可能恢复成某个 commit 的样子，常见组合是：
```bash
git reset --hard <commit>
git clean -fd #-d 表示连未跟踪目录也删除
```
`--soft` 、`--mixed`以及`--hard`是三个恢复等级。
- 使用`--soft`就仅仅将头指针恢复，已经add的暂存区以及工作空间的所有东西都不变。
- 如果使用`--mixed`，就将头恢复掉，已经add的暂存区也会丢失掉，工作空间的代码什么的是不变的。
- 如果使用`--hard`，那么一切就全都恢复了，头变，aad的暂存区消失，代码什么的也恢复到以前状态。
```bash
git log #先使用git log查看历史版本
git reset --hard 要回滚id #在使用git reset --hard命令回滚
#git reset默认参数是--mixed
```




## 解决GitBash将中文显示为八进制数的问题
==Git 默认会把文件名中的非 ASCII 字符转义成八进制形式==
```bash
#Git 默认core.quotepath=true对于中文、日文等非 ASCII 文件名，会进行转义,将其修改为false即可,就是告诉git非 ASCII 文件名直接原样显示，不要转义
git config --global core.quotepath false
```


