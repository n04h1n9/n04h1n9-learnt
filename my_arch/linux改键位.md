# linux改键位

前言：在linux上，我们会频繁使用到vim编辑器，其设计理念就是让手尽量少的离开键盘主区（26个字母及周围能够到的字符），但是很明显，esc是很常用的按键（因为要用于从输入模式切换成普通模式），但大写锁定键又几乎是一点用处没有，所以把这两个按键调换位置是很常见的需求，此外根据个人需要，还有其他不同的需求，以下是在linux上内核级别的改键位方法，能保证改的键位在哪都能用（用Arch Linux做演示，其他发行版大同小异）

> 在做自己不了解的事情时，记得做一个快照，这里要改根目录，所以做一个根分区的快照,快照相关内容，参见[archlinux基本使用方法](/my_arch/archlinux%E7%9A%84%E5%9F%BA%E6%9C%AC%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95.md)

1. `sudo pacman -S keyd`下载主角keyd

2. 创建并编辑/etc/keyd/default.conf,发挥自己天马行空的想象力（前提是你得需要并能适应你改的键位，且在不想要时记得配置文件在这里并有能力改回去），在配置文件写入这些内容：

```
#使全局生效
[ids]
*

[main]
# 1. Esc 与 Caps 换位
capslock = esc
esc = capslock

# 2. 左 Alt 与 左 Ctrl 换位
leftalt = leftcontrol
leftcontrol = leftalt

# 3. 右 Alt 与 右 Ctrl 换位
rightalt = rightcontrol
rightcontrol = rightalt
```

这是我的需求，如果你的需求跟我不一样，你可以按[我的模板](dotfile/keyd)进行修改

3. 启用守护进程使其立即生效
```
sudo systemctl enable --now keyd
```

配置立即生效，不用登出或重启
