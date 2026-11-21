#!/usr/bin/env bash

# ================================================================
# ONYX OS - KRN-007
# Validacion de toolchain cruzada y herramientas temporales
# Linux From Scratch 13.1-systemd
# ================================================================

set -uo pipefail

LFS="${LFS:-/mnt/lfs}"
LFS_TGT="${LFS_TGT:-x86_64-lfs-linux-gnu}"

FALLAS=0

check_tool() {
    local name="$1"
    shift
    local missing=0

    for path in "$@"; do
        if [[ ! -x "$path" ]]; then
            missing=1
            echo "  FALTA: $path"
        fi
    done

    if [[ "$missing" -eq 0 ]]; then
        echo "[OK] $name"
    else
        echo "[ERROR] $name"
        FALLAS=$((FALLAS + 1))
    fi
}

echo "================================================"
echo "          VALIDACION KRN-007 - ONYX OS"
echo "================================================"
echo "LFS: $LFS"
echo "LFS_TGT: $LFS_TGT"

# Entorno LFS
echo
echo "===== ENTORNO LFS ====="

if mountpoint -q "$LFS"; then
    echo "[OK] Particion LFS montada"
else
    echo "[ERROR] Particion LFS no montada"
    FALLAS=$((FALLAS + 1))
fi

check_tool "Estructura LFS" \
    "$LFS/usr/bin/bash" \
    "$LFS/usr/lib"

# Toolchain cruzada
echo
echo "===== TOOLCHAIN CRUZADA ====="

for tool in gcc g++ ld as; do
    check_tool "$LFS_TGT-$tool" "/tools/bin/$LFS_TGT-$tool"
done

/tools/bin/$LFS_TGT-gcc --version 2>/dev/null | head -n 1
/tools/bin/$LFS_TGT-g++ --version 2>/dev/null | head -n 1

# GCC Pass 2
echo
echo "===== GCC PASS 2 ====="

check_tool "GCC Pass 2" \
    "$LFS/usr/bin/gcc" \
    "$LFS/usr/bin/g++"

if [[ -x "$LFS/usr/bin/gcc" ]]; then
    "$LFS/usr/bin/gcc" --version | head -n 1
fi

if [[ -x "$LFS/usr/bin/g++" ]]; then
    "$LFS/usr/bin/g++" --version | head -n 1
fi

# Bibliotecas
echo
echo "===== BIBLIOTECAS ====="

for library in libgcc_s.so libstdc++.so; do
    if find "$LFS/usr/lib" -maxdepth 1 \
        -name "$library*" -print -quit 2>/dev/null | grep -q .; then
        echo "[OK] $library"
    else
        echo "[ERROR] Falta $library"
        FALLAS=$((FALLAS + 1))
    fi
done

# Herramientas temporales
echo
echo "===== HERRAMIENTAS KRN-007 ====="

check_tool "M4" /tools/bin/m4
check_tool "Ncurses" "$LFS/usr/bin/tic"
check_tool "Bash" "$LFS/usr/bin/bash"
check_tool "Coreutils" "$LFS/usr/bin/cat" "$LFS/usr/bin/cp"
check_tool "Diffutils" "$LFS/usr/bin/diff"
check_tool "File" "$LFS/usr/bin/file"
check_tool "Findutils" "$LFS/usr/bin/find"
check_tool "Gawk" /tools/bin/gawk
check_tool "Grep" "$LFS/usr/bin/grep"
check_tool "Gzip" "$LFS/usr/bin/gzip"
check_tool "Make" "$LFS/usr/bin/make"
check_tool "Patch" "$LFS/usr/bin/patch"
check_tool "Sed" "$LFS/usr/bin/sed"
check_tool "Tar" "$LFS/usr/bin/tar"
check_tool "Xz" "$LFS/usr/bin/xz"
check_tool "Binutils Pass 2" \
    "$LFS/usr/bin/ld" \
    "$LFS/usr/bin/as" \
    "$LFS/usr/bin/ar"

echo
echo "===== RESULTADO FINAL ====="

if [[ "$FALLAS" -eq 0 ]]; then
    echo "VALIDACION KRN-007 COMPLETADA"
    echo "Todas las comprobaciones fueron satisfactorias."
else
    echo "VALIDACION KRN-007 CON OBSERVACIONES"
    echo "Comprobaciones fallidas: $FALLAS"
fi

exit "$FALLAS"
