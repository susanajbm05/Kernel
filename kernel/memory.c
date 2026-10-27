
#include "memory.h"

extern unsigned int kernel_end;

#define HEAP_LIMIT 0x00400000

static unsigned int heap_current;
static unsigned int heap_limit = HEAP_LIMIT;

void memory_init(void)
{
    heap_current = ((unsigned int)&kernel_end + 3) & ~3U;
}

void *kmalloc(size_t size)
{
    unsigned int address;
    unsigned int aligned_size;

    if (size == 0)
        return (void *)0;

    address = heap_current;

    if (address >= heap_limit || size > heap_limit - address)
        return (void *)0;

    if (size > 0xFFFFFFFCU)
        return (void *)0;

    aligned_size = (size + 3U) & ~3U;

    if (aligned_size > heap_limit - address)
        return (void *)0;

    heap_current += aligned_size;

    return (void *)address;
}


