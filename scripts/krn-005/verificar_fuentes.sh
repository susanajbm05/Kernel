#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESTINO="$HOME/lfs-sources"
MANIFIESTO="$SCRIPT_DIR/md5sums"

echo "======================================"
echo " ONYX - VERIFICACION DE FUENTES KRN-005"
echo "======================================"

if [ ! -d "$DESTINO" ]; then
    echo "[ERROR] No existe el directorio $DESTINO"
    echo "Ejecuta primero descargar_fuentes.sh"
    exit 1
fi

if [ ! -f "$MANIFIESTO" ]; then
    echo "[ERROR] No se encuentra el manifiesto md5sums."
    exit 1
fi

cd "$DESTINO"

echo "Verificando archivos del manifiesto MD5..."
echo ""

md5sum --check "$MANIFIESTO"

echo ""
echo "Verificacion finalizada."
