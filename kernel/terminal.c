#include "terminal.h"

#define VGA_ADDRESS 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

static volatile char* video = (volatile char*) VGA_ADDRESS;
static int fila = 0;
static int columna = 0;
static unsigned char color = 0x0F;

void terminal_clear(void)
{
    for (int y = 0; y < VGA_HEIGHT; y++)
    {
        for (int x = 0; x < VGA_WIDTH; x++)
        {
            int posicion = (y * VGA_WIDTH + x) * 2;

            video[posicion] = ' ';
            video[posicion + 1] = color;
        }
    }

    fila = 0;
    columna = 0;
}

void terminal_newline(void)
{
    columna = 0;
    fila++;

    if (fila >= VGA_HEIGHT)
    {
        terminal_clear();
    }
}

void terminal_putchar(char c)
{
    if (c == '\n')
    {
        terminal_newline();
        return;
    }

    int posicion = (fila * VGA_WIDTH + columna) * 2;

    video[posicion] = c;
    video[posicion + 1] = color;

    columna++;

    if (columna >= VGA_WIDTH)
    {
        terminal_newline();
    }
}

void terminal_print(const char* texto)
{
    for (int i = 0; texto[i] != '\0'; i++)
    {
        terminal_putchar(texto[i]);
    }
}
