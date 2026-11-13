#!/usr/bin/env bash

set -u
export LC_ALL=C

# Guardar automaticamente cada ejecucion como evidencia.
if [[ "${LFS_HOST_CHECK_LOGGED:-0}" != "1" ]]; then
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
    LOG_FILE="$REPO_ROOT/docs/lfs/host-check-ejecucion.txt"

    mkdir -p "$REPO_ROOT/docs/lfs"
    (cd "$REPO_ROOT" && LFS_HOST_CHECK_LOGGED=1 bash "$SCRIPT_DIR/lfs-host-check.sh" "$@") 2>&1 | tee "$LOG_FILE"
    RESULT=${PIPESTATUS[0]}
    exit "$RESULT"
fi

ERRORS=0
WARNINGS=0

ok() {
    printf '[OK] %s\n' "$1"
}

error() {
    printf '[ERROR] %s\n' "$1"
    ERRORS=$((ERRORS + 1))
}

warning() {
    printf '[OBSERVACION] %s\n' "$1"
    WARNINGS=$((WARNINGS + 1))
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        ok "$1: $(command -v "$1")"
    else
        error "No se encuentra $1"
    fi
}

echo "=========================================="
echo " ONYX OS - VALIDACION DEL HOST LFS 13.1"
echo "=========================================="

echo
echo "===== SISTEMA ANFITRION ====="
uname -a
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Distribucion: $PRETTY_NAME"
fi
echo "Arquitectura: $(uname -m)"

echo
echo "===== HERRAMIENTAS LFS ====="

tools=(
    bash bison bzip2 diff find gawk gcc g++ grep gzip
    ld m4 make patch perl python3 sed tar makeinfo xz
    chown
)

for tool in "${tools[@]}"; do
    check_command "$tool"
done

echo
echo "===== ENLACES SIMBOLICOS ====="

SH_TARGET=$(readlink -f /bin/sh 2>/dev/null || true)
echo "/bin/sh -> ${SH_TARGET:-NO ENCONTRADO}"

if [[ "$SH_TARGET" == *bash ]]; then
    ok "/bin/sh apunta a Bash"
else
    error "/bin/sh no apunta a Bash"
    warning "Bash esta instalado en /bin/bash; no se modifico el enlace del sistema anfitrion"
fi

AWK_TARGET=$(readlink -f /usr/bin/awk 2>/dev/null || true)
echo "/usr/bin/awk -> ${AWK_TARGET:-NO ENCONTRADO}"

if [[ "$AWK_TARGET" == *gawk ]]; then
    ok "awk apunta a Gawk"
else
    error "awk no apunta a Gawk"
fi

YACC_TARGET=$(readlink -f /usr/bin/yacc 2>/dev/null || true)
echo "/usr/bin/yacc -> ${YACC_TARGET:-NO ENCONTRADO}"

if command -v yacc >/dev/null 2>&1; then
    if yacc --version 2>&1 | grep -qi bison; then
        ok "yacc ejecuta Bison"
    else
        warning "yacc existe, pero debe verificarse que ejecute Bison"
    fi
else
    error "No se encuentra yacc"
fi

echo
echo "===== VERSIONES PRINCIPALES ====="

for tool in bash bison gcc g++ ld make gawk m4 perl python3 \
            sed tar makeinfo xz bzip2 diff find grep gzip; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf '%-12s ' "$tool"

        if [ "$tool" = "perl" ]; then
            perl -e 'print "Perl $^V\n"'
        else
            "$tool" --version 2>&1 | head -n 1
        fi
    fi
done

echo
echo "===== KERNEL ====="
KERNEL_VERSION=$(uname -r | cut -d- -f1)
echo "Version: $(uname -r)"

if printf '%s\n' "5.10" "$KERNEL_VERSION" |
    sort -V -C; then
    ok "Kernel igual o superior a 5.10"
else
    error "Kernel inferior a 5.10"
fi

echo
echo "===== SOPORTE PTY ====="
if mount | grep -q 'devpts'; then
    ok "Sistema de archivos devpts montado"
else
    error "No se detecta devpts montado"
fi

if [ -c /dev/ptmx ]; then
    ok "/dev/ptmx existe como dispositivo"
else
    error "/dev/ptmx no está disponible"
fi

echo
echo "===== PRUEBA DE COMPILACION C++ ====="

TMP_SOURCE=$(mktemp)
TMP_BINARY=$(mktemp)
printf 'int main() { return 0; }\n' > "$TMP_SOURCE"

if g++ -x c++ "$TMP_SOURCE" -o "$TMP_BINARY" 2>/dev/null; then
    ok "G++ compila un programa de prueba"
else
    error "G++ no pudo compilar el programa de prueba"
fi

rm -f "$TMP_SOURCE" "$TMP_BINARY"

echo
echo "===== PRUEBA DE COMPILACION DE 32 BITS ====="

TMP_DIR=$(mktemp -d)
printf 'void kernel_test(void) {}\n' > "$TMP_DIR/test.c"

if gcc -m32 -ffreestanding -fno-pie -c "$TMP_DIR/test.c" -o "$TMP_DIR/test.o"; then
    ok "GCC genera correctamente un objeto ELF de 32 bits"
    file "$TMP_DIR/test.o"
else
    error "GCC no pudo generar un objeto de 32 bits"
fi

rm -rf "$TMP_DIR"

echo
echo "===== RECURSOS DEL ANFITRION ====="
echo "Procesadores: $(nproc)"
free -h

echo
echo "===== ESPACIO DISPONIBLE EN DISCO ====="
df -h "$HOME"

if [ "$(nproc)" -lt 4 ]; then
    warning "Menos de 4 nucleos: la compilacion puede tardar mas"
fi

TOTAL_RAM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
if [ "$TOTAL_RAM_KB" -lt 8388608 ]; then
    warning "Menos de 8 GB de RAM: la compilacion puede tardar mas"
fi

echo
echo "=========================================="
echo " RESULTADO DE VALIDACION"
echo "Errores: $ERRORS"
echo "Observaciones: $WARNINGS"

if [ "$ERRORS" -eq 0 ]; then
    echo "RESULTADO: REQUISITOS TECNICOS DETECTADOS"
else
    echo "RESULTADO: VALIDACION CON INCUMPLIMIENTOS"
fi

echo "=========================================="

exit "$ERRORS"
