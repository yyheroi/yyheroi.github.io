---
title: vscode-远程连接失败
categories:
  - test
tags:
  - vscode
date: 2024-05-17 17:14:4
---



































可能在服务端/root/.vscode-server/bin这个目录存在一个与你本地vscode版本不一致的文件夹，删除这个对应的文件夹重新连接就行了

# 先删除本地和服务端的know_hosts 

![image-20240517171503577](../imgs/image-20240517171503577.png)



[vscode远程连接提示过程试图写入的管道不存在_过程试图写入的管道不存在vscode-CSDN博客](https://blog.csdn.net/baidu_39131915/article/details/116302847)
