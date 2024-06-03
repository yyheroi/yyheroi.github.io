---
title: systemctl-详解
categories:
  - test
tags:
  - test
date: 2024-06-03 14:10:50
---

## 一、Systemd简介

Systemd是由红帽公司的一名叫做Lennart Poettering的员工开发，systemd是Linux系统中最新的初始化系统（init）,它主要的设计目的是克服Sys V 固有的缺点，提高系统的启动速度，systemd和upstart是竞争对手，ubantu上使用的是upstart的启动方式，centos7上使用systemd替换了Sys V，Systemd目录是要取代Unix时代依赖一直在使用的init系统，兼容SysV和LSB的启动脚本，而且能够在进程启动中更有效地引导加载服务。
system：系统启动和服务器守护进程管理器，负责在系统启动或运行时，激活系统资源，服务器进程和其他进程，根据管理，字母d是守护进程（daemon）的缩写，systemd这个名字的含义就是它要守护整个系统。

## 二、Systemd新特性

- 系统引导时实现服务并行启动
- 按需启动守护进程
- 自动化的服务依赖关系管理
- 同时采用socket式与D-Bus总线式激活服务
- 系统状态快照和恢复
- 利用Linux的cgroups监视进程
- 维护挂载点和自动挂载点
- 各服务间基于依赖关系进行精密控制



## 三、Systemd核心概念

- Unit
  表示不同类型的sytemd对象，通过配置文件进行标识和配置，文件中主要包含了系统服务，监听socket、保存的系统快照以及其他与init相关的信息
- 配置文件:
  /usr/lib/systemd/system：每个服务最主要的启动脚本设置，类似于之前的/etc/initd.d
  /run/system/system：系统执行过程中所产生的服务脚本，比上面的目录优先运行
  /etc/system/system：管理员建立的执行脚本，类似于/etc/rc.d/rcN.d/Sxx类的功能，比上面目录优先运行，在三者之中，此目录优先级最高

## 四、Unit类型

- systemctl -t help ：查看unit类型

- service unit：文件扩展名为.service，用于定义系统服务

- target unit：文件扩展名为.target，用于模拟实现“运行级别”

- device unit: .device,用于定义内核识别的设备

- mount unit ：.mount，定义文件系统挂载点

- socket unit ：.socket,用于标识进程间通信用的socket文件，也可以在系统启动时，延迟启动服务，实现按需启动

- snapshot unit：.snapshot，关系系统快照

- swap unit：.swap，用于表示swap设备

- automount unit：.automount，文件系统的自动挂载点如：/misc目录

- path unit：.path，用于定义文件系统中的一个文件或目录使用，常用于当文件系统变化时，延迟激活服务，如spool目录

- time：.timer由systemd管理的计时器

  注：使用systemctl控制单元时，通常需要使用单元文件的全名，包括扩展名，但是有些单元可以在systemctl中使用简写方式，如果无扩展名，systemctl默认把扩展名当做.service。例如netcfg和netcfg.service是等同的挂载点会自动转化为相应的.mount单元，例如/home等价于home.mount设备会自动转化为相应的.device单元，所以/dev/sd2等价于dev-sda2.device



## 五、关键特性

- 基于socket的激活机制：socket与服务进程分离
- 基于D-Bus的激活机制
- 基于device的激活机制
- 基于path的激活机制
- 系统快照：保存各unit的当前状态信息于持久存储设备中想后兼容sysv init脚本



## 六、不兼容

- systemctl命令固定不变，不可扩展
- 非由systemd启动的服务，systemctl无语与之通信和控制，如：使用之前sys v风格管理的进程就无法收systemd控制



## 七、Systemd基本工具

监视和控制systemd的主要命令是systemctl。该命令可用于查看系统状态和管理系统及服务。

- 管理服务

命令：systemctl  command name.service

启动：service name start –>systemctl start name.service

停止：service name stop –>systemctl stop name.service

重启：service name restart–>systemctl restart name.service

状态：service name status–>systemctl status name.service

- 条件式重启(已启动才重启，否则不做任何操作)
  `systemctl try-restart name.service`

- 重载或重启服务(先加载，然后再启动)
  `systemctl reload-or-try-restart name.service`

- 禁止自动和手动启动
  `systemctl mask name.service` 
  执行此条命令实则创建了一个链接 ln -s '/dev/null' '/etc/systemd/system/sshd.service'

- 取消禁止
  `systemctl unmask name.service` 
  删除此前创建的链接

- 服务查看(查看某服务当前激活与否的状态)
  `systemctl is-active name.service` 
  如果启动会显示active，否则会显示unknown

- 查看所有已经激活的服务
  `systemctl list-units –t|–type service`

- 查看所有服务

  systemctl list-units –t service -a

  设定某服务开机启动

- `chkconfig name on–>systemctl enable name.service`

设定某服务开机禁止启动
`chkconfig name off –>systemctl disable name.service`

查看所有服务的开机自启状态
`chkconfig –list–>systemctl list-unit-files -t service` 



- 用来列出该服务在那些运行级别下启用或禁用

