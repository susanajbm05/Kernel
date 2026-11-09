
# ONYX OS - KRN-007
## Toolchain cruzada y herramientas temporales

**Proyecto:** ONYX OS  
**Ticket:** KRN-007  
**Referencia:** Linux From Scratch 13.1-systemd  
**Arquitectura:** x86_64  
**Target:** `x86_64-lfs-linux-gnu`  
**Directorio LFS:** `/mnt/lfs`

---

## 1. Objetivo

Documentar la configuración del entorno LFS, la toolchain cruzada, las herramientas temporales y los procedimientos de validación correspondientes a KRN-007.

## 2. Entorno de compilación

Variables utilizadas:

```bash
export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu
export PATH=/tools/bin:/usr/bin
```

El directorio `/tools` es un enlace simbólico a `/mnt/lfs/tools`.

## 3. Toolchain cruzada

Se verificaron los siguientes compiladores:

- `x86_64-lfs-linux-gnu-gcc`
- `x86_64-lfs-linux-gnu-g++`

Versión identificada: GCC 16.2.0.

Target confirmado:

`x86_64-lfs-linux-gnu`

## 4. Herramientas temporales

Se localizaron ejecutables correspondientes a:

1. M4
2. Ncurses
3. Bash
4. Coreutils
5. Diffutils
6. File
7. Findutils
8. Gawk
9. Grep
10. Gzip
11. Make
12. Patch
13. Sed
14. Tar
15. Xz

También se identificaron componentes de Binutils y GCC en `/tools/bin`.

La presencia de los ejecutables fue comprobada mediante `scripts/validacion_krn007.sh`. La comprobación de presencia no sustituye la validación individual de versiones y compilaciones de todos los paquetes.

## 5. Corrección de GCC Pass 2

Se identificó un error tipográfico en la configuración de GCC Pass 2:

Opción incorrecta:

`--enable-lenguages=c,c++`

Opción corregida:

`--enable-languages=c,c++`

Archivo corregido:

`/mnt/lfs/sources/gcc-16.2.0/build-pass2/config.status`

Comando utilizado:

```bash
sudo sed -i 's/--enable-lenguages/--enable-languages/g' config.status
```

Se comprobó que no quedaran apariciones de la opción incorrecta.

## 6. Prueba de compilación

Se realizaron pruebas de compilación C y C++ utilizando los ejecutables de:

`/mnt/lfs/mnt/lfs/usr/bin/`

Resultados:

- Compilación C: código de salida 0.
- Compilación C++: código de salida 0.
- Archivos generados: objetos ELF de 64 bits para x86-64.

## 7. Inconsistencia pendiente

Se detectó que GCC y G++ están disponibles en:

`/mnt/lfs/mnt/lfs/usr/bin/`

Pero no aparecen en la ubicación esperada:

`/mnt/lfs/usr/bin/`

Por tanto, queda pendiente completar la recompilación de GCC Pass 2 y repetir las validaciones en la ruta esperada.

## 8. Scripts del proyecto

- `scripts/instalacion_krn007.sh`: configuración y comprobaciones iniciales del entorno; pendiente completar el procedimiento de instalación.
- `scripts/validacion_krn007.sh`: comprobación de toolchain, herramientas y bibliotecas.

## 9. Alcance

KRN-007 comprende el entorno LFS, la toolchain cruzada, las herramientas temporales y su documentación.

La preparación del Chroot y las herramientas adicionales de KRN-008 quedan fuera de este alcance.

## 10. Estado

KRN-007 continúa en proceso hasta completar la instalación correcta de GCC Pass 2, las validaciones finales y las evidencias correspondientes.
