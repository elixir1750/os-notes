---
tags: [操作系统, 速查]
---

# 缩写速查（第 3–6 课）

> [!tip] 先别慌：第 3–4 课真正要记的只有 12 个；第 5–6 课的新缩写在文末单独一节
> 下面分三档。**第一档必须记**，考试和理解主线都靠它；**第二档认识就行**，看到能查到意思即可；**第三档是指令**，读代码时对照着看。
> 读不懂一行代码时，先只问自己：**这一行在读/写哪个寄存器？这个寄存器属于哪一档？** 第二、三档的东西，知道它"在设置某个开关"就够了。

## 拆缩写的 4 个规律

学会这几条，大部分缩写能自己猜出来：

1. **结尾是 R 的，基本都是寄存器（Register）**：ELR、SPSR、ESR、VBAR、TTBR、SCR……
2. **`_EL1`、`_EL3` 后缀 = 这个寄存器归哪一级用**：`elr_el1` 和 `elr_el3` 是同一种东西，分别给 EL1 和 EL3 用。
3. **`mrs` / `msr` 是读写系统寄存器的两条指令**：`mrs x0, 某寄存器` = 读到 x0（**M**ove **R**egister ← **S**ystem）；`msr 某寄存器, x0` = 把 x0 写进去。读代码时看到它们，就知道"在读/写某个开关"。
4. **页表项里的两三个字母（AF、AP、SH……）都是"属性位"**：每个就是一个小开关，不用背。

---

## 第一档：必须记（12 个）

| 缩写 | 全称 | 人话 | 在哪出现 |
|---|---|---|---|
| **EL0 / EL1 / EL3** | Exception Level | **特权级**。EL0 用户程序，EL1 内核，EL3 最高（开机时在这） | 第 3、4 课全程 |
| **PC** | Program Counter | **下一条要执行的指令的地址** | 全程 |
| **SP** | Stack Pointer | **栈顶地址** | 设栈（第 17、18 页） |
| **PSTATE** | Processor State | **CPU 当前状态**：在哪个 EL、中断开没开 | 第 3 课 |
| **svc** | Supervisor Call | **用户程序主动进内核**（系统调用） | 第 3 课 |
| **eret** | Exception Return | **从异常返回**，同时恢复 PC 和 PSTATE。也是唯一能"降级"的办法 | 第 14 页 |
| **ELR** | Exception Link Register | 异常结束后**回到哪**（返回地址） | 第 14、33 页 |
| **SPSR** | Saved Program Status Register | 异常结束后**恢复成什么状态**（存的是 PSTATE） | 第 14、33 页 |
| **ESR** | Exception Syndrome Register | **出了什么事**（异常原因） | 第 34 页 |
| **VBAR** | Vector Base Address Register | **异常向量表在哪** | 第 30 页 |
| **TTBR0 / TTBR1** | Translation Table Base Register | **页表在哪**。0 管低地址（用户），1 管高地址（内核） | 第 20–28 页 |
| **MMU** | Memory Management Unit | **查页表、把虚拟地址翻译成物理地址的硬件** | 第 19–28 页 |

> [!example] 用一句话串起第一档
> 用户程序在 **EL0** 执行 **svc** → 硬件把返回地址存进 **ELR**、把 **PSTATE** 存进 **SPSR**、把原因写进 **ESR**，然后按 **VBAR** 跳到向量表 → 内核在 **EL1** 处理 → **eret** 回去。
> 另一边，**MMU** 每次访问内存都按 **TTBR0/TTBR1** 指向的页表翻译地址。

---

## 第二档：认识就行

### 系统寄存器（都是"开关面板"）

| 缩写 | 全称 | 人话 | 在哪出现 |
|---|---|---|---|
| SCR_EL3 | Secure Configuration Register | EL3 的安全配置。课上只用 3 个位：NS、HCE、RW | 第 14–16 页 |
| SCTLR_EL1 | System Control Register | 系统总开关。**M 位 = 开 MMU**，C/I 位 = 开缓存 | 第 26 页 |
| TCR_EL1 | Translation Control Register | 页表的规格：页多大、地址多少位 | 第 26 页 |
| MAIR_EL1 | Memory Attribute Indirection Register | 内存类型表（普通内存 / 设备内存），页表项用下标查它 | 第 26 页 |
| MPIDR_EL1 | Multiprocessor Affinity Register | **我是几号核**（低 8 位） | 第 13 页 |
| CurrentEL | Current Exception Level | **我现在在哪个 EL** | 第 14 页 |
| FAR_EL1 | Fault Address Register | 访问出错时，出错的地址 | 第 3 课 |
| TPIDR_EL1 | Thread Pointer / ID Register | 给内核存"每个核私有数据"的指针 | 第 18 页 |

### SCR_EL3 的三个位

