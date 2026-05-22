---
title: RISC-V Machine-Mode Trap 机制与 RVOS 实现
categories:
  - RVOS
tags:
  - RVOS
  - traps
  - RISC-V
date: 2026-05-19 19:17:22
categories:
- RVOS
tags:
- RVOS
- traps
---

本文梳理 RISC-V 在 Machine 模式下的 Trap 处理机制，并对照 `05-traps` 参考实现与 RVOS 中的 trap 子系统，说明硬件自动行为、CSR 语义及软件 Top/Bottom Half 分工。

---

## 1. 控制流与 Trap 分类

处理器按序取指、译码、执行，形成**控制流（Control Flow）**。分支、跳转属于可预期的控制流变更；由指令 fault、环境调用或异步事件引起的控制流变更称为**异常控制流（Exceptional Control Flow, ECF）**。

RISC-V 将 ECF 统一为 **Trap**，并划分为：

| 类别 | 同步性 | 触发时机 | 典型场景 |
|------|--------|----------|----------|
| Exception | 同步 | 与当前指令执行相关 | 非法指令、访存 fault、`ecall` |
| Interrupt | 异步 | 与当前 PC 无严格绑定 | 定时器、外部 IRQ、软件中断 |

内核需完成：保存上下文、解析 `mcause`、执行处理逻辑、恢复上下文并通过 `mret` 返回。

---

## 2. 特权级与 M 模式

RISC-V 可选实现 M / S / U 三级特权。每个 **hart** 在任意时刻处于其中一级：

| 模式 | 缩写 | 典型职责 |
|------|------|----------|
| Machine | M | 固件、引导、底层 Trap 入口 |
| Supervisor | S | 操作系统内核 |
| User | U | 用户态程序 |

`05-traps` 与 RVOS 当前均在 **M 模式**运行：可直接访问 M 级 CSR 与物理地址空间。完整系统中 Trap 常先进入 M 模式（或经委托进入 S 模式）；本章实现将 Trap 向量与处理程序均置于 M 模式。

---

## 3. Trap 相关 CSR（M 模式）

| CSR | 功能 |
|-----|------|
| **mtvec** | Trap 向量基址；发生 Trap 时 PC 跳转至此（需 4 字节对齐） |
| **mepc** | 异常返回 PC；`mret` 时写回 PC |
| **mcause** | Trap 原因；最高位为 Interrupt 标志，低位为 Exception Code |
| **mtval** | 附加信息（如 fault 地址、非法指令编码），依异常类型由实现定义 |
| **mstatus** | 特权级、全局中断使能（MIE/MPIE、MPP 等） |
| **mscratch** | M 模式专用；规范未规定语义，实现中常存放上下文指针 |
| **mie / mip** | 中断使能位 / 中断挂起位 |

### 3.1 mtvec 寻址模式

`mtvec` 低 2 位为 MODE：

- **Direct（0）**：所有 Trap 跳转至 `BASE`
- **Vectored（1）**：Exception 跳转 `BASE`；Interrupt 跳转 `BASE + 4 × code`

两处实现均采用 **Direct**，入口符号为 `trap_vector`。

### 3.2 mcause 编码

```
┌──────────────────────────────────────────┐
│ MSB (Interrupt) │ Exception Code [LSB] │
└──────────────────────────────────────────┘
   1 → Interrupt      具体类型编号
   0 → Exception
```

判别逻辑（与 `trap.c` / `trap.cc` 一致）：

```c
if (cause & MCAUSE_MASK_INTERRUPT) {
    /* Interrupt */
} else {
    /* Exception */
}
```

常用 **Exception Code**（Interrupt 位为 0）：

| Code | 说明 |
|------|------|
| 2 | Illegal instruction |
| 5 | Load access fault |
| 7 | Store/AMO access fault |
| 8 | Environment call from U-mode |
| 11 | Environment call from M-mode |

常用 **Interrupt Code**（Interrupt 位为 1，取 `cause & 0x7FFFFFFF`）：

| Code | 说明 |
|------|------|
| 3 | Machine software interrupt |
| 7 | Machine timer interrupt |
| 11 | Machine external interrupt |

