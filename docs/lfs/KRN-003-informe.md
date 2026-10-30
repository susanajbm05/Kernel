# KRN-003 - Validación del anfitrión y herramientas LFS

## 1. Objetivo

Verificar que el sistema anfitrión de ONYX OS cuente con las herramientas,
versiones y características necesarias para utilizar Linux From Scratch
(LFS) 13.1-systemd como referencia.

## 2. Entorno evaluado

- Sistema operativo: Ubuntu 26.04.1 LTS.
- Arquitectura: x86_64.
- Kernel: 7.0.0-34-generic.
- Procesadores: 2.
- Memoria RAM: 3.3 GiB.

## 3. Herramientas verificadas

Se comprobó la disponibilidad de Bash, GCC, G++, Binutils, Make,
Bison, Gawk, Perl, Python, Coreutils, Diffutils, Findutils,
Gzip, Bzip2, XZ y Texinfo, entre otras herramientas.

También se realizó una prueba de compilación con G++, que finalizó
correctamente.

## 4. Comprobaciones adicionales

- /usr/bin/awk apunta a Gawk.
- /usr/bin/yacc ejecuta Bison.
- El sistema de archivos devpts está montado.
- El dispositivo /dev/ptmx está disponible.
- El kernel supera la versión mínima indicada para LFS.

## 5. Observaciones y pendientes

La ruta /bin/sh apunta a Dash y no a Bash.
Bash está instalado en /bin/bash, pero no se modificó el enlace
del sistema anfitrión.

La máquina virtual dispone de 2 núcleos y 3.3 GiB de RAM,
por debajo de los recursos recomendados para realizar compilaciones
de LFS cómodamente.

## 6. Evidencias

- host-check.txt
- host-check-final.txt
- host-versions.txt
- host-aux-tools.txt
- host-links-pty.txt
- host-final-check.txt

## 7. Resultado

La comprobación permitió verificar la disponibilidad de las
herramientas principales y ejecutar satisfactoriamente una prueba
de compilación C++.

La validación queda pendiente de resolver o justificar formalmente
el requisito relacionado con /bin/sh antes de declarar KRN-003
completamente aprobado.