| 位 | 全称 | 人话 |
|---|---|---|
| NS | Non-Secure | 下面几级是不是"非安全世界"。设 1 |
| HCE | Hypervisor Call Enable | 允许用 hvc 指令（虚拟化用） |
| RW | Register Width | 下一级用 64 位还是 32 位。设 1 = 64 位 |

### 中断与异常相关

| 缩写 | 全称 | 人话 |
|---|---|---|
| IRQ | Interrupt Request | 普通中断（外设、时钟） |
| FIQ | Fast Interrupt Request | 快速中断（优先级更高） |
| SError | System Error | 系统错误（异步的硬件错误） |
| DAIF | Debug / Abort(SError) / IRQ / FIQ | 四个**屏蔽位**，置 1 = 先不理这类中断 |
| EL1t / EL1h | t = thread，h = handler | EL1 用哪个栈：t 用 SP_EL0，h 用 SP_EL1 |

### 地址与内存相关

| 缩写 | 全称 | 人话 |
|---|---|---|
| VA / PA | Virtual / Physical Address | 虚拟地址 / 物理地址 |
| VMA / LMA | Virtual / Load Memory Address | 链接脚本里：运行时的地址 / 实际放在哪 |
| TLB | Translation Lookaside Buffer | 页表查询结果的缓存 |
| BSS | Block Started by Symbol | 未初始化的全局变量所在的段，启动时要清零 |
| MMIO | Memory-Mapped I/O | 设备伪装成一段内存地址，用读写内存的方式操作它 |

### 页表项里的属性位（第 21、24 页）

| 缩写 | 全称 | 人话 |
|---|---|---|
| V | Valid | 这一项有没有效 |
| AF | Access Flag | 访问过没有。启动时直接设 1 |
| AP | Access Permissions | 读写权限，以及用户能不能访问 |
| UXN / PXN | User / Privileged eXecute Never | 用户态 / 内核态**不准执行**这块里的代码 |
| SH | Shareability | 多核之间怎么共享缓存 |
| AttrIndx | Attribute Index | 去 MAIR 里查第几种内存类型 |
| nG | not Global | 是否只属于当前进程 |

---

## 第三档：指令（读代码时对照）

| 指令 | 全称 | 人话（左边 = 右边算出来的东西） |
|---|---|---|
| `mov x0, x1` | move | x0 = x1 |
| `add` / `sub` | add / subtract | 加 / 减 |
| `and` / `orr` / `bic` | and / or / bit clear | 按位与（只留某些位）/ 按位或（把某些位置 1）/ 把某些位清 0 |
| `lsl #3` | logical shift left | 左移 3 位 = ×8 |
| `ldr x0, [x1]` | load register | 从内存读：x0 = 地址 x1 处的值 |
| `str x0, [x1]` | store register | 写内存：把 x0 存到地址 x1 |
| `ldp` / `stp` | load / store pair | 一次读 / 写**两个**寄存器 |
| `ldr x0, =sym` | （伪指令） | x0 = sym 链接时定好的地址 |
| `adr` / `adrp` | address / address of page | x0 = PC + 偏移（跟着 PC 走）；adrp 只精确到 4KB 页 |
| `b` | branch | 跳转 |
| `bl` | branch with link | 调用函数（跳过去，并把返回地址存进 x30） |
| `blr x16` | branch with link to register | 调用 x16 里存的地址处的函数 |
| `ret` | return | 返回到 x30 |
| `cmp` + `beq` / `bne` | compare + branch if equal / not equal | 比较，相等 / 不相等就跳 |
| `cbz` / `cbnz` | compare and branch if zero / non-zero | 是 0 / 不是 0 就跳 |
| `mrs` / `msr` | move from / to system register | **读 / 写系统寄存器** |
| `isb` | Instruction Synchronization Barrier | 屏障：等前面改的系统寄存器生效 |
| `dsb` | Data Synchronization Barrier | 屏障：等前面的内存读写完成 |
| `tlbi` | TLB invalidate | 清掉 TLB 里的旧缓存 |
| `wfe` | wait for event | 睡着等别人叫醒（其他核在启动时等待） |

> [!tip] 寄存器名也有规律
> `x0`–`x30` 是通用寄存器（64 位），`w0`–`w30` 是它们的低 32 位。x29 = 帧指针（FP），x30 = 返回地址（LR）。

---

## 第 5–6 课：内存管理新出现的缩写

> [!tip] 先抓这 6 个
> **VMA、TLB、ASID、COW、LRU、FIFO**。其余的认识就行。第一档里的 MMU、TTBR、VA/PA 这两课还在用，意思不变。

### 必须记

