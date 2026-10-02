
# Kernel

## Proceso de arranque

El kernel utiliza GRUB y el estándar Multiboot 1.

El flujo de arranque es:

GRUB → kernel.elf → _start → kernel_main

## boot.asm

- `bits 32`: indica que el código es de 32 bits.
- `.multiboot`: contiene la cabecera que GRUB utiliza para reconocer el kernel.
- `0x1BADB002`: magic number de Multiboot 1.
- `.bss`: reserva la memoria para el stack.
- `_start`: punto de entrada del kernel.
- `cli`: deshabilita las interrupciones.
- `mov esp, stack_top`: configura el stack.
- `call kernel_main`: pasa la ejecución al código en C.
- `hlt`: detiene el procesador en caso de que `kernel_main` retorne.

## Requisitos para GRUB

Para que GRUB cargue el kernel se necesita:

- Una cabecera Multiboot válida.
- Un kernel ELF de 32 bits.
- Un punto de entrada `_start`.
- Un linker script que coloque correctamente la sección `.multiboot`.
- Un archivo `grub.cfg`.

## Compilación

```bash
nasm -f elf32 boot/boot.asm -o boot.o
gcc -m32 -ffreestanding -fno-pie -fno-stack-protector -c kernel/kernel.c -o kernel.o
ld -m elf_i386 -T linker.ld -o kernel.elf boot.o kernel.o
