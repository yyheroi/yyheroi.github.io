---
title: 01-rust环境搭建
date: 2023-08-26 17:03:59
categories:
- rust
tags:
- rust环境搭建
- rust
---











当前环境：win11+wsl+vscode

## 1.安装rustup

```
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
sudo apt install build-essential
rustc -V 
cargo -V
```

## 2.安装vsocode插件

```
rust-analyzer ，Rust 语言插件
Even Better TOML，支持 .toml 文件完整特性
Error Lens, 更好的获得错误展示
One Dark Pro, 非常好看的 VSCode 主题
CodeLLDB, Debugger 程序
```

## 3.运行hello world!

```
cargo new world_hello
cd world_hello
cargo run
#编译
cargo build
#运行
./target/debug/world_hello
Hello, world!
#快速的检查一下代码能否编译通过
cargo check
```

## 4.修改 Rust 的下载镜像为国内的镜像地址

```
#在 $HOME/.cargo/config.toml 添加以下内容：

[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"
```

