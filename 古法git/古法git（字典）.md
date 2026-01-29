绑定用户名：git config --global user.name "用户名"

绑定邮箱： gi，t config --global user.email "邮箱"

clone别人的仓库：git clone [项目地址，项目主页点绿色的code键看到的http地址]

建自己的仓库(初始化本地仓库，先不传到托管网站)：git init 

把代码放到暂存区：git add .

提交：git commit -m "信息，不想填的话直接写git commit就行了"
，
查看历史：git log #后面加--stat可以看到修改了什么文件，最重要的时间是commit id

查看某次commit修改了具体内容：git diff [commit id]

回溯代码：git reset [commit id]  
git checkout [commit id]#的任意一个

查看当前项目有什么分支：git branch

创建分支并跳转到develop分支：git checkout -b develop

转到某分支：git checkout [分支名]

合并代码：git merge [要合并的分支]

绑定仓库：git remote add origin [仓库链接] #origin是远程仓库的别名，也可以是其他名字

推送代码到远程仓库：git push [别名] [本地分支]:[远程分支]

拉取远程仓库的内容到本地：git pull [别名] [分支]

校验仓库：  
1. sudo pacman -S openssh #下载ssh工具

2. ssh-keygen -t rsa -C [邮箱]

3. 看到一段ascii图就说明上一步成功了，此时找到public行，进入上面说的文件目录，复制里面的内容

4. 打开github,点击自己的头像，选择settings,找到ssh and gpg keys选项，点击new ssh key,title中输一个名字，并把刚刚复制的字符粘贴到输入框中

5. 回到终端输入ssh -T git@github.com,看到hi就完成了

