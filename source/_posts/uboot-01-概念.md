---
title: uboot-01-概念
categories:
  - uboot
tags:
  - uboot概念
date: 2024-05-15 21:59:01

---

uboot(Universal Boot Loader)

uboot 官网为 http://www.denx.de/wiki/U-Boot/

Linux 系统要启动就必须需要一个 bootloader 程序，也就说芯片上电以后先运行一段
bootloader 程序。这段 bootloader 程序会先初始化DDR 等外设，然后将 Linux 内核从 flash(NAND，
NOR FLASH，SD，MMC 等)拷贝到 DDR 中，最后启动 Linux 内核

uboot主要目的是为系统启动做准备

uboot是一种通用的bootloader，支持多种架构







uboot



