#!/usr/bin/env bash
set -Eeuo pipefail

LFS="${LFS:-/mnt/lfs}"
MODO="${1:---check}"

MONTADOS=()

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

limpiar_montajes() {
    local i

    for ((i=${#MONTADOS[@]}-1; i>=0; i--)); do
        if mountpoint -q "${MONTADOS[$i]}"; then
            if umount "${MONTADOS[$i]}"; then
                echo "[DESMONTADO] ${MONTADOS[$i]}"
            else
                echo "[ERROR] No se pudo desmontar ${MONTADOS[$i]}" >&2
            fi
        fi
    done
}

manejar_error() {
    local codigo=$?

    echo "[ERROR] Falló la preparación. Código: $codigo" >&2
    limpiar_montajes
    exit "$codigo"
}

if [[ "$EUID" -ne 0 ]]; then
    error "Ejecuta el script con sudo."
fi

if [[ "$LFS" != /* || "$LFS" == "/" ]]; then
    error "La ruta LFS debe ser absoluta y no puede ser /."
fi

if [[ ! -d "$LFS" ]]; then
    error "No existe la raíz LFS: $LFS"
fi

if ! mountpoint -q "$LFS"; then
    error "La raíz LFS no es un punto de montaje."
fi

if [[ "$MODO" != "--check" &&
      "$MODO" != "--mount" &&
      "$MODO" != "--chroot" ]]; then
    error "Uso: sudo LFS=/ruta/lfs $0 [--check|--mount|--chroot]"
fi

opciones=$(findmnt -n -o OPTIONS --target "$LFS")

if [[ "$MODO" != "--check" && ",$opciones," == *,ro,* ]]; then
    error "La raíz LFS está montada en solo lectura."
fi

echo "======================================"
echo " KRN-008 - Preparación del Chroot"
echo " Raíz LFS: $LFS"
echo " Modo: $MODO"
echo "======================================"

fallos=0

comprobar_archivo() {
    local archivo="$1"

    if [[ -x "$LFS/$archivo" ]]; then
        echo "[OK] $archivo"
    else
        echo "[FALTA] $archivo"
        fallos=$((fallos + 1))
    fi
}

comprobar_directorio() {
    local directorio="$1"

    if [[ -d "$LFS/$directorio" ]]; then
        echo "[OK] $directorio/"
    else
        echo "[FALTA] $directorio/"
        fallos=$((fallos + 1))
    fi
}

echo ""
echo "===== HERRAMIENTAS DEL CHROOT ====="

comprobar_archivo "usr/bin/env"
comprobar_archivo "bin/bash"

echo ""
echo "===== DIRECTORIOS DEL SISTEMA ====="

comprobar_directorio "usr/bin"
comprobar_directorio "usr/sbin"
comprobar_directorio "usr/lib"

if ((fallos > 0)); then
    error "Faltan $fallos requisitos. No se puede continuar."
fi

echo ""
echo "[OK] Requisitos básicos encontrados."

if [[ "$MODO" == "--check" ]]; then
    echo "Verificación terminada. No se realizaron cambios."
    exit 0
fi

echo ""
echo "===== HERRAMIENTAS DEL ANFITRIÓN ====="

for comando in mount mountpoint findmnt chroot mkdir umount; do
    if command -v "$comando" >/dev/null 2>&1; then
        echo "[OK] $comando"
    else
        error "No se encontró el comando del anfitrión: $comando"
    fi
done

if [[ ! -w "$LFS" ]]; then
    error "La raíz LFS no permite escritura."
fi

preparar_directorios() {
    mkdir -pv "$LFS"/{dev,proc,sys,run}
}

montar_si_necesario() {
    local destino="$1"
    shift

    if mountpoint -q "$destino"; then
        echo "[YA MONTADO] $destino"
    else
        "$@"
        MONTADOS+=("$destino")
        echo "[MONTADO] $destino"
    fi
}

preparar_montajes() {
    preparar_directorios

    trap manejar_error ERR

    montar_si_necesario "$LFS/dev" \
        mount --bind /dev "$LFS/dev"

    mkdir -p "$LFS/dev/pts"

    montar_si_necesario "$LFS/dev/pts" \
        mount -t devpts devpts -o gid=5,mode=0620 "$LFS/dev/pts"

    montar_si_necesario "$LFS/proc" \
        mount -t proc proc "$LFS/proc"

    montar_si_necesario "$LFS/sys" \
        mount -t sysfs sysfs "$LFS/sys"

    montar_si_necesario "$LFS/run" \
        mount -t tmpfs tmpfs "$LFS/run"

    trap - ERR

    echo "[OK] Preparación de montajes completada."
}

if [[ "$MODO" == "--mount" ]]; then
    preparar_montajes
    exit 0
fi

if [[ "$MODO" == "--chroot" ]]; then
    preparar_montajes

    # Limpiar los montajes realizados por esta ejecución
    # al salir del Chroot, tanto si termina correctamente
    # como si ocurre un error.
    trap limpiar_montajes EXIT

    echo "Entrando al entorno LFS."
    echo "Para salir del Chroot, escribe: exit"

    chroot "$LFS" /usr/bin/env -i \
        HOME=/root \
        TERM="${TERM:-linux}" \
        PS1='(lfs chroot) \u:\w\$ ' \
        PATH=/usr/bin:/usr/sbin \
        /bin/bash --login
fi
