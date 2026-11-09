# KRN-007 - Guía para corregir GCC Pass 2

## 1. Objetivo

Esta guía explica cómo identificar y corregir el error de escritura encontrado durante la configuración de GCC Pass 2 en las máquinas virtuales del proyecto ONYX OS.

El procedimiento está basado en la corrección indicada por el ingeniero y en las pruebas realizadas durante KRN-007.

## 2. Error identificado

Durante la revisión de GCC Pass 2 se encontró una opción escrita incorrectamente:

**Opción incorrecta:**

    --enable-lenguages=c,c++

**Opción correcta:**

    --enable-languages=c,c++

La palabra `languages` estaba mal escrita. Esto provocaba que GCC no recibiera correctamente la opción para habilitar los lenguajes C y C++.

También se identificó que la configuración inicial utilizaba:

    --prefix=/mnt/lfs/usr

Para la instalación correcta se debe utilizar:

    --prefix=/usr

La ruta `/mnt/lfs` se establece posteriormente mediante `DESTDIR` durante la instalación.

## 3. Preparar la máquina virtual

Verificar que la partición LFS esté montada:

    lsblk -f
    df -h /mnt/lfs

Si no está montada, identificar primero la partición correcta y montarla. No asumir que todas las máquinas utilizan el mismo dispositivo.

Ejemplo, si la partición corresponde a `/dev/sdb1`:

    sudo mount /dev/sdb1 /mnt/lfs

Ingresar al usuario LFS:

    sudo -iu lfs

Configurar las variables:

    export LFS=/mnt/lfs
    export LFS_TGT=x86_64-lfs-linux-gnu

Entrar al directorio de compilación:

    cd /mnt/lfs/sources/gcc-16.2.0/build-pass2

## 4. Identificar el error

Revisar la configuración generada:

    grep -n -- '--enable-lenguages' config.status

Si aparece `--enable-lenguages`, se ha identificado el error ortográfico.

También se puede revisar la configuración registrada:

    grep -nE 'enable-lenguages|enable-languages|prefix=' config.status

## 5. Corregir la configuración

No se recomienda limitarse a editar manualmente `config.status`, porque es un archivo generado por el proceso de configuración.

La solución reproducible consiste en volver a ejecutar `configure` con las opciones corregidas desde `build-pass2`:

    ../configure --build=$(../config.guess) --host=$LFS_TGT --target=$LFS_TGT --prefix=/usr --with-build-sysroot=$LFS --enable-default-pie --enable-default-ssp --disable-fixincludes --disable-nls --disable-multilib --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libsanitizer --disable-libssp --disable-libvtv --enable-languages=c,c++ CXX_FOR_TARGET="$LFS_TGT-gcc -nostdinc++" LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc target_configargs=gcc_cv_target_thread_file=posix

Verificar que la configuración registre la opción correcta:

    grep -n -- '--enable-languages=c,c++' config.status

La configuración final debe utilizar `--prefix=/usr` y `--enable-languages=c,c++`.

## 6. Limpiar cachés anteriores, si es necesario

Si la recompilación presenta errores relacionados con configuraciones almacenadas anteriormente, eliminar las cachés correspondientes:

    rm -f /mnt/lfs/sources/gcc-16.2.0/build-pass2/x86_64-lfs-linux-gnu/libgcc/config.cache

    rm -f /mnt/lfs/sources/gcc-16.2.0/build-pass2/x86_64-lfs-linux-gnu/libstdc++-v3/config.cache

Este paso es condicional. No es necesario eliminar archivos si no están causando errores.

## 7. Recompilar GCC Pass 2

Ejecutar:

    PATH=/usr/bin:/bin:$PATH make -j2 all-gcc all-target-libgcc all-target-libstdc++-v3 2>&1 | tee /home/lfs/gcc-pass2-recompilacion.log

Esperar a que termine la compilación y revisar el resultado antes de instalar.

## 8. Instalar GCC Pass 2

La instalación debe utilizar `DESTDIR=/mnt/lfs`:

    make DESTDIR=/mnt/lfs install-gcc install-target-libgcc install-target-libstdc++-v3 2>&1 | tee /home/lfs/gcc-pass2-instalacion.log

Con `--prefix=/usr` y `DESTDIR=/mnt/lfs`, los ejecutables deben quedar en:

    /mnt/lfs/usr/bin/gcc
    /mnt/lfs/usr/bin/g++

No debe producirse una instalación duplicada dentro de:

    /mnt/lfs/mnt/lfs/usr

Si aparece esa ruta, detenerse e inspeccionar su contenido. No eliminarla sin confirmar que se trata de una instalación duplicada y prescindible.

Si aparece un error de espacio:

    df -h /mnt/lfs

