#ifndef PROCESS_H
#define PROCESS_H

#define MAX_PROCESSES 8

typedef enum {
PROCESS_FREE,
PROCESS_READY,
PROCESS_RUNNING,
PROCESS_BLOCKED,
PROCESS_TERMINATED
} process_state_t;

typedef void (*process_entry_t)(void);

typedef struct {
unsigned int id;
process_state_t state;
process_entry_t entry;
} process_t;

void process_init(void);
int process_create(process_entry_t entry);
const process_t *process_get(unsigned int id);
unsigned int process_count(void);

int process_execute(unsigned int id);

#endif
