# KRN-003 - Validación del anfitrión y herramientas LFS

## 1. Objetivo

Verificar que el sistema anfitrión de ONYX OS disponga de las
herramientas, versiones y características necesarias para utilizar
Linux From Scratch (LFS) 13.1-systemd como referencia.

## 2. Entorno evaluado

- Sistema operativo: Ubuntu 26.04.1 LTS.
- Arquitectura: x86_64.
- Kernel: 7.0.0-34-generic.
- Procesadores disponibles: 3.
- Memoria RAM: 5.3 GiB.
- Memoria Swap: 3.8 GiB.

## 3. Herramientas verificadas

Se comprobó la disponibilidad de Bash, GCC, G++, Binutils, Make,
Bison, Gawk, Perl, Python, Coreutils, Diffutils, Findutils,
Gzip, Bzip2, XZ, Texinfo y otras herramientas auxiliares.

Las versiones detectadas superan los mínimos configurados
en el comprobador de versiones de LFS 13.1-systemd.


Ubuntu utiliza Uutils Coreutils 0.8.0 como proveedor
predeterminado. Ambos cumplen la versión mínima indicada
por LFS 13.1.

También se realizó una prueba de compilación con G++,
que finalizó correctamente.

## 4. Comprobaciones adicionales

- /bin/sh apunta a Bash.
- /usr/bin/awk apunta a Gawk.
- /usr/bin/yacc ejecuta Bison.

Los registros iniciales muestran que el enlace /bin/sh
apuntaba a Dash. Posteriormente se ajustó para utilizar Bash
y se repitieron las comprobaciones, obteniendo resultados
satisfactorios, como se refleja en las evidencias finales.

- El sistema de archivos devpts está montado.
- El dispositivo /dev/ptmx está disponible.
- El kernel supera la versión mínima indicada para LFS.
- La comprobación de versiones finalizó sin errores.

## 5. Observaciones

La máquina virtual dispone de 3 procesadores y 5.3 GiB de RAM,
por debajo de las recomendaciones de 4 núcleos y 8 GB
para realizar compilaciones de LFS con mayor comodidad.

Estas condiciones representan recomendaciones de rendimiento,
no errores de las comprobaciones ejecutadas.

## 6. Evidencias

- host-check.txt
- host-check-final.txt
- host-versions.txt
- host-aux-tools.txt
- host-links-pty.txt
- host-final-check.txt
- version-check.sh
- version-check-result.txt
- scripts/lfs-host-check.sh

## 7. Resultado

Las comprobaciones ejecutadas detectaron correctamente las
herramientas principales, los enlaces simbólicos requeridos,
el soporte PTY y la capacidad de compilación C++.

El comprobador principal finalizó con cero errores y dos
observaciones relacionadas con los recursos disponibles.

El comprobador de versiones de LFS 13.1-systemd también
finalizó satisfactoriamente. Todas las herramientas evaluadas
cumplieron las versiones mínimas establecidas.

Las evidencias de ambas comprobaciones quedaron registradas
en los archivos correspondientes dentro del repositorio.

Por tanto, la validación técnica del anfitrión presenta
resultados satisfactorios para los criterios evaluados
en KRN-003.
