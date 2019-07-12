ENTRY(entry_vector)
OUTPUT_ARCH("mips:isa32r2")
OUTPUT_FORMAT("elf32-tradlittlemips")

/* Qemu serial constants */
PROVIDE(COM1 = 0xBFD003F8);
PROVIDE(COM_LSR = COM1 + 5);
PROVIDE(COM_LSR_DATA = 0x01);
PROVIDE(COM_FCR = COM1 + 2);
PROVIDE(COM_LCR = COM1 + 3);
PROVIDE(COM_LCR_DLAB = 0x80);
PROVIDE(COM_DLL = COM1 + 0);
PROVIDE(COM_DLL_VAL = 115200 / 9600);
PROVIDE(COM_DLM = COM1 + 1);
PROVIDE(COM_LCR_WLEN8 = 0x03);
PROVIDE(COM_LCR_CONFIG = COM_LCR_WLEN8 & ~(COM_LCR_DLAB));
PROVIDE(COM_MCR = COM1 + 4);
PROVIDE(COM_IER = COM1 + 1);
PROVIDE(COM_IER_RDI = 0x01);

SECTIONS
{
    . = 0x807F0000;
    .bss : {
        _sbss = .;         /* define a global symbol at bss start */
        *(.bss)
        . = ALIGN(4);
        _ebss = .;         /* define a global symbol at bss end */
    }
    .rodata : {
        *(.rodata)
    }
    . = 0x80000000;
    .text.init : {
        KEEP (*(.text.init))
    }
    . = 0x80000180;
    .text.trap : {
        KEEP (*(.text.trap))
    }
    .text : {
        *(.text)
    }
}
