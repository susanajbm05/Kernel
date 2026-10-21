#include "memory.h"
#include "terminal.h"
#include "process.h"

void task_demo(void);

void kernel_main(void)
{
    char entrada[64];

    terminal_clear();
    memory_init();

    terminal_print("ONYX OS - Prueba de teclado\n");
    terminal_print("Kernel iniciado correctamente.\n");

    process_init();

    int task_id = process_create(task_demo);

    if (task_id > 0) {
        if (process_execute((unsigned int)task_id) == 0) {
            terminal_print("Tarea ejecutada correctamente.\n");
        } else {
            terminal_print("Error al ejecutar la tarea.\n");
        }
    } else {
        terminal_print("Error al crear la tarea.\n");
    }

    terminal_print("\nEscribi algo y presiona ENTER: ");
    terminal_readline(entrada, sizeof(entrada));

    terminal_print("Recibido: ");
    terminal_print(entrada);
    terminal_print("\nPrueba finalizada.\n");

    while (1)
    {
        __asm__ volatile ("hlt");
    }
}
