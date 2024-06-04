---
title: pinctrl
categories:
  - kernel
tags:
  - pinctrl
date: 2024-05-16 13:33:03
---



查看具体设备树中的宏定义

include/dt-bindings/gpio/gpio.h

include/dt-bindings/pinctrl/rockchip.h

dt-bindings/clock/rk3588-cru.h



查看物理单系统中的pinctrl配置，获取物理外设真实的device name

  cat /sys/kernel/debug/pinctrl/pinctrl-maps





pinctrl的三大作用,有助于理解相关结构体

1.引脚枚举与命名 enumerating and naming

2.引脚服用 Multiplexing：比如用作GPIO、I2C或其他功能

3.引脚配置 Configuration：比如上拉、下拉、open drain、驱动强度等





rk3588s.dtsi
rk3588s.-pinctrl.dtsi该文件枚举了3588所有的iomux实例

查看引脚的复用情况
cat /sys/kernel/debug/pinctrl/pinctrl-rockchip-pinctrl/pinmux-pins

RK3588频脚计算方式与一般的计算方式没有区别：
GPIO pin脚计算公式：pin = bank * 32 + number
GPIO 小组编号计算公式：number = group * 8 + X

摘自官网：

下面演示GPIO1_D0 pin脚计算方法：

bank = 1;      //GPIO1_D0 => 1, bank ∈ [0,4]

group = 3;      //GPIO1_D0 => 3, group ∈ {(A=0), (B=1), (C=2), (D=3)}

X = 0;       //GPIO1_D0 => 0, X ∈ [0,7]

number = group * 8 + X = 3 * 8 + 0 = 24

pin = bank*32 + number= 1 * 32 + 24 = 56;

GPIO1_D0 对应的设备树属性描述为:<&gpio1 24 GPIO_ACTIVE_HIGH>,由kernel-5.10/include/dt-bindings/pinctrl/rockchip.h的
的宏定义可知，也可以将GPIO1_D0描述为<&gpio1 RK_PD0 GPIO_ACTIVE_HIGH>。



## client端相关结构体

https://pixso.cn/app/board/2hWH9JSK6ESlVP76tmeENQ?showQuickFrame=true&icon_type=3&file_type=20 

![image-20240530170508734](../imgs/image-20240530170508734.png)





rk3588-pinctrl-pin-config-debug

```
cd /sys/kernel/debug/pinctrl/pinctrl-rockchip-pinctrl 
cat pinmux-pins  
cat ../pinctrl-handles	#查看所有pinctrl client state
```



```

rk3588s.dtsi
rk3588s.-pinctrl.dtsi该文件枚举了3588所有的iomux实例

查看引脚的复用情况
cat /sys/kernel/debug/pinctrl/pinctrl-rockchip-pinctrl/pinmux-pins

RK3588频脚计算方式与一般的计算方式没有区别：
GPIO pin脚计算公式：pin = bank * 32 + number
GPIO 小组编号计算公式：number = group * 8 + X

摘自官网：

下面演示GPIO1_D0 pin脚计算方法：

bank = 1;      //GPIO1_D0 => 1, bank ∈ [0,4]

group = 3;      //GPIO1_D0 => 3, group ∈ {(A=0), (B=1), (C=2), (D=3)}

X = 0;       //GPIO1_D0 => 0, X ∈ [0,7]

number = group * 8 + X = 3 * 8 + 0 = 24

pin = bank*32 + number= 1 * 32 + 24 = 56;

GPIO1_D0 对应的设备树属性描述为:<&gpio1 24 GPIO_ACTIVE_HIGH>,由kernel-5.10/include/dt-bindings/pinctrl/rockchip.h的
的宏定义可知，也可以将GPIO1_D0描述为<&gpio1 RK_PD0 GPIO_ACTIVE_HIGH>。


rockchip_pinctrl_parse_dt
	info->groups = devm_kcalloc(dev, info->ngroups, sizeof(*info->groups), GFP_KERNEL);
	rockchip_pinctrl_parse_functions
		rockchip_pinctrl_parse_groups
			pinconf_generic_parse_dt_config
				parse_dt_cfg
					pinconf_to_config_packed
						PIN_CONF_PACKED

#define PIN_CONF_PACKED(p, a) ((a << 8) | ((unsigned long) p & 0xffUL))
5,1
105


of_property_read_u32(np, par->property, &val);
	of_property_read_u32_array(np, property, val, 1);
		of_property_read_variable_u32_array(np, property, val, 1, 0);
		of_find_property_value_of_size(np, property, 4, 0, &sz);

	pinctrl_show
		pinconf_show_setting
			pinconf_show_config
				setting->data.configs.configs

add_setting
	pinconf_map_to_setting

		setting->data.configs.configs = map->data.configs.configs;

rockchip_dt_node_to_map
	pinctrl_name_to_group
		rockchip_pin_group * grp = info->groups[i]

	new_map[i].data.configs.configs = grp->data[i].configs;


rockchip_pmx_set
	const struct rockchip_pin_config *data = info->groups[group].data;


rockchip_pin_group


uart1 {
		/omit-if-no-ref/
		uart1m1_xfer: uart1m1-xfer {
			rockchip,pins =
				/* uart1_rx_m1 */
				<1 RK_PB7 10 &pcfg_pull_up>,
				/* uart1_tx_m1 */
				<1 RK_PB6 10 &pcfg_pull_up>;
		};


pcfg_pull_up
	bias-pull-up;
		static const struct pinconf_generic_params dt_params[] = {
			{ "bias-bus-hold", PIN_CONFIG_BIAS_BUS_HOLD, 0 },
			{ "bias-disable", PIN_CONFIG_BIAS_DISABLE, 0 },
			{ "bias-high-impedance", PIN_CONFIG_BIAS_HIGH_IMPEDANCE, 0 },
			{ "bias-pull-up", PIN_CONFIG_BIAS_PULL_UP, 1 },

		static const struct pin_config_item conf_items[] = {
			PCONFDUMP(PIN_CONFIG_BIAS_PULL_UP, "input bias pull up", "ohms", true),

		enum pin_config_param {
			PIN_CONFIG_BIAS_BUS_HOLD,
			PIN_CONFIG_BIAS_DISABLE,
			PIN_CONFIG_BIAS_HIGH_IMPEDANCE,
			PIN_CONFIG_BIAS_PULL_DOWN,
			PIN_CONFIG_BIAS_PULL_PIN_DEFAULT,
			PIN_CONFIG_BIAS_PULL_UP,	//5
```

