KRN-007 — Toolchain cruzada y herramientas temporales

Proyecto: ONYX OS
Responsable: Liz
Sistema: Linux From Scratch (LFS) 13.1-systemd

1. Entorno LFS

Se preparó el entorno de trabajo para construir Linux From Scratch dentro de una máquina virtual Ubuntu utilizando VirtualBox.

Configuración utilizada:

Elemento                    | Configuración
Máquina virtual             | Kernell
Usuario de trabajo          | "lfs"
Directorio LFS              | "/mnt/lfs"
Directorio de fuentes       | "/mnt/lfs/sources"
Directorio de herramientas  | "/mnt/lfs/tools"
Arquitectura objetivo       | "x86_64"
Target                      | "x86_64-lfs-linux-gnu"
Variable LFS                | "/mnt/lfs"
PATH                        | "/tools/bin:/usr/bin"

2. Toolchain cruzada

Se trabajó en la construcción de la cadena de herramientas cruzadas necesaria para compilar los componentes del sistema LFS.

Los componentes trabajados comprenden:

- Binutils: herramientas para ensamblado y enlazado.
- GCC: compilador de C y C++.
- Linux API Headers: cabeceras de las interfaces del kernel Linux.
- Glibc: biblioteca principal de C.
- Libstdc++: biblioteca estándar de C++.
- Binutils Pass 2: segunda construcción de las herramientas Binutils.
- GCC Pass 2: segunda construcción del compilador GCC.

La arquitectura objetivo utilizada fue "x86_64-lfs-linux-gnu".

3. Herramientas temporales

Se trabajó en la instalación de las herramientas temporales necesarias para continuar la construcción de LFS.

Las herramientas verificadas fueron:

Herramienta     | Descripción
M4              | Procesador de macros
Bash            | Intérprete de comandos
Coreutils       | Utilidades básicas
Diffutils       | Comparación de archivos
File            | Identificación de archivos
Findutils       | Búsqueda de archivos
Gawk            | Procesamiento de texto
Grep            | Búsqueda de patrones
Gzip            | Compresión
Make            | Automatización de compilación
Patch           | Aplicación de modificaciones
Sed             | Edición de texto
Tar             | Gestión de archivos
Xz              | Compresión

4. Comprobaciones realizadas

Se realizaron comprobaciones mediante comandos Bash para verificar que los ejecutables estuvieran disponibles en las rutas correspondientes:

- "/mnt/lfs/usr/bin/"
- "/mnt/lfs/tools/bin/"

Se verificaron también los siguientes ejecutables de la toolchain:

- "x86_64-lfs-linux-gnu-ld"
- "x86_64-lfs-linux-gnu-gcc"
- "x86_64-lfs-linux-gnu-g++"

Verificación de GCC

Se ejecutaron los siguientes comandos:

/mnt/lfs/tools/bin/x86_64-lfs-linux-gnu-gcc --version

/mnt/lfs/tools/bin/x86_64-lfs-linux-gnu-gcc -v

Se confirmó que GCC responde correctamente y muestra la versión 16.2.0.

También se comprobó su arquitectura objetivo, directorio de instalación y configuración.

5. Resultado

Se completó la instalación de las herramientas temporales y se verificó la disponibilidad de los ejecutables incluidos en la comprobación.

GCC 16.2.0 fue localizado y comprobado correctamente, al igual que G++ y el enlazador de la toolchain cruzada.

Con este trabajo se deja preparado el entorno correspondiente a KRN-007 para continuar con las siguientes etapas de construcción de ONYX OS.

Nota: La preparación de Chroot y las herramientas adicionales pertenecen a KRN-008, asignada a Danna, por lo que no forman parte de esta tarea.
