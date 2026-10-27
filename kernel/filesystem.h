#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#define FS_NAME_MAX 32
#define FS_MAX_NODES 32
#define FS_FILE_CONTENT_MAX 128

typedef enum {
    FS_DIRECTORY,
    FS_FILE
} fs_type_t;

typedef struct fs_node {
    char name[FS_NAME_MAX];
    fs_type_t type;
    struct fs_node *parent;
    struct fs_node *children[FS_MAX_NODES];
    unsigned int child_count;
    char content[FS_FILE_CONTENT_MAX];
} fs_node_t;

void fs_init(void);
fs_node_t *fs_root(void);
fs_node_t *fs_current(void);
int fs_cd(const char *path);
void fs_pwd(char *buffer, unsigned int size);
unsigned int fs_ls(char *buffer, unsigned int size);

#endif
