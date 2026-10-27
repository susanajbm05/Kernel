#include "serial.h"

#define COM1 0x3F8

static inline void outb(unsigned short port, unsigned char value)
{
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

static inline unsigned char inb(unsigned short port)
{
    unsigned char value;
    __asm__ volatile ("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

void serial_init(void)
{
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x80);
    outb(COM1 + 0, 0x03);
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x03);
    outb(COM1 + 2, 0xC7);
    outb(COM1 + 4, 0x0B);
}

static int serial_transmit_ready(void)
{
    unsigned int timeout = 1000000;

    while (timeout > 0)
    {
        if (inb(COM1 + 5) & 0x20)
            return 1;

        timeout--;
    }

    return 0;
}

void serial_putchar(char c)
{
    if (c == '\n' && serial_transmit_ready())
        outb(COM1, '\r');

    if (serial_transmit_ready())
        outb(COM1, (unsigned char)c);
}

char serial_getchar(void)
{
    static int previous_was_cr = 0;

    while ((inb(COM1 + 5) & 0x01) == 0)
    {
        __asm__ volatile ("pause");
    }

    char c = (char)inb(COM1);

    if (c == '\r')
    {
        previous_was_cr = 1;
        return '\n';
    }

    if (c == '\n')
    {
        if (previous_was_cr)
        {
            previous_was_cr = 0;
            return '\0';
        }
        return '\n';
    }

    previous_was_cr = 0;

    if (c == 127)
        return '\b';

    return c;
}
