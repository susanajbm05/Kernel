# Kernel
##Instrucciones de compilación

Primero se entra a la carpeta del proyecto:

cd ~/kernel

Luego se ejecuta:

make clean && make run

Este comando limpia compilaciones anteriores, compila el kernel, genera la imagen ISO y abre Onix OS en QEMU.

Cuando aparezca GRUB, se selecciona Onyx OS y se presiona Enter.

Si todo funciona correctamente, el sistema mostrará la pantalla de Onix OS y permitirá realizar la prueba de teclado.

## Evidencia de funcionamiento

En la primera captura se observa el menú de GRUB mostrando la opción **Onyx OS**, lo que confirma que la imagen ISO fue generada correctamente y que GRUB reconoce el kernel.

En la segunda captura se muestra Onix OS ejecutándose en QEMU. El kernel inicia correctamente y permite realizar la prueba de teclado.

### Evidencia 1
Menú de GRUB cargando Onyx OS.

### Evidencia 2
Onix OS ejecutándose correctamente en QEMU.
