---
title: struct-dev-debug
categories:
  - test
tags:
  - debug
date: 2024-06-03 10:10:43
---

最近调试pinctrl时需要打印全部的state

可以通过struct dev查看 pinctrl client的相关信息,因为pinctrl client是通过设备树配置的，通过probe会构造struct dev

在设备树中,pinctrl client 设备节点会包含 `pinctrl-names` 和 `pinctrl-0` 等属性,用于描述引脚配置

可以使用 `dev_dbg()`、`dev_info()` 等宏来打印这个 `struct device *dev` 的调试信息

```
struct pinctrl_state *state;
struct pinctrl_desc *desc;
struct device *dev;
struct pinctrl *p;
	
dev = pctldev->dev;
desc = pctldev->desc;
p = pctldev->p;

printk(KERN_ERR"[%s][%d]Device name: %s\n", __func__, __LINE__, dev_name(dev));
printk(KERN_ERR"[%s][%d]Device type: %s\n", __func__, __LINE__, dev->type ? dev->type->name : "unknown");
printk(KERN_ERR"[%s][%d]Device driver: %s\n", __func__, __LINE__, dev->driver ? dev->driver->name : "unknown");
printk(KERN_ERR"[%s][%d]desc->name %s\n", __func__, __LINE__, desc->name);
list_for_each_entry(state, &p->states, node) {
	printk(KERN_ERR"[%s][%d] state->name %s\n", __func__, __LINE__, state->name);
}
```

