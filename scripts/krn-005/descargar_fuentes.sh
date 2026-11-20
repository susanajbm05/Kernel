#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESTINO="$HOME/lfs-sources"
LISTA="$SCRIPT_DIR/wget-list"

echo "======================================"
echo " ONYX - DESCARGA DE FUENTES KRN-005"
echo "======================================"

if ! command -v wget >/dev/null 2>&1; then
    echo "[ERROR] wget no esta instalado."
    exit 1
fi

if [ ! -f "$LISTA" ]; then
    echo "[ERROR] No se encuentra wget-list."
    exit 1
fi

mkdir -p "$DESTINO"

echo "Directorio de descarga: $DESTINO"

fallidos=0

while IFS= read -r url || [ -n "$url" ]; do
    [ -z "$url" ] && continue

    archivo="${url##*/}"

    echo ""
    echo "[DESCARGANDO] $archivo"

    if wget -c -P "$DESTINO" "$url"; then
        echo "[OK] $archivo"
    else
        echo "[ERROR] No se pudo descargar $archivo"
        fallidos=$((fallidos + 1))
    fi
done < "$LISTA"

echo ""
echo "======================================"

if [ "$fallidos" -eq 0 ]; then
    echo "Descargas finalizadas correctamente."
else
    echo "Descargas con errores: $fallidos"
    exit 1
fi