---

## 4. Trap 入口：硬件状态转移

Trap 触发后，硬件在跳转 `mtvec` 之前自动完成（Privileged Architecture 规范）：

1. `MPIE ← MIE`，`MIE ← 0`（关闭 M 模式全局中断）
2. `mepc ←` 陷阱相关 PC  
   - **Exception**：指向引起 Trap 的指令  
   - **Interrupt**：指向被中断指令的下一条指令
3. `mcause`（及必要时 `mtval`）← 原因与附加数据
4. `MPP ←` 当前特权级，随后进入 **M 模式**
5. `PC ← mtvec` 所指向地址

此后由软件 Trap Handler 接管。

---

## 5. 软件处理流程

Trap 处理划分为四个阶段，对应 `trap_init`、`trap_vector`（汇编）、`trap_handler`（C）、`mret`（汇编）：

```
┌─────────────────┐
│ 初始化           │  配置 mtvec、mscratch
└────────┬────────┘
         ▼
┌─────────────────┐
│ Top Half（汇编） │  保存 GPR → 调用 C handler
└────────┬────────┘
         ▼
┌─────────────────┐
│ C Handler       │  解析 mcause，更新返回 PC
└────────┬────────┘
         ▼
┌─────────────────┐
│ Bottom Half     │  恢复 GPR → mret
└─────────────────┘
```

### 5.1 初始化

`05-traps/trap.c`：

```c
void trap_init(void)
{
    w_mtvec((reg_t)trap_vector);
}
```

RVOS `trap.cc`：

```c
void TrapInit(void)
{
    RVOS::Arch::WriteMscratch(reinterpret_cast<RegT>(&g_trapContext));
    RVOS::Arch::WriteMtvec(reinterpret_cast<RegT>(trap_vector));
}
```

RVOS 在初始化阶段将 **`mscratch` 绑定至 `g_trapContext`**，供 Trap 路径保存通用寄存器；`05-traps` 在 `sched_init()` 中将 `mscratch` 置 0，与协作式调度中的 `switch_to` 协同使用。

### 5.2 Top Half：`trap_vector`

`entry.S` / `trap_entry.S` 执行序列：

1. `csrrw t6, mscratch, t6`：交换 `t6` 与上下文基址
2. `reg_save`：将 callee-saved 与 caller-saved GPR（不含 `gp`/`tp`）写入 `TrapContext`
3. 单独保存真实 `t6`（`t6` 作为基址寄存器参与保存过程）
4. `csrr a0, mepc`；`csrr a1, mcause`；`call trap_handler`
5. `csrw mepc, a0`：应用 C 层返回的 PC
6. `reg_restore`；`mret`

**mscratch 的作用**：Trap 入口时尚未建立栈帧，不宜立即修改 `sp`。预先将上下文结构地址存入 `mscratch`，可在无栈或少栈条件下完成第一轮寄存器保存，属 RISC-V 内核常见写法。

**TrapContext 布局**（`trap_context.hh`）须与汇编偏移严格一致：31×`uint64_t`，`gp`/`tp` 槽位保留但不写入（`tp` 在 `05-traps` 中固定为 hart ID）。

### 5.3 C Handler

`05-traps` 实现（同步异常进入 `panic`，教学用）：

```c
reg_t trap_handler(reg_t epc, reg_t cause)
{
    reg_t return_pc = epc;
    reg_t cause_code = cause & MCAUSE_MASK_ECODE;

    if (cause & MCAUSE_MASK_INTERRUPT) {
        switch (cause_code) {
        case 3:  uart_puts("software interruption!\n"); break;
        case 7:  uart_puts("timer interruption!\n"); break;
        case 11: uart_puts("external interruption!\n"); break;
        }
    } else {
        printf("Sync exceptions! Code = %ld\n", cause_code);
        panic("OOPS! What can I do!");
    }
    return return_pc;
}
```

RVOS 实现（对访存 fault 推进 `mepc`）：

