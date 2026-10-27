#include "process.h"

static process_t
processes[MAX_PROCESSES];
static unsigned int next_id = 1;


void process_init(void)
{
      for(unsigned int i = 0; i < MAX_PROCESSES; i++) {
        processes[i].id = 0;
        processes[i].state = PROCESS_FREE;
        processes[i].entry = 0;
}

     next_id = 1;
     
}

int process_create(process_entry_t entry)
{
      if (entry == 0) {
           return -1;
          }

      for (unsigned int i = 0; i < MAX_PROCESSES; i++) {
              if  (processes[i].state == PROCESS_FREE ||
                   processes[i].state == PROCESS_TERMINATED) {
                        processes[i].id = next_id++;
                        processes[i].state = PROCESS_READY;
                        processes[i].entry = entry;
                        

                        return
                   (int)processes[i].id;
                   }
               }
    return -1;
}

const process_t *process_get(unsigned int id)
{
       for (unsigned int i = 0; i < MAX_PROCESSES; i++) {
         if (processes[i].id == id && processes[i].state != PROCESS_FREE) {
                 return &processes[i];
           }
       }
return 0;
}

unsigned int process_count(void)
{
unsigned int count = 0;

    for (unsigned int i = 0; i < MAX_PROCESSES; i++) {
        if (processes[i].state == PROCESS_READY ||
            processes[i].state == PROCESS_RUNNING ||
            processes[i].state == PROCESS_BLOCKED) {
            count++;
        }
    }

    return count;
}

int process_execute(unsigned int id)
{
   for (unsigned int i = 0; i < MAX_PROCESSES; i++) {
      if (processes[i].id == id && processes[i].state == PROCESS_READY) {
processes[i].state = PROCESS_RUNNING;
processes[i].entry();
processes[i].state = PROCESS_TERMINATED;

    return 0;
        }
    }
return -1;
}
