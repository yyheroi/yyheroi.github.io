---
title: pinctrl
categories:
  - kernel
tags:
  - pinctrl
date: 2024-05-16 13:33:03
---







# 

查看具体设备树中的宏定义

include/dt-bindings/gpio/gpio.h

include/dt-bindings/pinctrl/rockchip.h

dt-bindings/clock/rk3588-cru.h



查看物理单系统中的pinctrl配置，获取物理外设真实的device name

  cat /sys/kernel/debug/pinctrl/pinctrl-maps
