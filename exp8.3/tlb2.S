/*
# 简单 TLB 测试程序2：自动重填

需要实现以下指令：
- li (lui, ori), sll, srl, xor, and, lw, nop
- j, eret
- mfc0, mtc0, tlbwr

需要实现以下CP0寄存器：
- Status
- EBase
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

    .section .text.tlb_refill
tlb_refill_vector:                  // TLB Refill 入口点：0x80001000
    mfc0 k0, CP0_ENTRYHI
    sll k0, k0, 2
    srl k0, k0, 8
    ori k0, k0, 0b110               // k0 = (k0 << 2) >> 8 | 0b110
    mtc0 k0, CP0_ENTRYLO0
    ori k0, k0, 1 << 6
    mtc0 k0, CP0_ENTRYLO1
    tlbwr                           // TLB: 0xCxxxxxxx -> 0x0xxxxxxx
    eret
    nop

    .section .text
start:
    mfc0 t0, CP0_STATUS             // 初始化 CP0.status
    li t1, (ST0_BEV | ST0_IM | ST0_IE | ST0_EXL | ST0_ERL)
                                    // 取消错误、异常位，使得eret正常
                                    // 见Vol3p196ERL,错误置位会让eret跳ErEPC
    xor t1, t0, t1
    and t0, t0, t1                  // status Reg 的 IE位、IM位、BEV位 置零
    mtc0 t0, CP0_STATUS             // 暂停中断响应，直到启动完成

    mfc0 t0, CP0_CAUSE				// 初始化 CP0.cause
    li t1, CAUSEF_IV
    xor t1, t1, t0
    and t0, t0, t1                  // Cause IV位置零
    mtc0 t0, CP0_CAUSE              // 关闭中断特殊入口

    li t0, PAGE_SIZE
    mtc0 t0, CP0_EBASE              // 设定中断响应基址为0x8000_1000

test0:
    li t0, 0x80001000
    lw t1, 0x0(t0)                  // t1 = *0x80001000
    li t0, 0xC0001000
    lw t2, 0x0(t0)                  // t2 = *0xC0001000
    bne t1, t2, fail
    nop

pass:
    j pass
    nop

fail:
    j fail
    nop
