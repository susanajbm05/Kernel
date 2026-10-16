#ifndef MEMORY_H
#define MEMORY_H

typedef unsigned int size_t;

void memory_init(void);
void *kmalloc(size_t size);

#endif
