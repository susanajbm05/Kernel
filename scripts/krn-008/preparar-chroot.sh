#!/usr/bin/env bash
set -Eeuo pipefail

LFS="${LFS:-/mnt/lfs}"
MODO="${1:---check}"

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

if [[ "$EUID" -ne 0 ]]; then
    error "Ejecuta el script con sudo."
fi

if [[ ! -d "$LFS" ]]; then
    error "No existe la raíz LFS: $LFS"
fi

if findmnt -n -o OPTIONS --target "$LFS" | grep -qw ro; then
    error "La raíz LFS está montada en solo lectura."
fi

requisitos=(
    "usr/bin/bash"
    "usr/bin/env"
    "tools/bin/bash"
    "tools/bin/gcc"
    "tools/bin/ld"
    "tools/bin/as"
)

echo "======================================"
echo " KRN-008 - Verificación del entorno"
echo " Raíz LFS: $LFS"
echo "======================================"

fallos=0

for archivo in "${requisitos[@]}"; do
    if [[ -x "$LFS/$archivo" ]]; then
        echo "[OK] $archivo"
    else
        echo "[FALTA] $archivo"
        fallos=$((fallos + 1))
    fi
done

if [[ ! -d "$LFS/usr/lib" ]]; then
    echo "[FALTA] usr/lib"
    fallos=$((fallos + 1))
else
    echo "[OK] usr/lib"
fi

if (( fallos > 0 )); then
    error "Hay $fallos requisitos pendientes. No se preparará el Chroot."
fi

echo "[OK] Requisitos básicos encontrados."

if [[ "$MODO" == "--check" ]]; then
    echo "Verificación terminada. No se realizaron montajes."
    exit 0
fi

if [[ "$MODO" != "--mount" && "$MODO" != "--chroot" ]]; then
    error "Uso: sudo LFS=/ruta/lfs $0 [--check|--mount|--chroot]"
fi

if [[ ! -w "$LFS" ]]; then
    error "La raíz LFS no permite escritura."
fi

montar() {
    local origen="$1"
    local destino="$2"
    local tipo="${3:-}"

    mkdir -p "$destino"

    if mountpoint -q "$destino"; then
        echo "[YA MONTADO] $destino"
    elif [[ -n "$tipo" ]]; then
        mount -t "$tipo" "$origen" "$destino"
        echo "[MONTADO] $destino"
    else
        mount --bind "$origen" "$destino"
        echo "[MONTADO] $destino"
    fi
}

montar /dev "$LFS/dev"
montar /dev/pts "$LFS/dev/pts"
montar proc "$LFS/proc" proc
montar sysfs "$LFS/sys" sysfs
montar tmpfs "$LFS/run" tmpfs

echo "[OK] Preparación de montajes completada."

if [[ "$MODO" == "--chroot" ]]; then
    echo "Entrando al entorno LFS. Para salir, escribe: exit"
    chroot "$LFS" /usr/bin/env -i \
        HOME=/root \
        TERM="${TERM:-linux}" \
        PS1='(lfs chroot) \u:\w\$ ' \
        PATH=/usr/bin:/usr/sbin:/tools/bin \
        /bin/bash --login
fi
