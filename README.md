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
https://git.alesoftsolutions.website/ProyectoOnyx/Kernel/src/branch/boot-kiara/docs/evidencias/Captura%20desde%202026-10-21%2019-41-26.png

### Evidencia 2
Onix OS ejecutándose correctamente en QEMU.
https://git.alesoftsolutions.website/ProyectoOnyx/Kernel/src/branch/boot-kiara/docs/evidencias/Captura%20desde%202026-10-21%2019-58-21.png