chkconfig sshd –list –>ls /etc/system/system/*.wants/sshd.service

[root@www ~]# ls /etc/systemd/system/*.wants/sshd.service

/etc/systemd/system/multi-user.target.wants/sshd.service

- 查看服务是否开机自启
  `systemctl is-enabled name.servcice`
- 查看服务的依赖关系
  `systemctl list-dependencies`  

- 查看启动失败的服务
  `systemctl -failed -t service`
- 查看服务单元的启用和禁用状态
  `systemctl list-unit-files –t=service`
- 杀死进程
  `systemctl kill 进程名`   
  [图片上传失败...(image-53509-1519920006718)]
- 服务状态
  systemctl list-units -t service -a 显示状态
  loaded：unit配置文件已处理
  active（running）：一次或多次持续处理的运行
  active（exited）：成功完成一次性的配置
  active（waiting）:运行中，等待一个事件
  inactive：不运行
  enabled：开机启动
  disabled：开机不启动
  static：开机不启动，但可以被另一个启用的服务激活

- 运行级别
  target units：
  unit配置文件：.target 以target结尾的文件
  ls /usr/lib/system/system/*.target
  systemctl list-unit-files -type target -all
  0–>runlevel0.target, poweroff.target
  1–>runlevel1.target, rescue.target
  2–>runlevel2.target, muti-user.target
  3–>runlevel3.target, mutil-user.target
  4–>runlevel4.target, multi-user.target
  5–>runlevel5.target, graphical.target
  6–>runlevel6.target, reboot.target

  

- 查看依赖性
  `systemctl list-dependencies graphical.target`

- 查看默认运行级别
  systemctl get-default 在Sys V风格的系统上是查看/etc/inittab文件其中有一条id:5:initdefault:

- 级别切换
  `systemctl isolate muti-user.target` 
  注意：只有当/lib/system/system/*.target文件中AllowIsolate=yes时才能奇幻（修改文件需执行systemctl daemon-reload生效）

- 设定默认运行级别
  `systemctl set-default muti-user.target`     
  实则将multi-user.target链接至default.target
  `ls –l /etc/system/system/default.target`

- 进入紧急救援模式
  `systemctl rescue`

- 切换至emergency模式
  `systemctl emergency`

- 在systemd风格的系统上还能使用sysv风格系统上的关机，重启等命令，指示将该命令链接到systemctl的一个软链接
  关机：`systemctl halt systemctl poweroff` 
  重启：`systemctl reboot`   
  挂起：`systemctl suspend`   
  休眠：`systemctl hibernate`   
  休眠并挂起：`systemctl hybrid-sleep`

> 使用systemctl控制单元时，通常需要使用单元文件的全名，包括扩展名，但是有些单元可以在systemctl中使用简写方式
>
> 如果无扩展名，systemctl默认把扩展名当做.service。例如netcfg和netcfg.service是等同的
>
> 挂载点会自动转化为相应的.mount单元，例如/home等价于home.mount
>
> 设备会自动转化为相应的.device单元，所以/dev/sd2等价于dev-sda2.device
> 加载initramfs驱动模块
>
> 加载内核选项
>
> 内核初始化，centos7使用systemd代替init
>
> 执行initrd.target所有单元，包括挂载/etc/fstab
>
> 从initramfs根文件系统切换到磁盘根目录
>
> systemd执行默认target配置，配置文件/etc/systemd/default.target /etc/systemd/system/
>
> systemd执行sysinit.target初始化系统及basic.target准备操作系统
>
> systemd启动multi-user.target下的本机与服务器服务
>
> systemd执行multi-user.target下的/etc/rc.d/rc.local
>
> systemd执行multi-user.target下的getty.target及登入服务
>
> systemd执行graphical需要的服务（此为图形界面所有）

## unit文件格式

以#开头的行后面的内容会被认为是注释
相关布尔值，1、yes、on、ture都是开启，0、no、off、false都是关闭
时间单位默认是秒



## Unit文件组成

- [Unit]：定义与Unit类型无关的通用选项，用于提供unit的扫描信息，unit行为及依赖关系等
- [Service]：与特定类型相关的专用选项；此处为Service类型
- [Install]：定义由“systemctl enable及systemctl disable”命令在实现服务启用或禁用时用到的一些选项

## unit段常用选项

- Description：描述信息

  After：定义unit的启动次序，表示当前unit应该晚育那些unit启动，其功能与before相反
  Requires：依赖到的其他units，强依赖，被一来的units无法激活时，当前unit即无法激活
  Wants：依赖到的其他units，弱依赖
  Conflicts：定义units间的冲突关系

## Service段常用选项

- Type：定义硬性ExecStart及相关参数的功能的unit进程启动类型
- simple：默认值；这个daemon主要有ExecStart接的指令串来启动，启动后常驻于内存中
- forking：由ExecStart启动的程序透过spawns延伸出其他子程序来作为此daemon的主要服务原生父程序在启动结束后就会终止
- onshot：用于执行一项任务，随后立即退出的服务，不会常驻于内存中
- notify：与simple相同，但约定服务会在就绪后想systemd发送一个信号，需要配合NotifyAccess来让Systemd接收消息
- idle：与simple类似，要执行这个daemon必须要所有的工作都顺利执行完毕后才会执行。这类的daemon通常是开机到最后才只能即可的服务
- EnvironmentFile：环境配置文件
- ExeStart：指明启动unit要运行命令或脚本的绝对路径
- ExeStartPre：ExecStart前运行
- ExeStartPost：ExecStart后运行
- ExecStop：指明停止unit要运行的命令或脚本
- Restart：当设定Restart=1时，则当次daemon服务意外终止后，会在此自动启动此服务

## Install段常用选项

- Alias：别名(可使用systemctl command Alial.service)
  RequiredBy:被那些units所依赖，强依赖
  WantedBy：被那些units所依赖，弱依赖
  Also：安装本服务的时候还要安装别的相关服务
  注意：对于新创建的unit文件，或者修改了的unit文件，要通知systemd重载次配置文件，而后可以选择重启：`systemctl daemon-reload`
