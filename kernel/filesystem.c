#include "filesystem.h"

static fs_node_t nodes[FS_MAX_NODES];
static unsigned int nodes_used = 0;
static fs_node_t *root = 0;
static fs_node_t *current = 0;

static int fs_name_equal(const char *a, const char *b)
{
    unsigned int i = 0;

    while (a[i] != '\0' && b[i] != '\0') {
        if (a[i] != b[i]) {
            return 0;
        }

        i++;
    }

    return a[i] == b[i];
}

static void fs_copy_name(char *dest, const char *src)
{
    unsigned int i = 0;

    while (i < FS_NAME_MAX - 1 && src[i] != '\0') {
        dest[i] = src[i];
        i++;
    }

    dest[i] = '\0';
}

static fs_node_t *fs_create(
    fs_node_t *parent,
    const char *name,
    fs_type_t type)
{
    fs_node_t *node;
    unsigned int i;

    if (nodes_used >= FS_MAX_NODES) {
        return 0;
    }

    if (parent != 0 && parent->child_count >= FS_MAX_NODES) {
        return 0;
    }

    if (parent != 0) {
        for (i = 0; i < parent->child_count; i++) {
            if (fs_name_equal(parent->children[i]->name, name)) {
                return 0;
            }
        }
    }

    node = &nodes[nodes_used++];

    fs_copy_name(node->name, name);
    node->type = type;
    node->parent = parent;
    node->child_count = 0;
    node->content[0] = '\0';

    for (i = 0; i < FS_MAX_NODES; i++) {
        node->children[i] = 0;
    }

    if (parent != 0) {
        parent->children[parent->child_count++] = node;
    }

    return node;
}

void fs_init(void)
{
    fs_node_t *home;

    nodes_used = 0;
    root = 0;
    current = 0;

    root = fs_create(0, "/", FS_DIRECTORY);

    if (root == 0) {
        return;
    }

    home = fs_create(root, "home", FS_DIRECTORY);
    fs_create(root, "bin", FS_DIRECTORY);
    fs_create(root, "etc", FS_DIRECTORY);
    fs_create(root, "tmp", FS_DIRECTORY);

    if (home != 0) {
        fs_create(home, "documentos", FS_DIRECTORY);
        fs_create(home, "notas.txt", FS_FILE);
    }

    current = root;
}

fs_node_t *fs_root(void)
{
    return root;
}

fs_node_t *fs_current(void)
{
    return current;
}

static fs_node_t *fs_find_child(fs_node_t *parent, const char *name)
{
    unsigned int i;

    if (parent == 0 || parent->type != FS_DIRECTORY) {
        return 0;
    }

    for (i = 0; i < parent->child_count; i++) {
        if (fs_name_equal(parent->children[i]->name, name)) {
            return parent->children[i];
        }
    }

    return 0;
}

int fs_cd(const char *path)
{
    fs_node_t *target;
    const char *start;
    unsigned int length;
    char component[FS_NAME_MAX];

    if (path == 0 || path[0] == '\0' || current == 0) {
        return 0;
    }

    target = (path[0] == '/') ? root : current;
    start = path;

    while (*start != '\0') {
        while (*start == '/') {
            start++;
        }

        if (*start == '\0') {
            break;
        }

        length = 0;

        while (start[length] != '\0' && start[length] != '/') {
            if (length >= FS_NAME_MAX - 1) {
                return 0;
            }

            component[length] = start[length];
            length++;
        }

        component[length] = '\0';
        start += length;

        if (fs_name_equal(component, ".")) {
            continue;
        }

        if (fs_name_equal(component, "..")) {
            if (target->parent != 0) {
                target = target->parent;
            }

            continue;
        }

        target = fs_find_child(target, component);

        if (target == 0 || target->type != FS_DIRECTORY) {
            return 0;
        }
    }

    current = target;
    return 1;
}

static int fs_append(
    char *buffer,
    unsigned int size,
    unsigned int *position,
    const char *text)
{
    unsigned int i = 0;

    if (buffer == 0 || position == 0 || text == 0 || size == 0) {
        return 0;
    }

    while (text[i] != '\0') {
        if (*position >= size - 1) {
            buffer[*position] = '\0';
            return 0;
        }

        buffer[(*position)++] = text[i++];
    }

    buffer[*position] = '\0';
    return 1;
}

void fs_pwd(char *buffer, unsigned int size)
{
    fs_node_t *path_nodes[FS_MAX_NODES];
    fs_node_t *node;
    unsigned int count = 0;
    unsigned int position = 0;
    unsigned int i;

    if (buffer == 0 || size == 0) {
        return;
    }

    buffer[0] = '\0';
    node = current;

    while (node != 0 && count < FS_MAX_NODES) {
        path_nodes[count++] = node;
        node = node->parent;
    }

    if (count == 0) {
        fs_append(buffer, size, &position, "/");
        return;
    }

    for (i = count; i > 0; i--) {
        if (path_nodes[i - 1] == root) {
            continue;
        }

        if (!fs_append(buffer, size, &position, "/")) {
            return;
        }

        if (!fs_append(
                buffer,
                size,
                &position,
                path_nodes[i - 1]->name)) {
            return;
        }
    }

    if (position == 0) {
        fs_append(buffer, size, &position, "/");
    }
}

unsigned int fs_ls(char *buffer, unsigned int size)
{
    unsigned int position = 0;
    unsigned int i;

    if (buffer == 0 || size == 0) {
        return 0;
    }

    buffer[0] = '\0';

    if (current == 0 || current->type != FS_DIRECTORY) {
        return 0;
    }

    for (i = 0; i < current->child_count; i++) {
        fs_node_t *child = current->children[i];
        unsigned int j = 0;

        while (child->name[j] != '\0') {
            if (position >= size - 1) {
                buffer[position] = '\0';
                return position;
            }

            buffer[position++] = child->name[j++];
        }

        if (child->type == FS_DIRECTORY) {
            if (position >= size - 1) {
                buffer[position] = '\0';
                return position;
            }

            buffer[position++] = '/';
        }

        if (position >= size - 1) {
            buffer[position] = '\0';
            return position;
        }

        buffer[position++] = '\n';
    }

    buffer[position] = '\0';
    return position;
}

int fs_mkdir(const char *name)
{
    unsigned int i;

    if (name == 0 || name[0] == '\0' || current == 0) {
        return 0;
    }

    if (current->type != FS_DIRECTORY) {
        return 0;
    }

    if (name[0] == '/') {
        return 0;
    }

    for (i = 0; name[i] != '\0'; i++) {
        if (i >= FS_NAME_MAX - 1 || name[i] == '/') {
            return 0;
        }
    }

    if (fs_name_equal(name, ".") ||
        fs_name_equal(name, "..")) {
        return 0;
    }

    if (fs_find_child(current, name) != 0) {
        return 0;
    }

    return fs_create(current, name, FS_DIRECTORY) != 0;
}

int fs_cat(const char *name, char *buffer, unsigned int size)
{
    fs_node_t *node;
    unsigned int i = 0;

    if (name == 0 || buffer == 0 || size == 0 || current == 0) {
        return 0;
    }

    node = fs_find_child(current, name);

    if (node == 0 || node->type != FS_FILE) {
        return 0;
    }

    while (node->content[i] != '\0' && i < size - 1) {
        buffer[i] = node->content[i];
        i++;
    }

    buffer[i] = '\0';
    return 1;
}