Liberar espacio únicamente después de identificar qué archivos son prescindibles.

## 9. Verificar GCC y G++

Consultar las versiones:

    /mnt/lfs/usr/bin/gcc --version
    /mnt/lfs/usr/bin/g++ --version

Consultar el objetivo de compilación:

    /mnt/lfs/usr/bin/gcc -dumpmachine
    /mnt/lfs/usr/bin/g++ -dumpmachine

Resultado esperado:

    x86_64-lfs-linux-gnu

Consultar la configuración:

    /mnt/lfs/usr/bin/gcc -v

En el resultado debe aparecer la configuración corregida con:

    --prefix=/usr
    --enable-languages=c,c++

El registro de configuración puede conservar información histórica de la configuración anterior y mostrar una reconfiguración. Debe identificarse la configuración final corregida.

## 10. Comprobar las bibliotecas

Ejecutar:

    find /mnt/lfs/usr/lib /mnt/lfs/usr/lib64 -maxdepth 3 \( -name 'libgcc_s.so*' -o -name 'libstdc++.so*' \) -print 2>/dev/null

Se esperan las bibliotecas de GCC y C++, entre ellas:

- libgcc_s.so
- libgcc_s.so.1
- libstdc++.so
- libstdc++.so.6
- libstdc++.so.6.0.36

Los números de versión pueden variar según la versión instalada.

## 11. Solución temporal para el error de libbfd

Durante las pruebas desde el sistema anfitrión puede aparecer un error indicando que el ensamblador no encuentra `libbfd`.

Localizar la biblioteca:

    find /mnt/lfs/usr/lib -name 'libbfd-*.so'

Si se encuentra, crear un directorio temporal:

    mkdir -p /tmp/lfs-bfd-libs

Crear un enlace simbólico utilizando el nombre real encontrado. Ejemplo:

    ln -sf /mnt/lfs/usr/lib/libbfd-2.47.20260726.so /tmp/lfs-bfd-libs/libbfd-2.47.20260726.so

Establecer la ruta temporal:

    export LD_LIBRARY_PATH=/tmp/lfs-bfd-libs

Esta solución permite realizar las pruebas desde el sistema anfitrión sin añadir todas las bibliotecas de LFS a la ruta de búsqueda del anfitrión.

**Importante:** No utilizar `LD_LIBRARY_PATH=/mnt/lfs/usr/lib` de forma general, porque puede provocar conflictos al cargar la biblioteca C de LFS en programas del sistema anfitrión.

## 12. Prueba funcional de C y C++

Crear archivos de prueba:

    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR" || exit 1

    cat > test.c <<'SRC'
    int main(void) {
        return 0;
    }
    SRC

    cat > test.cpp <<'SRC'
    int main() {
        return 0;
    }
    SRC

Compilar C:

    /mnt/lfs/usr/bin/gcc -c test.c -o test-c.o
    echo "Resultado compilación C: $?"

Compilar C++:

    /mnt/lfs/usr/bin/g++ -c test.cpp -o test-cpp.o
    echo "Resultado compilación C++: $?"

Verificar los objetos:

    file test-c.o test-cpp.o

Resultado esperado:

    test-c.o: ELF 64-bit LSB relocatable, x86-64
    test-cpp.o: ELF 64-bit LSB relocatable, x86-64

Ambas compilaciones deben devolver código de salida 0.

Al finalizar:

    cd /
    rm -rf "$TEST_DIR"

## 13. Evidencias de la corrección

Conservar los registros:

- `/home/lfs/gcc-pass2-recompilacion.log`
- `/home/lfs/gcc-pass2-instalacion.log`

Registrar también:

- Versión de GCC y G++.
- Target de compilación.
- Configuración final de GCC.
- Bibliotecas instaladas.
- Resultado de compilación C y C++.
- Identificación ELF de los archivos objeto.

## 14. Resultados obtenidos en la máquina de referencia

En la máquina utilizada para corregir KRN-007 se obtuvo:

- GCC 16.2.0 disponible.
- G++ 16.2.0 disponible.
- Target `x86_64-lfs-linux-gnu`.
- Configuración final con `--prefix=/usr`.
- Configuración final con `--enable-languages=c,c++`.
- Bibliotecas `libgcc_s` y `libstdc++` presentes.
- Compilación C con código de salida 0.
- Compilación C++ con código de salida 0.
- Archivos objeto identificados como ELF de 64 bits para x86-64.

## 15. Alcance de la tarea

Este procedimiento corresponde a la corrección y validación de GCC Pass 2 dentro de KRN-007.

La preparación del Chroot y las herramientas adicionales correspondientes a KRN-008 quedan fuera del alcance de esta guía.
