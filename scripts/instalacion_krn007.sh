#!/usr/bin/env bash

# ============================================================
# ONYX OS - KRN-007
# Instalación de toolchain cruzada y herramientas temporales
# Basado en Linux From Scratch 13.1-systemd
# Arquitectura: x86_64
# ============================================================

set -Eeuo pipefail

# Variables principales
LFS="${LFS:-/mnt/lfs}"
LFS_TGT="${LFS_TGT:-x86_64-lfs-linux-gnu}"
JOBS="${JOBS:-2}"

# Registro de ejecución
LOG_DIR="${LFS}/var/log"
LOG_FILE="${LOG_DIR}/krn007-instalacion.log"

# ------------------------------------------------------------
# 1. Comprobaciones previas
# ------------------------------------------------------------

error() {
    echo "ERROR: $*" >&2
    exit 1
}

if [[ "$(id -un)" != "lfs" ]]; then
    error "Ejecuta este script como usuario lfs."
fi

if [[ ! -d "$LFS" ]] || ! mountpoint -q "$LFS"; then
    error "$LFS no está montado. Comprueba la partición LFS."
fi

[[ -d "$LFS/sources" ]] || error "No existe $LFS/sources"
[[ -d "$LFS/tools" ]] || error "No existe $LFS/tools"

for package in \
    binutils-2.47 \
    gcc-16.2.0 \
    glibc-2.44 \
    m4-1.4.21 \
    ncurses-6.5 \
    bash-5.3 \
    coreutils-9.11 \
    diffutils-3.12 \
    file-5.48 \
    findutils-4.11.0 \
    gawk-5.4.1 \
    grep-3.12 \
    gzip-1.14 \
    make-4.4.1 \
    patch-2.7.6 \
    sed-4.9 \
    tar-1.35 \
    xz-5.8.1
do
    [[ -d "$LFS/sources/$package" ]] ||
        error "No se encuentra la fuente: $package"
done

mkdir -p "$LOG_DIR"

echo "Comprobaciones iniciales completadas."
echo "LFS: $LFS"
echo "LFS_TGT: $LFS_TGT"
echo "Trabajos paralelos: $JOBS"
echo "Registro: $LOG_FILE"

# ------------------------------------------------------------
# 2. Configuración del entorno LFS
# ------------------------------------------------------------

export LFS
export LFS_TGT
export PATH="/tools/bin:/usr/bin"
export CONFIG_SITE="$LFS/usr/share/config.site"

cd "$LFS/sources"

echo "Entorno de compilación configurado."
echo "PATH=$PATH"

