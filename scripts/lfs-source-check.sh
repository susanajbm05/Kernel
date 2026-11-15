#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
DOC_DIR="$ROOT_DIR/docs/lfs/krn-005"
SOURCE_DIR="${LFS_SOURCE_DIR:-$HOME/lfs-sources}"

WGET_LIST="$DOC_DIR/wget-list"
MD5_FILE="$DOC_DIR/md5sums"
INVENTORY="$DOC_DIR/inventario-fuentes.csv"

ERRORS=0
WARNINGS=0
CHECKS=0

pass() {
    echo "[OK] $1"
    CHECKS=$((CHECKS + 1))
}

fail() {
    echo "[ERROR] $1"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo "[AVISO] $1"
    WARNINGS=$((WARNINGS + 1))
}

echo "=========================================="
echo " KRN-005 - Verificacion de fuentes LFS"
echo "=========================================="
echo "Repositorio: $ROOT_DIR"
echo "Fuentes:     $SOURCE_DIR"
echo

# 1. Comprobar documentos necesarios
for file in "$WGET_LIST" "$MD5_FILE" "$INVENTORY"; do
    if [[ -f "$file" ]]; then
        pass "Documento encontrado: $(basename "$file")"
    else
        fail "No existe el documento: $file"
    fi
done

if [[ ! -d "$SOURCE_DIR" ]]; then
    fail "No existe el directorio de fuentes: $SOURCE_DIR"
    echo
    echo "Resumen: $CHECKS verificaciones, $ERRORS errores, $WARNINGS avisos."
    exit 1
fi

# 2. Comprobar los archivos de wget-list
echo
echo "--- Archivos registrados en wget-list ---"

while IFS= read -r url || [[ -n "$url" ]]; do
    [[ -z "$url" || "$url" == \#* ]] && continue

    filename="${url##*/}"

    if [[ -s "$SOURCE_DIR/$filename" ]]; then
        pass "Archivo disponible: $filename"
    elif [[ -f "$SOURCE_DIR/$filename" ]]; then
        fail "Archivo vacio: $filename"
    else
        fail "Archivo faltante: $filename"
    fi
done < "$WGET_LIST"

# 3. Verificar los MD5 oficiales
echo
echo "--- MD5 oficiales ---"

if (
    cd "$SOURCE_DIR" &&
    md5sum --check --quiet "$MD5_FILE"
); then
    official_count=$(wc -l < "$MD5_FILE")
    pass "MD5 oficiales correctos: $official_count"
else
    fail "Uno o mas MD5 oficiales no coinciden"
fi

# 4. Verificaciones complementarias
echo
echo "--- MD5 complementarios ---"

check_md5() {
    local expected="$1"
    local filename="$2"
    local actual

    if [[ ! -f "$SOURCE_DIR/$filename" ]]; then
        fail "No se puede verificar MD5: $filename no existe"
        return
    fi

    actual="$(md5sum "$SOURCE_DIR/$filename" | awk '{print $1}')"

    if [[ "$actual" == "$expected" ]]; then
        pass "MD5 complementario correcto: $filename"
    else
        fail "MD5 complementario incorrecto: $filename"
    fi
}

check_md5 "c7d954e5bc29704a662d2c10c9cc4952" "lfs-bootscripts-20250827.tar.xz"
check_md5 "af60786956a2dc84054fbf46652e515e" "sysklogd-2.7.2.tar.gz"
check_md5 "3af8fd8e13cad481eeeaa48be4247445" "sysvinit-3.14-consolidated-1.patch"
check_md5 "bc6890b975d19dc9db42d0c7364dd092" "sysvinit-3.14.tar.xz"
check_md5 "acd4360d8a5c3ef320b9db88d275dae6" "udev-lfs-20230818.tar.xz"

# 5. Integridad de archivos comprimidos
echo
echo "--- Integridad de archivos comprimidos ---"

check_archive() {
    local filename="$1"
    local command="$2"

    if [[ ! -f "$SOURCE_DIR/$filename" ]]; then
        fail "No se puede probar el archivo: $filename"
        return
    fi

    if "$command" -t "$SOURCE_DIR/$filename" >/dev/null 2>&1; then
        pass "Archivo comprimido valido: $filename"
    else
        fail "Archivo comprimido dañado: $filename"
    fi
}

check_archive "lfs-bootscripts-20250827.tar.xz" xz
check_archive "sysklogd-2.7.2.tar.gz" gzip
check_archive "sysvinit-3.14.tar.xz" xz
check_archive "udev-lfs-20230818.tar.xz" xz

# 6. Comprobar que el parche sea legible
echo
echo "--- Parche complementario ---"

PATCH="$SOURCE_DIR/sysvinit-3.14-consolidated-1.patch"

if [[ -s "$PATCH" ]] && git apply --stat "$PATCH" >/dev/null 2>&1; then
    pass "Parche legible y reconocido por git apply"
else
    fail "El parche no pudo verificarse"
fi

# 7. Comparar tamaños con el inventario
echo
echo "--- Comparacion de tamanos del inventario ---"

if [[ -f "$INVENTORY" ]]; then
    while IFS=, read -r filename type url expected_size status; do
        status="${status%$'\r'}"
        [[ "$filename" == "archivo" ]] && continue
        [[ -z "$filename" ]] && continue

        actual_size=""

        if [[ -f "$SOURCE_DIR/$filename" ]]; then
            actual_size="$(stat -c '%s' "$SOURCE_DIR/$filename")"
        else
            continue
        fi

        if [[ -z "$expected_size" ]]; then
            warn "El inventario no registra el tamano de $filename"
        elif [[ "$actual_size" != "$expected_size" ]]; then
            fail "Tamano diferente para $filename: inventario=$expected_size, real=$actual_size"
        else
            pass "Tamano correcto: $filename"
        fi

        if [[ "$status" != Descargado* ]]; then
            warn "Estado del inventario para $filename: $status"
        fi
    done < "$INVENTORY"
fi

# 8. Resumen
echo
echo "=========================================="
echo " RESUMEN DE VERIFICACION"
echo "=========================================="
echo "Verificaciones correctas: $CHECKS"
echo "Errores:                  $ERRORS"
echo "Avisos:                   $WARNINGS"
echo "=========================================="

if [[ "$ERRORS" -gt 0 ]]; then
    echo "RESULTADO: VERIFICACION CON ERRORES"
    exit 1
fi

echo "RESULTADO: VERIFICACION COMPLETADA"
exit 0
