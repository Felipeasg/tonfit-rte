# extracted from https://github.com/torvalds/linux/blob/master/scripts/Lindent
LINDENT=indent -npro -kr -i8 -ts8 -sob -l80 -ss -ncs -cp1 -il0


LIBOPENCM3_DIR = /home/felipe/projects_study/automation/beremiz/related-projects/ioton_plc/libopencm3_stm32f4
MATIEC_C_INCLUDE_DIR=/home/felipe/projects_study/automation/beremiz/related-projects/ioton_plc/matiec/lib/C
ARM_GCC_TOOLCHAIN_DIR=/home/felipe/projects_study/automation/beremiz/related-projects/nucleron/gcc-arm-none-eabi-4_9-2015q3
STM32FLASH_DIR=/home/felipe/projects_study/automation/beremiz/related-projects/ioton_plc/stm32flash

# BUILD CONFIG 
LDSCRIPT = stm32f4disco-rte.ld

PREFIX	?= arm-none-eabi

CC		=  ${ARM_GCC_TOOLCHAIN_DIR}/bin/$(PREFIX)-gcc
LD		=  ${ARM_GCC_TOOLCHAIN_DIR}/bin/$(PREFIX)-g++
OBJCOPY	=  ${ARM_GCC_TOOLCHAIN_DIR}/bin/$(PREFIX)-objcopy
OBJDUMP =  ${ARM_GCC_TOOLCHAIN_DIR}/bin/$(PREFIX)-objdump
GDB		=  ${ARM_GCC_TOOLCHAIN_DIR}/bin/$(PREFIX)-gdb

BINARY = main

#CFLAGS		+= -Os -g -Wall -Wextra -I$(LIBOPENCM3_DIR)/include -I$(MATIEC_C_INCLUDE_DIR) -I./ \
		 -Wimplicit-function-declaration -Wundef -Wshadow \
		 -Wredundant-decls -Wmissing-prototypes -Wstrict-prototypes \
		 -fno-common -ffunction-sections -fdata-sections \
		 -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 \
		 -MD -DSTM32F4

# -g flag indicated in issue  #2 RTE (https://github.com/nucleron/RTE/issues/2) (maybe something related with ABI?)
CFLAGS += -g -mthumb \
		-std=gnu90 \
		-mcpu=cortex-m4 \
		-mfloat-abi=hard \
		-mfpu=fpv4-sp-d16 \
		-fmessage-length=0 \
		-fno-builtin \
		-fno-strict-aliasing \
		-ffunction-sections \
		-fdata-sections \
		-DSTM32F4 \
		-I$(LIBOPENCM3_DIR)/include \
		-I$(MATIEC_C_INCLUDE_DIR) \
		-I.

#LDFLAGS		+= -lc -s -lnosys -nostdlib -Wl,--gc-sections,-lgcc -L$(LIBOPENCM3_DIR)/lib \
			 -L$(LIBOPENCM3_DIR)/lib/stm32/f4 \
		   -T$(LDSCRIPT) -nostartfiles -Wl,--gc-sections \
		   -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16

LDFLAGS 	+= -mthumb \
			   -mcpu=cortex-m4 \
			   -mfloat-abi=hard \
               -nostdlib \
               -Xlinker \
               -Map=$(BINARY).map \
               -T$(LDSCRIPT) -Wl,--gc-sections,-lgcc \
			   -L$(LIBOPENCM3_DIR)/lib \
			   -L$(LIBOPENCM3_DIR)/lib/stm32/f4 \
			   -L$(ARM_GCC_TOOLCHAIN_DIR)/lib/gcc/arm-none-eabi/4.9.3/armv7e-m/fpu \
			   -s # issue #2 (https://github.com/nucleron/RTE/issues/2)
			   
OBJS		+= $(BINARY).o xprintf.o plc_libc.o plc_clock.o plc_wait_tmr.o plc_iom.o plc_backup.o plc_rtc.o plc_glue_rte.o plc_diag.o   plc_isr_stubs.o frac_div.o plc_tick.o plc_serial.o plc_app_default.o  plc_dbg.o  plc_gpio.o dbnc_flt.o  plc_hw.o  

#OBJS		+= $(BINARY).o 



.SUFFIXES: .elf .bin .hex .srec .list .images
.SECONDEXPANSION:
.SECONDARY:

all: images

images: $(BINARY).images

flash: $(BINARY).flash


%.images: %.bin %.hex %.srec %.list
	@echo "Success."

%.bin: %.elf
	$(OBJCOPY) -O binary $(*).elf $(*).bin

%.hex: %.elf
	$(OBJCOPY) -O ihex $(*).elf $(*).hex

%.srec: %.elf
	$(OBJCOPY) -O srec $(*).elf $(*).srec

%.list: %.elf
	$(OBJDUMP) -S $(*).elf > $(*).list

#%.elf: $(OBJS) $(LDSCRIPT) $(LIBOPENCM3_DIR)/lib/stm32/f4/libopencm3_stm32f4.a
#	$(LD) -o $(*).elf $(OBJS) -lopencm3_stm32f4 $(LDFLAGS)
%.elf: $(OBJS) $(LDSCRIPT)
	$(LD) -o $(*).elf $(OBJS) -lopencm3_stm32f4 $(LDFLAGS)

%.o: %.c Makefile
	$(CC) $(CFLAGS) -o $@ -c $<

$(LIBOPENCM3_DIR)/lib/stm32/f4/libopencm3_stm32f4.a : $(LIBOPENCM3_DIR)/Makefile
	$(MAKE) -C $(LIBOPENCM3_DIR) lib


clean:
	rm -f *.o *.d *.elf *.bin *.hex *.srec *.list
	#$(MAKE) -C $(LIBOPENCM3_DIR) clean

%.flash: %.bin
	st-flash write $< 0x8000000
	#$(STM32FLASH_DIR}/stm32flash -w $< -v -g 0x0 -S 0x08000000 /dev/ttyUSB0

.PHONY: images clean

-include $(OBJS:.o=.d)

flash_hex:

