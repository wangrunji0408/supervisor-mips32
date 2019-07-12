ifeq ($(OS),Windows_NT)
# Windows Host
GCCPREFIX	:= mips-mti-elf-
else
#GCCPREFIX	:= mipsel-linux-gnu-
#GCCPREFIX	:= mips-mti-elf-
endif
QEMU := qemu-system-mipsel
LD	:= $(GCCPREFIX)ld
CC	:= $(GCCPREFIX)gcc

TARGET	:= interrupt.elf
INCLUDE	:= ../kernel/include
LDSCRIPT	:= kernel.ld
ASFLAG	:= -D__ASSEMBLY__ -EL -g -mips32r2 -mno-abicalls -mno-shared

ifeq ($(ON_FPGA), y)
	ASFLAG += -DMACH_FPGA
else
   	ASFLAG += -DMACH_QEMU
endif

$(TARGET): interrupt.o
	$(LD) $< -T$(LDSCRIPT) -o $@

interrupt.o: interrupt.S
	$(CC) -o $@ $< -c -I$(INCLUDE) $(ASFLAG)

run: $(TARGET)
	$(QEMU) -M mipssim -m 8M -kernel $< -nographic

clean:
	rm interrupt.o interrupt.elf
