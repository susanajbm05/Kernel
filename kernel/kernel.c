#include "memory.h"
#include "terminal.h"
#include "process.h"

void task_demo(void);

void kernel_main(void)
{
    terminal_clear();
    memory_init();
    terminal_print("HOLI USUARIO\n");
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

    while (1)
    {
        __asm__ volatile ("hlt");
    }
}

