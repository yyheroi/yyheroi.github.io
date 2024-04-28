---
title: 02-rust基本类型
date: 2023-08-26 21:17:00
categories:
- rust
tags:
- rust基本类型
- rust

---









[toc]

# Rust基本数据类型

Rust 每个值都有其确切的数据类型，总的来说可以分为两类：基本类型和复合类型。 基本类型意味着它们往往是一个最小化原子类型，无法解构为其它类型(一般意义上来说)，由以下组成：

- 数值类型: 有符号整数 (`i8`, `i16`, `i32`, `i64`, `isize`)、 无符号整数 (`u8`, `u16`, `u32`, `u64`, `usize`) 、浮点数 (`f32`, `f64`)、以及有理数、复数
- 字符串：字符串字面量和字符串切片 `&str`
- 布尔类型： `true`和`false`
- 字符类型: 表示单个 Unicode 字符，存储为 4 个字节
- 单元类型: 即 `()` ，其唯一的值也是 `()`

## 1.数值类型

| 长度       | 有符号类型 | 无符号类型 |
| ---------- | ---------- | ---------- |
| 8 位       | `i8`       | `u8`       |
| 16 位      | `i16`      | `u16`      |
| 32 位      | `i32`      | `u32`      |
| 64 位      | `i64`      | `u64`      |
| 128 位     | `i128`     | `u128`     |
| 视架构而定 | `isize`    | `usize`    |

整形字面量可以用下表的形式书写：

| 数字字面量         | 示例          |
| ------------------ | ------------- |
| 十进制             | `98_222`      |
| 十六进制           | `0xff`        |
| 八进制             | `0o77`        |
| 二进制             | `0b1111_0000` |
| 字节 (仅限于 `u8`) | `b'A'`        |

## 2.[浮点类型](https://course.rs/basic/base-type/numbers.html#浮点类型)

**浮点类型数字** 是带有小数点的数字，在 Rust 中浮点类型数字也有两种基本类型： `f32` 和 `f64`，分别为 32 位和 64 位大小。默认浮点类型是 `f64`，在现代的 CPU 中它的速度与 `f32` 几乎相同，但精度更高。

下面是一个演示浮点数的示例：

```rust
fn main() {
    let x = 2.0; // f64

    let y: f32 = 3.0; // f32
}
```

## 3.[序列(Range)](https://course.rs/basic/base-type/numbers.html#序列range)

Rust 提供了一个非常简洁的方式，用来生成连续的数值，例如 **`1..5`，生成从 1 到 4 的连续数字，不包含 5** ；`1..=5`，生成从 1 到 5 的连续数字，包含 5，它的用途很简单，常常用于循环中：

```rust
for i in 1..=5 {
    println!("{}",i);
}
```

最终程序输出:

```console
1
2
3
4
5
```

**序列只允许用于数字或字符类型**，原因是：它们可以连续，同时编译器在编译期可以检查该序列是否为空，字符和数字值是 Rust 中仅有的可以用于判断是否为空的类型。如下是一个使用字符类型序列的例子：

```rust
for i in 'a'..='z' {
    println!("{}",i);
}
```

## 4.[有理数和复数](https://course.rs/basic/base-type/numbers.html#有理数和复数)

Rust 的标准库相比其它语言，准入门槛较高，因此有理数和复数并未包含在标准库中：

- 有理数和复数
- 任意大小的整数和任意精度的浮点数
- 固定精度的十进制小数，常用于货币相关的场景

