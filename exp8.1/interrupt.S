#include <regdef.h>
#include <mipsregs.h>
#include <unistd.h>
#include <exception.h>

    .set noreorder                  // 禁止指令重排序
    .set noat                       // 禁止使用$at寄存器
    .p2align 2

    .section .text.init
    .global entry_vector
entry_vector:						// 启动入口点：0x80000000
    lui k0, %hi(start)
    addiu k0, %lo(start)
    jr k0
    nop

    .section .text.trap
trap_vector:						// 中断入口点：0x80000180
    lui k0, %hi(trap_handler)
    addiu k0, %lo(trap_handler)
    jr k0
    nop

    .section .text
start:
    mfc0 t0, CP0_STATUS             // 初始化 CP0.status
    lui t1, %hi(ST0_BEV)
    ori t1, t1, (ST0_IM | ST0_IE | ST0_EXL | ST0_ERL)
                                    // 取消错误、异常位，使得eret正常
                                    // 见Vol3p196ERL,错误置位会让eret跳ErEPC
    xor t1, t0, t1
    and t0, t0, t1                  // status Reg 的 IE位、IM位、BEV位 置零
    mtc0 t0, CP0_STATUS             // 暂停中断响应，直到启动完成

    mfc0 t0, CP0_CAUSE				// 初始化 CP0.cause
    lui t1, %hi(CAUSEF_IV)
    xor t1, t1, t0
    and t0, t0, t1                  // Cause IV位置零
    mtc0 t0, CP0_CAUSE              // 关闭中断特殊入口

#ifdef MACH_QEMU
                                    // QEMU 上用串口输入产生中断
    lui t0, 0xBFD0                  // NOTE: all COM_* share high 16 bits
                                    // 0xBFD0 should be %hi(COM1) but can not be used
                                    // due to a compiler bug (bugzilla/20649)
    sb zero, %lo(COM_FCR)(t0)       // *FCR = 0
    ori t1, zero, %lo(COM_LCR_DLAB)
    sb t1, %lo(COM_LCR)(t0)         // *LCR = LCR_DLAB
    ori t1, zero, %lo(COM_DLL_VAL)
    sb t1, %lo(COM_DLL)(t0)         // *DLL = DLL_VAL
    sb zero, %lo(COM_DLM)(t0)       // *DLM = 0
    ori t1, zero, %lo(COM_LCR_CONFIG)
    sb t1, %lo(COM_LCR)(t0)         // *LCR = LCR_CONFIG
    sb zero, %lo(COM_MCR)(t0)       // *MCR = 0
    ori t1, zero, %lo(COM_IER_RDI)
    sb t1, %lo(COM_IER)(t0)         // *IER = IER_RDI
#endif

    mfc0 t0, CP0_STATUS
    ori t0, t0, (ST0_IE | STATUSF_IP4)
                                    // status Reg 的 IE位 置一
    mtc0 t0, CP0_STATUS             // 启动中断
    nop

spin:
    b spin							// 等待中断
    nop
    
trap_handler:
#ifdef MACH_QEMU
    lui k0, 0xBFD0					// 读串口，响应中断
    lb k0, %lo(COM1)(k0)
#endif
    addi t9, t9, 1					// 中断计数，查看 t9 的值以确认中断处理正常
    eret
    nop
