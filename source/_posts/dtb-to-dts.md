---
title: dtb to dts
categories:
  - kernel
tags:
  - dtb
  - dts
date: 2024-05-30 11:05:15
---

[toc]

## [rk3588] dtc path

linux/kernel/scripts/dtc/dtc 

android/out/soong/host/linux-x86/bin/dtc

## 使用[adb](https://so.csdn.net/so/search?q=adb&spm=1001.2101.3001.7020)获取fdt文件

```
adb root
adb pull /sys/firmware/fdt d:	
pwd
```

## 使用以下指令生成dts文件

```
cd ./out/soong/host/linux-x86/bin/dtc
./dtc -I dtb -O dts –o fdt2dts.dts fdt
```
