---
title: 01以太网ethernet-概念
categories:
  - driver
tags:
  - ethrnet
date: 2024-05-23 15:30:58
---



## stmmac

drivers/net/stmicro/stmmac

> stmmac 是一种以太网媒体访问控制器(Ethernet MAC, EMAC)的实现,由ST Microelectronics公司开发和维护

## dwmac

>`dwmac` 是由 Synopsys 公司开发的一种广泛应用于系统芯片 (SoC) 设计中的以太网媒体访问控制器 (Ethernet MAC, EMAC) 实现

## rgmii

>RGMII(Reduced Gigabit Media Independent Interface)是一种以太网物理层(PHY)接口标准,主要用于连接系统芯片(SoC)与以太网收发器(PHY)之间。
>
>1. 接口速率:
>   - RGMII 支持 10/100/1000Mbps 三种以太网速率。
>2. 引脚数量:
>   - RGMII 使用 24 个引脚(双向各 12 个)来传输数据和控制信号。
>3. 时序要求:
>   - RGMII 接口需要严格的时序要求,包括数据和时钟之间的相位关系等。
>4. 信号类型:
>   - RGMII 使用LVCMOS电平的并行数据信号,以及独立的发送和接收时钟信号。



## cru

>CRU 是 Clock and Reset Unit 的缩写,指时钟和复位单元。它在系统芯片(SoC)中扮演着非常重要的角色。
>
>CRU 的主要功能包括:
>
>1. 时钟生成和管理:
>   - 生成和分配各种内部时钟信号,如 CPU 时钟、总线时钟等。
>   - 提供时钟切换和动态调频等功能,用于电源管理和性能优化。
>2. 复位控制:
>   - 生成和分配各种内部复位信号,如系统复位、模块复位等。
>   - 提供复位同步和延迟功能,确保复位信号的正确传播。
>3. 时钟/复位状态监控:
>   - 监控时钟和复位信号的状态,并提供相关中断和状态寄存器。
>   - 用于诊断和调试时钟/复位相关的问题。
>
>CRU 通常作为 SoC 中的一个独立模块,集中管理整个系统的时钟和复位相关功能。它与 CPU、内存、外设等模块紧密交互,确保系统稳定可靠地运行。
>
>CRU 的设计和实现通常由 SoC 设计团队负责,需要考虑时钟源、复位策略、功耗、时序等多方面因素。它是构建高性能、低功耗 SoC 的关键组件之一。





## rk3588-gmac驱动

kernel-5.10

kernel/drivers/net/ethernet/stmicro/stmmac

```
rk_gmac_probe
	stmmac_probe_config_dt
		stmmac_dt_phy
```



