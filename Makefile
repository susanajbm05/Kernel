# Kernel educativo de 32 bits

# Herramientas
AS      := nasm
CC      := gcc
LD      := ld
QEMU    := qemu-system-i386

# Opciones
ASFLAGS := -f elf32
CFLAGS  := -m32 -ffreestanding -fno-pie -fno-stack-protector \
           -nostdlib -O2 -Wall -Wextra -c
LDFLAGS := -m elf_i386 -T linker.ld -nostdlib

# Archivos
BUILD   := build
ISODIR  := $(BUILD)/isodir
OBJS := $(BUILD)/boot.o $(BUILD)/kernel.o $(BUILD)/terminal.o $(BUILD)/keyboard.o $(BUILD)/memory.o $(BUILD)/process.o $(BUILD)/task_demo.o
KERNEL  := $(BUILD)/kernel.bin
ISO     := $(BUILD)/kernel.iso

.PHONY: all iso run test clean

all: $(KERNEL)

# 1. boot.asm -> boot.o
$(BUILD)/boot.o: boot/boot.asm | $(BUILD)
	$(AS) $(ASFLAGS) $< -o $@

# 2. kernel.c -> kernel.o
$(BUILD)/kernel.o: kernel/kernel.c | $(BUILD)
	$(CC) $(CFLAGS) $< -o $@
$(BUILD)/terminal.o: kernel/terminal.c kernel/terminal.h | $(BUILD)
	$(CC) $(CFLAGS) kernel/terminal.c -o $@
$(BUILD)/keyboard.o: kernel/keyboard.c kernel/keyboard.h | $(BUILD)
	$(CC) $(CFLAGS) kernel/keyboard.c -o $@
$(BUILD)/memory.o: kernel/memory.c kernel/memory.h | $(BUILD)
	$(CC) $(CFLAGS) kernel/memory.c -o $@
$(BUILD)/process.o: kernel/process.c kernel/process.h | $(BUILD)
	$(CC) $(CFLAGS) kernel/process.c -o $@

$(BUILD)/task_demo.o: kernel/task_demo.c kernel/process.h | $(BUILD)
	$(CC) $(CFLAGS) kernel/task_demo.c -o $@

# 3-4. Enlazar -> kernel.bin
$(KERNEL): $(OBJS) linker.ld
	$(LD) $(LDFLAGS) $(OBJS) -o $@
	@grub-file --is-x86-multiboot $@ \
		&& echo "[OK] $@ es un kernel Multiboot valido" \
		|| (echo "[ERROR] $@ NO es Multiboot"; exit 1)

# 5-6. ISO booteable
iso: $(ISO)

$(ISO): $(KERNEL) iso/boot/grub/grub.cfg
	mkdir -p $(ISODIR)/boot/grub
	cp $(KERNEL) $(ISODIR)/boot/kernel.bin
	cp iso/boot/grub/grub.cfg $(ISODIR)/boot/grub/grub.cfg
	grub-mkrescue -o $@ $(ISODIR)

# 7. QEMU
run: $(ISO)
	$(QEMU) -no-reboot -no-shutdown -cdrom $< -boot d

# 8. Prueba de arranque
test: $(ISO)
	@./tests/boot_test.sh $(ISO)

$(BUILD):
	mkdir -p $@

clean:
	rm -rf $(BUILD)
