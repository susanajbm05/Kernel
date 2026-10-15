#include "terminal.h"

void kernel_main(void)
{
    terminal_clear();
    terminal_print("HOLI USUARIO\n");
    terminal_print("Kernel iniciado correctamente.\n");

    while (1)
    {
        __asm__ volatile ("hlt");
    }
}
