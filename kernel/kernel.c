
#include "memory.h"
#include "terminal.h"
#include "process.h"
#include "filesystem.h"

void task_demo(void);

static int command_equals(const char *text, const char *command)
{
    int i = 0;

    while (text[i] != '\0' && command[i] != '\0')
    {
        if (text[i] != command[i])
        {
            return 0;
        }

        i++;
    }

    return text[i] == '\0' && command[i] == '\0';
}

static void command_help(void)
{
    terminal_print("Comandos disponibles:\n");
    terminal_print(" help  - Lista de comandos\n");
    terminal_print(" about - Informacion de ONYX OS\n");
    terminal_print(" clear - Limpiar pantalla\n");
    terminal_print(" mem   - Estado del asignador de memoria\n");
    terminal_print(" tasks - Demostracion de procesos\n");
    terminal_print(" ls    - Listar contenido del directorio\n");
    terminal_print(" pwd   - Mostrar directorio actual\n");
    terminal_print(" cd    - Cambiar de directorio (cd home, cd ..)\n");
}

static void command_ls(void)
{
    char contenido[512];

    fs_ls(contenido, sizeof(contenido));
    terminal_print(contenido);
}

static void command_pwd(void)
{
    char ruta[128];

    fs_pwd(ruta, sizeof(ruta));
    terminal_print(ruta);
    terminal_print("\n");
}

static void command_about(void)
{
    terminal_print("ONYX OS\n");
    terminal_print("Kernel educativo de 32 bits.\n");
    terminal_print("Proyecto de Ingenieria en Ciencias de la Computacion.\n");
}

static void command_mem(void)
{
    void *test = kmalloc(16);

    if (test != 0)
    {
        terminal_print("Asignador de memoria: funcionando.\n");
        terminal_print("Prueba de reserva de 16 bytes: correcta.\n");
    }
    else
    {
        terminal_print("Error al reservar memoria.\n");
    }
}

static void command_tasks(void)
{
    int task_id = process_create(task_demo);

    if (task_id < 0)
    {
        terminal_print("No se pudo crear la tarea.\n");
        return;
    }

    if (process_execute((unsigned int)task_id) == 0)
    {
        terminal_print("Tarea ejecutada correctamente.\n");
    }
    else
    {
        terminal_print("Error al ejecutar la tarea.\n");
    }
}

static void command_cd(const char *path)
{
    if (path[0] == '\0')
    {
        terminal_print("Uso: cd <directorio>\n");
        return;
    }

    if (fs_cd(path) == 0)
    {
        terminal_print("Directorio cambiado correctamente.\n");
    }
    else
    {
        terminal_print("Directorio no encontrado.\n");
    }
}

static void execute_command(const char *command)
{
    if (command[0] == 'c' && command[1] == 'd' && command[2] == ' ')
    {
        command_cd(command + 3);
    }
    else if (command_equals(command, "cd"))
    {
        terminal_print("Uso: cd <directorio>\\n");
    }
    else if (command_equals(command, "help"))
    {
        command_help();
    }
    else if (command_equals(command, "about"))
    {
        command_about();
    }
    else if (command_equals(command, "clear"))
    {
        terminal_clear();
    }
    else if (command_equals(command, "ls"))
    {
        command_ls();
    }
    else if (command_equals(command, "pwd"))
    {
        command_pwd();
    }
    else if (command_equals(command, "mem"))
    {
        command_mem();
    }
    else if (command_equals(command, "tasks"))
    {
        command_tasks();
    }
    else if (command_equals(command, ""))
    {
        /* No hacer nada si se presiona Enter sin escribir. */
    }
    else
    {
        terminal_print("Comando desconocido. Escribi help.\n");
    }
}

void kernel_main(void)
{
    char entrada[64];

    terminal_clear();
    memory_init();
    process_init();

    terminal_print("ONYX OS - Terminal interactiva\n");
    terminal_print("Escribi help para ver los comandos.\n\n");

    while (1)
    {
        terminal_print("onyx> ");
        terminal_readline(entrada, sizeof(entrada));
        execute_command(entrada);
    }
}

