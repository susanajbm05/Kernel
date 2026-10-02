ENTRY(_start)

SECTIONS
{
    . = 1M;

    .text :
    {
<<<<<<< HEAD
        KEEP(*(.multiboot))
        *(.text*)
=======
        *(.multiboot)
        *(.text)
>>>>>>> f8cd8fc (Agrega nuevo archivo del kernel)
    }

    .rodata :
    {
<<<<<<< HEAD
        *(.rodata*)
=======
        *(.rodata)
>>>>>>> f8cd8fc (Agrega nuevo archivo del kernel)
    }

    .data :
    {
<<<<<<< HEAD
        *(.data*)
=======
        *(.data)
>>>>>>> f8cd8fc (Agrega nuevo archivo del kernel)
    }

    .bss :
    {
<<<<<<< HEAD
        *(COMMON)
        *(.bss*)
    }
}
=======
        *(.bss)
    }
}
>>>>>>> f8cd8fc (Agrega nuevo archivo del kernel)
