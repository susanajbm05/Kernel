#!/usr/bin/env bash

# ================================================================
# ONYX OS - KRN-007
# Validación de toolchain cruzada y herramientas temporales
# Linux From Scratch 13.1-systemd
# ================================================================

set -uo pipefail

LFS="${LFS:-/mnt/lfs}"
LFS_TGT="${LFS_TGT:-x86_64-lfs-linux-gnu}"

echo "========== VALIDACIÓN KRN-007 =========="
echo "Usuario: $(whoami)"
echo "LFS: $LFS"
echo "LFS_TGT: $LFS_TGT"

echo "========== TOOLCHAIN CRUZADA =========="

for compiler in gcc g++; do
    path="/tools/bin/$LFS_TGT-$compiler"

    if [[ -x "$path" ]]; then
        echo "DISPONIBLE: $path"
        "$path" --version | head -n 1
        "$path" -dumpmachine
    else
        echo "NO DISPONIBLE: $path"
    fi
done

echo "========== GCC PASS 2 =========="

for compiler in gcc g++; do
    for path in \
        "$LFS/usr/bin/$compiler" \
        "$LFS/mnt/lfs/usr/bin/$compiler"
    do
        if [[ -x "$path" ]]; then
            echo "DISPONIBLE: $path"
            "$path" --version | head -n 1
        else
            echo "NO DISPONIBLE: $path"
        fi
    done
done

echo "========== BIBLIOTECAS =========="

find "$LFS/usr/lib" "$LFS/usr/lib64" \
    -maxdepth 3 \
    \( -name 'libgcc_s.so*' -o -name 'libstdc++.so*' \) \
    -print 2>/dev/null

echo "========== HERRAMIENTAS =========="

check_tool() {
    local tool="$1"
    shift

    local found=0

    for path in "$@"; do
        if [[ -x "$path" ]]; then
            echo "DISPONIBLE: $tool ($path)"
            found=1
        fi
    done

    if [[ "$found" -eq 0 ]]; then
        echo "REVISAR: $tool"
    fi
}

check_tool "M4" /tools/bin/m4
check_tool "Ncurses" "$LFS/usr/bin/tic" /tools/bin/tic
check_tool "Bash" "$LFS/usr/bin/bash"
check_tool "Coreutils" "$LFS/usr/bin/cat" "$LFS/usr/bin/cp"
check_tool "Diffutils" "$LFS/usr/bin/diff"
check_tool "File" "$LFS/usr/bin/file"
check_tool "Findutils" "$LFS/usr/bin/find"
check_tool "Gawk" /tools/bin/gawk "$LFS/usr/bin/gawk"
check_tool "Grep" "$LFS/usr/bin/grep"
check_tool "Gzip" "$LFS/usr/bin/gzip"
check_tool "Make" "$LFS/usr/bin/make"
check_tool "Patch" "$LFS/usr/bin/patch"
check_tool "Sed" "$LFS/usr/bin/sed"
check_tool "Tar" "$LFS/usr/bin/tar"
check_tool "Xz" "$LFS/usr/bin/xz"

echo "========== FIN DE VALIDACIÓN =========="
