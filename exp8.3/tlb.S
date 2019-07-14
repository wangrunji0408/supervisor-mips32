/*
# 简单 TLB 测试程序1：地址转化

需要实现以下指令：
- li (lui, ori), lw, nop
- j
- mtc0, tlbwi

需要实现以下CP0寄存器：
- Index
- EntryHi, EntryLo0, EntryLo1

*/

#include <regdef.h>
#include <mipsregs.h>
#include <unistd.h>
#include <exception.h>

    .set noreorder                  // 禁止指令重排序
    .set noat                       // 禁止使用$at寄存器
    .p2align 2

    .section .text.init
    .global entry_vector
entry_vector:                       // 启动入口点：0x80000000
    j start
    nop

    .section .text
start:
    mtc0 zero, CP0_PAGEMASK         // PageMask = 0 (4K Page)
    li t0, 0xC0000000
    mtc0 t0, CP0_ENTRYHI            // EntryHi = 0xC0000000
    li t0, (0x1 << 6) | 0b110
    mtc0 t0, CP0_ENTRYLO0           // EntryLo0 = { PFN: 0x1, D, V }
    mtc0 t0, CP0_ENTRYLO1           // EntryLo1 = { PFN: 0x1, D, V }
    mtc0 zero, CP0_INDEX            // Index = 0
    tlbwi                           // TLB: 0xC0000xxx -> 0x00001xxx
                                    //      0xC0001xxx -> 0x00001xxx

    li t0, 0x80001000
    lw t1, 0x0(t0)                  // t1 = *0x80001000
    li t0, 0xC0000000
    lw t2, 0x0(t0)                  // t2 = *0xC0000000
    li t0, 0xC0001000
    lw t3, 0x0(t0)                  // t3 = *0xC0001000
    bne t1, t2, fail
    nop
    bne t1, t3, fail
    nop

pass:
    j pass
    nop

fail:
    j fail
    nop
