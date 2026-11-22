#!/usr/bin/env bash
set -Eeuo pipefail

LFS="${LFS:-/mnt/lfs}"
MODO="${1:---check}"

MONTADOS=()
declare -A MONTADOS_PROPIOS=()

LIMPIAR_AL_SALIR=0

# ==================================================
# VALIDACION INICIAL DE LFS
# ==================================================

if [[ "$LFS" != /* ]]; then
    echo "[ERROR] LFS debe ser una ruta absoluta: $LFS" >&2
    exit 1
fi

if [[ "$LFS" == "/" ]]; then
    echo "[ERROR] No se permite utilizar LFS=/." >&2
    exit 1
fi

if [[ "$MODO" != "--check" &&
      "$MODO" != "--mount" &&
      "$MODO" != "--chroot" ]]; then
    echo "[ERROR] Modo no válido. Usa --check, --mount o --chroot." >&2
    exit 1
fi

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# ==================================================
# HERRAMIENTAS DEL SISTEMA
# ==================================================

for herramienta in mount mountpoint findmnt chroot mkdir umount realpath; do
    command -v "$herramienta" >/dev/null 2>&1 ||
        error "Falta la herramienta del sistema: $herramienta"
done

# ==================================================
# VALIDAR Y NORMALIZAR LA RUTA LFS
# ==================================================

if [[ ! -d "$LFS" ]]; then
    error "No existe el directorio LFS: $LFS"
fi

LFS_REAL=$(realpath -e -- "$LFS") ||
    error "No se pudo resolver la ruta LFS."

if [[ "$LFS_REAL" == "/" ]]; then
    error "La ruta LFS no puede apuntar a la raíz del anfitrión."
fi

LFS="$LFS_REAL"

IDENTIFICADOR=$(printf '%s' "$LFS" | cksum | awk '{print $1}')
ESTADO="/run/krn-008-montajes-${IDENTIFICADOR}.txt"

# ==================================================
# GUARDAR ESTADO DE LOS MONTAJES
# ==================================================

guardar_estado() {
    local temporal="${ESTADO}.tmp"

    if ! {
        printf '%s\n' "${MONTADOS[@]}" > "$temporal"
    }; then
        rm -f "$temporal"
        echo "[ERROR] No se pudo escribir el estado temporal." >&2
        return 1
    fi

    if ! chmod 600 "$temporal"; then
        rm -f "$temporal"
        echo "[ERROR] No se pudieron establecer los permisos del estado." >&2
        return 1
    fi

    if ! mv -f "$temporal" "$ESTADO"; then
        rm -f "$temporal"
        echo "[ERROR] No se pudo guardar el archivo de estado." >&2
        return 1
    fi

    return 0
}

# ==================================================
# RECUPERAR ESTADO ANTERIOR
# ==================================================

cargar_estado() {
    local mount_id punto existente
    local encontrado

    [[ -f "$ESTADO" ]] || return 0

    while IFS='|' read -r mount_id punto; do

        [[ "$punto" == "$LFS/"* ]] || continue
        mountpoint -q "$punto" || continue

        if [[ "$mount_id" != "PENDING" &&
              ! "$mount_id" =~ ^[0-9]+$ ]]; then
            continue
        fi

        encontrado=0

        for existente in "${MONTADOS[@]}"; do
            if [[ "$existente" == "$mount_id|$punto" ]]; then
                encontrado=1
                break
            fi
        done

        if ((encontrado == 0)); then
            MONTADOS+=("$mount_id|$punto")
        fi

    done < "$ESTADO"
}

# ==================================================
# LIMPIEZA SEGURA DE LOS MONTAJES
# ==================================================

limpiar_montajes() {
    local i mount_id punto actual
    local fallo=0

    for ((i=${#MONTADOS[@]}-1; i>=0; i--)); do

        IFS='|' read -r mount_id punto <<< "${MONTADOS[$i]}"

        # Montaje pendiente: solo se desmonta automáticamente
        # si fue realizado por esta ejecución del script.

        if [[ "$mount_id" == "PENDING" ]]; then

            if [[ "${MONTADOS_PROPIOS[$punto]:-0}" == "1" ]]; then

                if mountpoint -q "$punto"; then

                    if umount "$punto" && ! mountpoint -q "$punto"; then
                        echo "[DESMONTADO] $punto"
                        unset 'MONTADOS_PROPIOS[$punto]'
                    else
                        echo "[ERROR] No se pudo desmontar $punto" >&2
                        fallo=1
                    fi

                else
                    unset 'MONTADOS_PROPIOS[$punto]'
                fi

            elif mountpoint -q "$punto"; then
                echo "[ERROR] Montaje pendiente sin ID verificable: $punto" >&2
                fallo=1
            fi

            continue
        fi

        actual=$(findmnt -n -o ID --mountpoint "$punto" 2>/dev/null || true)

        if [[ "$actual" == "$mount_id" ]]; then

            if umount "$punto" && ! mountpoint -q "$punto"; then
                echo "[DESMONTADO] $punto"
            else
                echo "[ERROR] No se pudo desmontar completamente $punto" >&2
                fallo=1
            fi

        elif mountpoint -q "$punto"; then
            echo "[ERROR] El montaje cambió en $punto; no se desmontará." >&2
            fallo=1
        fi

    done

    if ((fallo == 0)); then
        if ! rm -f -- "$ESTADO" "${ESTADO}.tmp"; then
            echo "[ERROR] No se pudieron eliminar los archivos de estado: $ESTADO y ${ESTADO}.tmp" >&2
            fallo=1
        fi
    fi

    if ((fallo == 0)); then
        echo "[OK] Limpieza de montajes completada."
        return 0
    fi

    echo "[ERROR] Limpieza incompleta. Se conserva el estado: $ESTADO" >&2
    return 1
}

# ==================================================
# MANEJO DE SALIDA Y ERRORES
# ==================================================

al_salir() {
    local codigo=$?

    trap - EXIT

    if ((LIMPIAR_AL_SALIR == 1)); then

        if ! limpiar_montajes; then
            echo "[ERROR] Algunos montajes siguen pendientes." >&2

            if ((codigo == 0)); then
                codigo=1
            fi
        fi

    fi

    exit "$codigo"
}

# ==================================================
# VALIDACIONES DEL ENTORNO LFS
# ==================================================

if [[ "$EUID" -ne 0 ]]; then
    error "Ejecuta el script con sudo."
fi

if ! mountpoint -q "$LFS"; then
    error "La raíz LFS no está montada: $LFS"
fi

opciones=$(findmnt -n -o OPTIONS --target "$LFS") ||
    error "No se pudieron consultar las opciones de montaje de LFS."

if [[ "$MODO" != "--check" ]]; then

    if [[ ",$opciones," != *",rw,"* ]]; then
        error "La raíz LFS debe estar montada en modo lectura y escritura."
    fi

    if [[ ! -w "$LFS" ]]; then
        error "No hay permisos de escritura en $LFS."
    fi

fi

echo "======================================"
echo " KRN-008 - Preparación del Chroot"
echo " Raíz LFS: $LFS"
echo " Modo: $MODO"
echo "======================================"

echo
echo "===== HERRAMIENTAS DEL CHROOT ====="

for archivo in usr/bin/env bin/bash; do

    if [[ -x "$LFS/$archivo" ]]; then
        echo "[OK] $archivo"
    else
        error "Falta una herramienta ejecutable: $archivo"
    fi

done

echo
echo "===== DIRECTORIOS DEL SISTEMA ====="

for directorio in usr/bin usr/sbin usr/lib; do

    if [[ -d "$LFS/$directorio" ]]; then
        echo "[OK] $directorio/"
    else
        error "Falta el directorio: $directorio"
    fi

done

if [[ "$MODO" == "--check" ]]; then
    echo
    echo "[OK] Verificación completada."
    exit 0
fi

# ==================================================
# PREPARACION DE DIRECTORIOS
# ==================================================

preparar_directorios() {
    mkdir -pv "$LFS"/{dev/pts,proc,sys,run}
}

# ==================================================
# MONTAJE CON REGISTRO INMEDIATO
# ==================================================

montar_si_necesario() {
    local destino="$1"
    local mount_id
    local indice

    shift

    if mountpoint -q "$destino"; then
        echo "[YA MONTADO] $destino"
        return 0
    fi

    if ! "$@"; then

        # Si el montaje llegó a existir a pesar del error,
        # se registra como pendiente para intentar limpiarlo.

        if mountpoint -q "$destino"; then
            MONTADOS+=("PENDING|$destino")
            MONTADOS_PROPIOS["$destino"]=1
            guardar_estado || true
        fi

        error "No se pudo realizar el montaje: $destino"
    fi

    # Registrar inmediatamente el montaje como PENDING.
    # Así EXIT puede intentar desmontarlo incluso si falla
    # la identificación o el guardado del ID.

    MONTADOS+=("PENDING|$destino")
    MONTADOS_PROPIOS["$destino"]=1

    if ! guardar_estado; then
        error "No se pudo registrar el montaje pendiente: $destino"
    fi

    # Obtener y verificar el ID real del montaje.

    mount_id=$(findmnt -n -o ID --mountpoint "$destino" 2>/dev/null) ||
        error "No se pudo identificar el montaje: $destino"

    if [[ ! "$mount_id" =~ ^[0-9]+$ ]]; then
        error "ID de montaje inválido: $destino"
    fi

    # Sustituir PENDING por el ID verificado.

    indice=$((${#MONTADOS[@]} - 1))
    MONTADOS[$indice]="$mount_id|$destino"

    if ! guardar_estado; then
        error "No se pudo guardar el ID del montaje: $destino"
    fi

    echo "[MONTADO] $destino (ID: $mount_id)"
}

# ==================================================
# PREPARACION DE LOS MONTAJES
# ==================================================

preparar_montajes() {

    preparar_directorios

    montar_si_necesario "$LFS/dev" \
        mount --bind /dev "$LFS/dev"

    montar_si_necesario "$LFS/dev/pts" \
        mount -t devpts devpts -o gid=5,mode=0620 "$LFS/dev/pts"

    montar_si_necesario "$LFS/proc" \
        mount -t proc proc "$LFS/proc"

    montar_si_necesario "$LFS/sys" \
        mount -t sysfs sysfs "$LFS/sys"

    montar_si_necesario "$LFS/run" \
        mount --bind /run "$LFS/run"

    echo
    echo "[OK] Preparación de montajes completada."
}

# ==================================================
# INICIO DE LA PROTECCION DE LIMPIEZA
# ==================================================

cargar_estado

LIMPIAR_AL_SALIR=1
trap al_salir EXIT

# ==================================================
# MODO --MOUNT
# ==================================================

if [[ "$MODO" == "--mount" ]]; then

    preparar_montajes

    # Los montajes deben permanecer activos en este modo.
    # Se desactiva la limpieza únicamente después de completar
    # y guardar correctamente todos los registros.

    LIMPIAR_AL_SALIR=0
    trap - EXIT

    echo "[OK] Montajes preparados y registrados."
    echo "[OK] Los montajes permanecerán activos."

    exit 0
fi

# ==================================================
# MODO --CHROOT
# ==================================================

if [[ "$MODO" == "--chroot" ]]; then

    preparar_montajes

    echo
    echo "Entrando al entorno LFS."
    echo "Para salir del Chroot, escribe: exit"

    chroot "$LFS" /usr/bin/env -i \
        HOME=/root \
        TERM="${TERM:-linux}" \
        PS1='(lfs chroot) \u:\w\$ ' \
        PATH=/usr/bin:/usr/sbin:/bin:/sbin \
        /bin/bash --login

fi
