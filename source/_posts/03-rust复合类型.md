---
title: 03-rust复合类型
date: 2023-08-28 21:58:27
categories:
- rust
tags:
- rust复合类型
- rust
---





# 1.字符串和切片

## [什么是字符串?](https://course.rs/basic/compound-type/string-slice.html#什么是字符串)

**Rust 中的字符是 Unicode 类型，因此每个字符占据 4 个字节内存空间，但是在字符串中不一样，字符串是 UTF-8 编码，也就是字符串中的字符所占的字节数是变化的(1 - 4)**

`str` 类型是硬编码进可执行文件，也无法被修改，但是 `String` 则是一个可增长、可改变且具有所有权的 UTF-8 编码字符串，**当 Rust 用户提到字符串时，往往指的就是 `String` 类型和 `&str` 字符串切片类型，这两个类型都是 UTF-8 编码**。

```
let a = [1, 2, 3, 4, 5];

let slice = &a[1..3];

assert_eq!(slice, &[2, 3]);

```



## [String 与 &str 的转换](https://course.rs/basic/compound-type/string-slice.html#string-与-str-的转换)

```
fn main() {
    let s = String::from("hello,world!");
    say_hello(&s);
    say_hello(&s[..]);
    say_hello(s.as_str());
}

fn say_hello(s: &str) {
    println!("{}",s);
}
```

## [字符串索引](https://course.rs/basic/compound-type/string-slice.html#字符串索引)

## [字符串切片](https://course.rs/basic/compound-type/string-slice.html#字符串切片)

通过索引区间来访问字符串时，**需要格外的小心**，一不注意，就会导致你程序的崩溃！

## [操作字符串](https://course.rs/basic/compound-type/string-slice.html#操作字符串)

#### [追加 (Push)](https://course.rs/basic/compound-type/string-slice.html#追加-push)



#### [插入 (Insert)](https://course.rs/basic/compound-type/string-slice.html#插入-insert)

#### [替换 (Replace)](https://course.rs/basic/compound-type/string-slice.html#替换-replace)

#### [删除 (Delete)](https://course.rs/basic/compound-type/string-slice.html#删除-delete)

#### [连接 (Concatenate)](https://course.rs/basic/compound-type/string-slice.html#连接-concatenate)

## [字符串转义](https://course.rs/basic/compound-type/string-slice.html#字符串转义)

```
fn main() {
    println!("{}", "hello \\x52\\x75\\x73\\x74");
    let raw_str = r"Escapes don't work here: \x3F \u{211D}";
    println!("{}", raw_str);

    // 如果字符串包含双引号，可以在开头和结尾加 #
    let quotes = r#"And then I said: "There is no escape!""#;
    println!("{}", quotes);

    // 如果还是有歧义，可以继续增加，没有限制
    let longer_delimiter = r###"A string with "# in it. And even "##!"###;
    println!("{}", longer_delimiter);
}
```

## [操作 UTF-8 字符串](https://course.rs/basic/compound-type/string-slice.html#操作-utf-8-字符串)

[字符串与切片 - Rust语言圣经(Rust Course)](https://course.rs/basic/compound-type/string-slice.html#课后练习)

```
for c in "中国人".chars() {
    println!("{}", c);
}
```

## [课后练习](https://course.rs/basic/compound-type/string-slice.html#课后练习)

> Rust By Practice，支持代码在线编辑和运行，并提供详细的习题解答。
>
> - [字符串](https://zh.practice.rs/compound-types/string.html)
>   - [习题解答](https://github.com/sunface/rust-by-practice/blob/master/solutions/compound-types/string.md)
> - [切片](https://zh.practice.rs/compound-types/slice.html)
>   - [习题解答](https://github.com/sunface/rust-by-practice/blob/master/solutions/compound-types/slice.md)
> - [String](https://zh.practice.rs/collections/String.html)
>   - [习题解答](https://github.com/sunface/rust-by-practice/blob/master/solutions/collections/String.md)

```

// 填空并修复错误
fn main() {
    let s = String::from("hello, 世界");
    let slice1 = &s[0..1]; //提示: `h` 在 UTF-8 编码中只占用 1 个字节
    assert_eq!(slice1, "h");

    let slice2 = &s[7..10];// 提示: `世` 在 UTF-8 编码中占用 3 个字节
    assert_eq!(slice2, "世");
    
    // 迭代 s 中的所有字符
    for (i, c) in s.chars().enumerate() {
        if i == 7 {
            assert_eq!(c, '世')
        }
    }

    println!("Success!")
}



// 填空
fn main() {
    let mut s = String::new();
     s.push_str("hello");

    let v = vec![104, 101, 108, 108, 111];

    // 将字节数组转换成 String
    let s1 = String::from_utf8(v).unwrap();
    
    
    assert_eq!(s, s1);

    println!("Success!")
}



// 填空
use std::mem;

fn main() {
    let story = String::from("Rust By Practice");

    // 阻止 String 的数据被自动 drop
    let mut story = mem::ManuallyDrop::new(story);

    let ptr = story.as_mut_ptr();
    let len = story.len();
    let capacity = story.capacity();

    assert_eq!(16, len);

    // 我们可以基于 ptr 指针、长度和容量来重新构建 String. 
    // 这种操作必须标记为 unsafe，因为我们需要自己来确保这里的操作是安全的
    let s = unsafe { String::from_raw_parts(ptr, len, capacity) };

    assert_eq!(*story, s);

    println!("Success!")
}

```



# 2.[元组](https://course.rs/basic/compound-type/tuple.html#元组)

# 3. 元组
# 4. test

待续。。。