好在社区已经开发出高质量的 Rust 数值库：[num](https://crates.io/crates/num)。

按照以下步骤来引入 `num` 库：

1. 创建新工程 `cargo new complex-num && cd complex-num`
2. 在 `Cargo.toml` 中的 `[dependencies]` 下添加一行 `num = "0.4.0"`
3. 将 `src/main.rs` 文件中的 `main` 函数替换为下面的代码
4. 运行 `cargo run`

```rust
use num::complex::Complex;

 fn main() {
   let a = Complex { re: 2.1, im: -1.2 };
   let b = Complex::new(11.1, 22.2);
   let result = a + b;

   println!("{} + {}i", result.re, result.im)
 }
```

#### [总结](https://course.rs/basic/base-type/numbers.html#总结)

之前提到了过 Rust 的数值类型和运算跟其他语言较为相似，但是实际上，除了语法上的不同之外，还是存在一些差异点：

- **Rust 拥有相当多的数值类型**. 因此你需要熟悉这些类型所占用的字节数，这样就知道该类型允许的大小范围以及你选择的类型是否能表达负数
- **类型转换必须是显式的**. Rust 永远也不会偷偷把你的 16bit 整数转换成 32bit 整数
- **Rust 的数值上可以使用方法**. 例如你可以用以下方法来将 `13.14` 取整：`13.14_f32.round()`，在这里我们使用了类型后缀，因为编译器需要知道 `13.14` 的具体类型

## 5.[函数要点](https://course.rs/basic/base-type/function.html#函数要点)

- 函数名和变量名使用[蛇形命名法(snake case)](https://course.rs/practice/naming.html)，例如 `fn add_two() -> {}`
- 函数的位置可以随便放，Rust 不关心我们在哪里定义了函数，只要有定义即可
- 每个函数参数都需要标注类型

```
fn add(i: i32, j: i32) -> i32 {
   i + j
 }

```

![img](https://pic2.zhimg.com/80/v2-54b3a6d435d2482243edc4be9ab98153_1440w.png)

### 返回值：

​	[无返回值`()`](https://course.rs/basic/base-type/function.html#无返回值)

- 函数没有返回值，那么返回一个 `()`
- 通过 `;` 结尾的表达式返回一个 `()`

​    [永不返回的发散函数 `!`](https://course.rs/basic/base-type/function.html#永不返回的发散函数-)

​		当用 `!` 作函数返回类型的时候，表示该函数永不返回( diverge function )，特别的，这种语法往往用做会导致程序崩溃的函数：

## 6.练习

[数值类型 - Rust By Practice( Rust 练习实践 )](https://zh.practice.rs/basic-types/numbers.html)

```// 填空
fn main() {
    let v: u16 = 38_u8 as u16; //从8位无符号整数（u8）到16位无符号整数（u16）的类型转换
}
```

```

// 修改 `assert_eq!` 让代码工作
fn main() {
    let x = 5;		//i32
    assert_eq!("i32".to_string(), type_of(&x)); //
}

// 以下函数可以获取传入参数的类型，并返回类型的字符串形式，例如  "i8", "u8", "i32", "u32"
fn type_of<T>(_: &T) -> String {
    format!("{}", std::any::type_name::<T>())
}

```

```
fn main() {
    assert_eq!(i8::MAX, 127); 
    assert_eq!(u8::MAX, 255); 
}

```

```

// 解决代码中的错误和 `panic`
fn main() {
   let v1 = 251_u8.wrapping_add(8);
   let v2 = match u8::checked_add(251, 8) {
        Some(value) => value,
        None => {
            println!("Overflow occurred.");
            0
        }
    };
   println!("{},{}",v1,v2);
}

```

```
fn main() {
    let x = 1_000.000_1; // f64
    let y: f32 = 0.12; // f32
    let z = 0.01_f64; // f64
}
```

```c
#使用两种方法来让下面代码工作
fn main() {
    assert!(0.1+0.2==0.3);
}
 fn main() {
     assert!(0.1_f32+0.2_f32==0.3_f32);
 }
//降低精度
fn main() {
    let eps=0.001;
    assert!((0.1_f64+ 0.2 - 0.3).abs() < eps);
}
//设置允许误差
```

### [序列Range](https://zh.practice.rs/basic-types/numbers.html#序列range)

1. 🌟🌟 两个目标: 1. 修改 `assert!` 让它工作 2. 让 `println!` 输出: 97 - 122

```
fn main() {
    let mut sum = 0;
    for i in -3..2 {
        sum += i
    }

    assert!(sum == -5);

    for c in 'a'..='z' {
        println!("{}",c as u8);
    }
}

```

```\// 填空
use std::ops::{Range, RangeInclusive};
fn main() {
    assert_eq!((1..5), Range{ start: 1, end: 5 });
    assert_eq!((1..=5), RangeInclusive::new(1, 5));
}
///RangeInclusive::new(1, 5) 创建的是一个闭区间，表示从 1 到 5（包括 5）的范围。若 (1..5) 创建的是一个半开区间，表示从 1 到 5（不包括 5）的范围。
```

```
use std::mem::size_of_val;
fn main() {
    let unit: () = ();
    assert!(size_of_val(&unit) == 0);		//单元类型占用的内存大小 0

    println!("Success!")
}
```

### [语句与表达式](https://zh.practice.rs/basic-types/statements-expressions.html#语句与表达式)

```
fn main() {
   let v = {
       let mut x = 1;
       x += 2		// 没有返回值  
   };

   assert_eq!(v, 3);
}
正确的做法
fn main() {
   let v = {
       let mut x = 1;
       x += 2;
       x
   };

   assert_eq!(v, 3);
}

let z = {
	// 分号让表达式变成了语句，因此返回的不再是表达式 `2 * x` 的值，而是语句的值 `()`
	2 * x;
};
fn main() {
   let v = { let x = 3; x};

   assert!(v == 3);
}
```

### [函数](https://zh.practice.rs/basic-types/functions.html#函数)



## 7.总结：

1.`let x = 2.0; // f64`

2.比较浮点数`(0.1_f64 + 0.2 - 0.3).abs() < 0.00001`

3.`编译器会进行自动推导，给予twenty i32的类型  let twenty = 20;`

4.按照补码循环溢出规则处理`et b = 255_u8.wrapping_add(20);  // 19`  `在 u8 的情况下，256 变成 0，257 变成 1，`

5.`(1..5)  表示从 1 到 5（不包括 5）半开区间的范围`

6.`(1..=5)  表示从 1 到 5（包括 5）半闭区间的范围`

6.**表达式不能包含分号**。`表达式总要返回值`

7.返回值为！的表达式

```
loop {}  
panic!("Never return");  
todo!();  
unimplemented!();  //未实现的占位符函数
 
```
