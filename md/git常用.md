# git常用

### 配置远程仓库

配置远程仓库

`git remote add origin '(https)'`

拉取远程仓库的全部内容

`git pull`

### 查看本地已有的分支

查看本地已有分支

`git branch`

查看所有分支，包含远程分支

`git branch -a`

查看本地分支与远程分支对应关系

`git branch -vv`

### 配置本地分支对应到远程分支

创建分支并切换分支，同时对应到远程分支

`git checkout -b devbranch origin/devbranch`

如果已有本地分支则可以使用`git checkout devbranch`切换到本地分支，通过 git branch --set-upstream-to 命令设置关联

`git branch --set-upstream-to develop origin/develop`

### 拉取远程分支

`git pull`或者`git fetch origin`可以拉取所有远程分支

使用`git pull origin devbranch`命令可以拉取单远程分支

### 推送到远程分支

1. 获取远程库与本地同步合并（如果远程库不为空必须做这一步，否则后面的提交会失败）

`git pull --rebase origin devbranch`

2. 使用命令`git push origin devbranch`推送分支到远程仓库

----

### git add后撤销

执行完 `git add .` 才发现没有在对应的分支，如何撤回呢？

### 可以参考下面的方法：

文件退出暂存区，但是修改保留：

```javascript
git reset --mixed
```

撤销所有的已经 add 的文件：

```javascript
git reset HEAD .
```

撤销某个文件或文件夹：

```javascript
git reset HEAD  -filename
```

另外：可以用 `git status` Git 会告诉你可以通过那个命令来执行操作。

----

### git删除远程文件夹或文件

1. 预览将要删除的文件
   
   ```undefined
   git rm -r  --cached -n 文件/文件夹名称 
   
   加上 -n 这个参数，执行命令时，是不会删除任何文件，而是展示此命令要删除的文件列表预览。
   ```

2. 确定无误后删除文件
   
   ```undefined
   git rm -r --cached 文件/文件夹名称
   ```

3. 提交到本地并推送到远程服务器
   
   ```bash
   git commit -m "提交说明"
   git push origin master
   ```