| 缩写 | 全称 | 人话 | 在哪出现 |
|---|---|---|---|
| **VMA** | Virtual Memory Area | **虚拟内存区域**：操作系统登记"这段地址允许用、权限是什么"的记录。Linux 里叫 `vm_area_struct` | 第 5 课第 39–47 页；第 6 课 |
| **TLB** | Translation Lookaside Buffer | **地址翻译的缓存**：记着最近翻译过的"虚拟页 → 物理页" | 第 5 课第 30–35 页 |
| **ASID** | Address Space ID | **进程编号**，打在 TLB 条目上，切换进程不用清 TLB | 第 5 课第 33 页 |
| **COW** | Copy-On-Write | **写时拷贝**：先共享只读，谁要写再复制那一页 | 第 5 课第 63 页 |
| **FIFO** | First In, First Out | **先进先出**：换出最早进来的页 | 第 6 课第 43 页 |
| **LRU** | Least Recently Used | **最近最少使用**：换出最久没被访问的页 | 第 6 课第 46 页 |

### 认识就行

| 缩写 | 全称 | 人话 | 在哪出现 |
|---|---|---|---|
| PMP / sPMP | (supervisor-mode) Physical Memory Protection | RISC-V 的物理内存保护：用寄存器写明哪段物理地址能读写执行 | 第 5 课第 8–9 页 |
| ARM64 / AArch64 | ARM Architecture 64-bit | 64 位 ARM 架构（手机、树莓派） | 全程 |
| CR3 | Control Register 3 | x86-64 的页表基地址寄存器（相当于 ARM 的 TTBR） | 第 5 课第 23 页 |
| CR2 | Control Register 2 | x86-64 存缺页地址的寄存器（相当于 ARM 的 FAR_EL1） | 第 5 课第 50 页 |
| TCR_EL1 | Translation Control Register | 设定页大小（4K/16K/64K）、ASID 位数等 | 第 5 课第 33、71 页 |
| TLBI | TLB Invalidate | 清 TLB 的指令。`VMALLE1IS` 全清、`ASIDE1IS` 按 ASID 清、`VAE1IS` 按地址清 | 第 5 课第 32 页 |
| IS | Inner Shareable | 指令结尾的 IS = 对同组的所有核都生效 | 第 5 课第 32、35 页 |
| IPI | Inter-Processor Interrupt | 核间中断：一个核通知另一个核干活（比如清 TLB） | 第 5 课第 35 页 |
| XN / UXN | (User) eXecute Never | 页表项第 54 位：用户态不准执行 | 第 5 课第 25 页 |
| PXN | Privileged eXecute Never | 页表项第 53 位：内核态不准执行 | 第 5 课第 25 页 |
| DBM | Dirty Bit Modifier | 页表项第 51 位：这页被写过（脏） | 第 5 课第 25 页 |
| PTE | Page Table Entry | 页表项（课件写中文"页表项"） | 两课全程 |
| ELF | Executable and Linkable Format | Linux 可执行文件格式，VMA 的代码段、数据段按它建 | 第 5 课第 40 页 |
| fd | file descriptor | 文件描述符：打开文件后得到的编号 | 第 5 课第 42 页 |
| POSIX | Portable Operating System Interface | 类 Unix 系统的接口标准 | 第 5 课第 42 页 |
| SIGSEGV | Segmentation Violation signal | "段错误"信号，访问非法地址时发给进程 | 第 5 课第 84 页；第 6 课 |
| JIT | Just-In-Time compilation | 即时编译：运行时生成机器码 | 第 5 课第 60 页 |
| KSM | Kernel Same-page Merging | Linux 内存去重：内容一样的页合成一份 | 第 5 课第 64 页 |
| THP | Transparent Huge Pages | 透明大页：内核自动换成 2MB 大页 | 第 5 课第 70 页 |
| ZRAM / ESWAP | (compressed) RAM / Enhanced SWAP | 鸿蒙 HyperHold 用的内存压缩区 / 增强交换 | 第 5 课第 73 页 |
| SFI | Software Fault Isolation | 软件故障隔离：编译时插检查代码代替 MMU 隔离 | 第 5 课第 72 页 |
| KV Cache | Key-Value Cache | 大模型推理时存的中间结果，vLLM 用分页管理它 | 第 5 课第 74–76 页 |
| DMA | Direct Memory Access | 外设直接读写内存，不经过 CPU，需要物理连续的缓冲区 | 第 6 课第 4 页 |
| kmalloc | kernel malloc | 内核里的 malloc，底下用 SLUB | 第 6 课第 4 页 |
| SLAB / SLUB / SLOB | （名字，不是严格缩写；SLOB = Simple List Of Blocks） | 小对象分配器家族。课上讲 SLUB | 第 6 课第 19–31 页 |
| OPT | Optimal | 理想替换策略：换出未来最久不用的页（做不到，当标准答案） | 第 6 课第 42 页 |
| MRU | Most Recently Used | 换出最近刚用过的页 | 第 6 课第 49 页 |
| XOR | exclusive or | 异或。伙伴地址 = 自己地址 XOR 块大小 | 第 6 课第 11 页 |

