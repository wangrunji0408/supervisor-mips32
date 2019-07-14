ENTRY(entry_vector)
OUTPUT_ARCH("mips:isa32r2")
OUTPUT_FORMAT("elf32-tradlittlemips")

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
    . = 0x80001000;
    .text.tlb_refill : {
        KEEP (*(.text.tlb_refill))
    }
    .text : {
        *(.text)
    }
}
