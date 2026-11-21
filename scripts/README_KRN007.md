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

Documentar la configuración del entorno LFS, la toolchain cruzada, las herramientas temporales, la corrección de GCC Pass 2 y los procedimientos de validación correspondientes a KRN-007.

## 2. Entorno de compilación

Variables utilizadas:

```bash
export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu
export PATH=/tools/bin:/usr/bin
```

El directorio `/tools` es un enlace simbólico a `/mnt/lfs/tools`.

La partición LFS debe estar montada en `/mnt/lfs` antes de realizar las operaciones correspondientes.

## 3. Toolchain cruzada

Se verificaron los siguientes ejecutables:

- `x86_64-lfs-linux-gnu-gcc`
- `x86_64-lfs-linux-gnu-g++`
- `x86_64-lfs-linux-gnu-ld`
- `x86_64-lfs-linux-gnu-as`

Se confirmó el target:

`x86_64-lfs-linux-gnu`

Versión de GCC y G++:

`16.2.0`

Los ejecutables de la toolchain cruzada se encuentran en `/tools/bin`.

## 4. Herramientas temporales

Se comprobó la disponibilidad de los 15 componentes siguientes:

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

También se verificaron los componentes correspondientes a:

16. Binutils Pass 2
17. GCC Pass 2

Las versiones confirmadas individualmente son:

| Componente | Versión |
|---|---|
| Ncurses | 6.5.20240427 |
| Patch | 2.7.6 |
| Sed | 4.9 |
| Xz | 5.8.1 |
| GCC / G++ | 16.2.0 |

La disponibilidad de los ejecutables se comprobó mediante `scripts/validacion_krn007.sh`.

La comprobación de presencia no sustituye las pruebas individuales de compilación y funcionamiento de cada paquete.

Para consultar la versión de Ncurses se utilizó:

```bash
sudo chroot /mnt/lfs /usr/bin/tic -V
```

Esta prueba se realiza dentro del entorno LFS para evitar conflictos entre las bibliotecas del sistema anfitrión y las del sistema LFS.

## 5. Corrección de GCC Pass 2

Durante la configuración de GCC Pass 2 se identificó un error tipográfico:

Opción incorrecta:

`--enable-lenguages=c,c++`

Opción correcta:

`--enable-languages=c,c++`

También se corrigió la configuración para utilizar:

`--prefix=/usr`

La instalación se realizó utilizando `DESTDIR=/mnt/lfs`, evitando la creación de una ruta de instalación duplicada.

Los ejecutables finales se encuentran en:

- `/mnt/lfs/usr/bin/gcc`
- `/mnt/lfs/usr/bin/g++`

El procedimiento detallado se encuentra en:

`docs/KRN-007_CORRECCION_GCC_PASS2.md`

## 6. Validación de GCC Pass 2

Se verificaron las versiones:

- GCC: 16.2.0
- G++: 16.2.0

Target:

`x86_64-lfs-linux-gnu`

También se comprobó la presencia de las bibliotecas:

- `libgcc_s.so.1`
- `libstdc++.so.6`
- `libstdc++.so.6.0.36`

Ubicación:

`/mnt/lfs/usr/lib`

Se realizaron pruebas de compilación C y C++:

- Compilación C: código de salida 0.
- Compilación C++: código de salida 0.
- Objetos generados: ELF de 64 bits para x86-64.

## 7. Registros de compilación e instalación

Se conservaron los registros:

- `/home/lfs/gcc-pass2-recompilacion.log`
- `/home/lfs/gcc-pass2-instalacion.log`

Se revisó el final de ambos registros y se buscaron patrones de errores fatales, referencias indefinidas y fallos de `make`. No se encontraron coincidencias.

Estos archivos constituyen evidencia del procedimiento realizado.

## 8. Scripts del proyecto

### `scripts/instalacion_krn007.sh`

Prepara y realiza comprobaciones iniciales del entorno de compilación, verifica directorios y fuentes requeridos, configura variables y establece el contexto de trabajo.

**Importante:** el script actual no ejecuta la compilación ni la instalación automática de los paquetes. Su función es preparar y comprobar el entorno.

### `scripts/validacion_krn007.sh`

Comprueba:

- Montaje y estructura del directorio LFS.
- Disponibilidad de la toolchain cruzada.
- Presencia de GCC y G++ Pass 2.
- Disponibilidad de bibliotecas.
- Presencia de las herramientas temporales y componentes de Binutils Pass 2.

El script verifica rutas y disponibilidad de ejecutables; no sustituye las pruebas funcionales individuales de todos los paquetes.

## 9. Alcance de KRN-007

KRN-007 comprende:

- Configuración del entorno LFS.
- Construcción y verificación de la toolchain cruzada.
- Herramientas temporales.
- Binutils Pass 2.
- GCC Pass 2.
- Documentación y validaciones correspondientes.

La preparación del Chroot y las herramientas adicionales de KRN-008 quedan fuera de este alcance.

## 10. Estado actual

Se completaron las verificaciones documentadas de la toolchain cruzada, GCC Pass 2, las bibliotecas y la disponibilidad de los 17 componentes contemplados en esta tarea.

Las pruebas de compilación C y C++ finalizaron correctamente y los registros de recompilación e instalación de GCC Pass 2 se conservaron como evidencia.

Los scripts del proyecto permiten preparar y comprobar el entorno, aunque la instalación automatizada de los paquetes no está implementada en el script de preparación.