```c
std::uint64_t trap_handler(std::uint64_t epc, std::uint64_t cause)
{
    std::uint64_t returnPc = epc;
    const std::uint64_t code = cause & kMcauseMaskEcode;

    if (cause & kMcauseMaskInterrupt) {
        /* 记录中断类型，待扩展 */
    } else {
        switch (code) {
        case 5:  /* Load access fault */
        case 7:  /* Store/AMO access fault */
            returnPc += 4;
            break;
        default:
            while (true) { __asm__ volatile("wfi"); }
        }
    }
    return returnPc;
}
```

**mepc 调整**：Exception 时 `mepc` 指向 faulting 指令。若处理策略为忽略该次访存并继续执行，须将返回 PC 增加 4（标准 32 位指令宽度；压缩指令需按长度处理），否则 `mret` 将反复触发同一异常。

测试用例通过向非法地址写入触发 Store/AMO access fault（code 7）：

```c
*(int *)0x00000000 = 100;   /* 05-traps */
```

RVOS 在 QEMU `virt` 上使用 `0x200`，避开低地址 MMIO 区域，语义仍为故意触发访存 fault。

### 5.4 `mret` 与返回路径

`mret` 执行（M 模式）：

1. 当前特权级 ← `mstatus.MPP`；`MPP` 复位
2. `MIE ← MPIE`；`MPIE ← 1`
3. `PC ← mepc`

因此 `trap_handler` 的返回值经 `csrw mepc, a0` 写入后，由 `mret` 生效。

---

## 6. Trap 处理时序

```mermaid
sequenceDiagram
    participant Task as 任务/内核代码
    participant HW as Hart 硬件
    participant ASM as trap_vector
    participant C as trap_handler

    Task->>HW: 执行指令 / 中断断言
    HW->>HW: 更新 mepc, mcause, mstatus
    HW->>ASM: PC ← mtvec
    ASM->>ASM: 保存 TrapContext
    ASM->>C: trap_handler(mepc, mcause)
    C->>C: 分类处理，计算 return PC
    C-->>ASM: return return_pc
    ASM->>ASM: mepc ← a0; 恢复 GPR
    ASM->>HW: mret
    HW->>Task: PC ← mepc
```

---

## 7. Trap 与任务切换

`entry.S` 中的 **`switch_to`** 复用 `reg_save` / `reg_restore` 与 `mscratch` 机制，在协作式调度下切换任务上下文：

```c
void sched_init(void)
{
    w_mscratch(0);
}
```

`task_create` 仅初始化目标任务的 `sp`、`ra`；首次调度经 `switch_to` 加载下一任务上下文。Trap 保存帧与任务 `struct context` / `TrapContext` 在布局上同源，均为 GPR 镜像。

---

## 8. 实现对照

| 维度 | `05-traps` | RVOS |
|------|------------|------|
| ISA 宽度 | RV32（`lw`/`sw`） | RV64（`ld`/`sd`） |
| 语言 | C | C++20 |
| Trap 入口 | `trap_vector` | `trap_vector` |
| CSR 访问 | `riscv.h` | `Csr.hh` |
| 上下文 | `struct context` | `TrapContext` |
| `mscratch` | `sched_init` 置 0 | `TrapInit` → `g_trapContext` |
| 同步异常 | 打印后 `panic` | 访存 fault：`mepc += 4` |
| 验证路径 | 任务循环调用 `trap_test` | `KernelInit` → `TrapTest` |

RVOS 在相同 Trap 框架上采用类型化 CSR 封装，并对可恢复的访存 fault 实现了 `mepc` 推进逻辑。

---

## 9. 小结

| 术语 | 含义 |
|------|------|
| Trap | Exception 与 Interrupt 的统称 |
| mtvec | Trap 向量入口 |
| mepc | 异常返回地址（软件可改写） |
| mcause | Trap 类型编码 |
| mscratch | 实现定义的 scratch；本实现用于上下文指针 |
| Top Half | 汇编：保存现场、调用 C |
| Bottom Half | 汇编：恢复现场、`mret` |

本章构成后续工作的基础：M/S 模式委托、定时器与外部中断使能、`ecall` 系统调用接口，以及 S/U 模式下的 Trap 处理。
