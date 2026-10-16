#include "process.h"

void task_demo(void)
{
volatile char *video = (volatile char *) 0xB8000;
const char *message = "Tarea ejecutada correctamente (Parte de procesos y tareas)";

int position = 320;

for (int i = 0; message[i] != '\0'; i++) {
video[position + i * 2] = message[i];

video[position + i * 2 + 1] = 0x0F;
       }
}
