# KRN-005 - Descarga, verificación y versionado de fuentes y parches

## 1. Objetivo

Descargar las fuentes y parches correspondientes al entorno Linux From Scratch (LFS), verificar su integridad mediante sumas de comprobación y conservar un inventario auditable de los recursos utilizados.

## 2. Entorno de referencia

De acuerdo con la definición establecida en KRN-001:

- Proyecto: Linux From Scratch (LFS).
- Versión: 13.1-systemd estable.
- Arquitectura objetivo: x86_64.
- Entorno de trabajo: máquina virtual Ubuntu.
- Directorio local de descargas: ~/lfs-sources.

## 3. Fuentes de referencia

Se utilizaron los archivos wget-list y md5sums publicados por Linux From Scratch para la versión estable systemd.

- wget-list contiene las direcciones de descarga de los recursos.
- md5sums contiene las sumas MD5 publicadas para los archivos incluidos en el manifiesto.

Se comprobó que las copias conservadas corresponden a los archivos oficiales consultados. Ambos archivos se mantienen sin modificaciones.

## 4. Descarga e inventario

Se utilizó la lista wget-list mediante la herramienta Wget.

Resultados:

- Entradas registradas: 99.
- Archivos encontrados localmente: 99.
- Archivos faltantes: 0.

El archivo lfs-bootscripts-20250827.tar.xz presentó una respuesta HTTP 404 en la dirección original del directorio 13.1. Se obtuvo desde el directorio oficial development de Linux From Scratch y se actualizó su URL en el inventario para dejar constancia del origen efectivo de la descarga.

El inventario detallado se encuentra en inventario-fuentes.csv e incluye nombre, tipo, URL, tamaño en bytes y estado.

## 5. Verificación de integridad

Se ejecutó el procedimiento md5sum -c md5sums.

Resultados:

- Archivos incluidos en el manifiesto: 94.
- Verificaciones correctas: 94.
- Verificaciones fallidas: 0.

El registro completo se encuentra en verificacion-md5.txt.

MD5 permite comprobar la coincidencia con los valores publicados en el manifiesto, pero no se considera un algoritmo criptográfico moderno. Por ello, esta evidencia acredita la coincidencia respecto a dicha referencia.

## 6. Entradas adicionales sin suma en el manifiesto

La comparación entre wget-list y md5sums identificó cinco entradas sin una suma correspondiente:

- lfs-bootscripts-20250827.tar.xz
- sysklogd-2.7.2.tar.gz
- sysvinit-3.14-consolidated-1.patch
- sysvinit-3.14.tar.xz
- udev-lfs-20230818.tar.xz

Los cinco archivos están presentes localmente. Se realizaron verificaciones complementarias y se documentaron por separado en verificacion-complementaria.txt.

Resultados:

- lfs-bootscripts-20250827.tar.xz: MD5 comparado con una referencia externa consultada.
- sysklogd-2.7.2.tar.gz: MD5 comparado con la referencia oficial consultada y prueba gzip -t sin errores.
- sysvinit-3.14-consolidated-1.patch: archivo idéntico al parche descargado desde el repositorio oficial de parches LFS.
- sysvinit-3.14.tar.xz: MD5 comparado con la referencia oficial consultada y prueba xz -t sin errores.
- udev-lfs-20230818.tar.xz: MD5 comparado con una referencia histórica y prueba xz -t sin errores. Su inclusión en el conjunto específico de LFS 13.1-systemd continúa pendiente de justificación.

Estas verificaciones complementarias no se contabilizan dentro de las 94 verificaciones del manifiesto oficial. Tampoco se agregaron sumas inventadas al archivo md5sums.

## 7. Evidencias conservadas

La carpeta docs/lfs/krn-005/ contiene:

- wget-list: lista de direcciones de descarga.
- md5sums: manifiesto de sumas MD5.
- verificacion-md5.txt: registro de las 94 verificaciones.
- verificacion-complementaria.txt: registro de las cinco verificaciones adicionales.
- inventario-fuentes.csv: inventario de recursos.
- KRN-005-informe.md: informe técnico.

Las fuentes descargadas se mantienen en ~/lfs-sources y no se incorporan directamente al repositorio.

## 8. Conclusión

Se completó la descarga de los 99 recursos registrados en wget-list. De los archivos incluidos en el manifiesto oficial MD5, los 94 obtuvieron resultados correctos y no se registraron fallos.

También se identificaron cinco recursos sin suma correspondiente en el manifiesto y se documentaron sus verificaciones complementarias por separado. Se mantiene pendiente justificar la inclusión de udev-lfs-20230818.tar.xz en el conjunto específico de LFS 13.1-systemd.

El trabajo conserva evidencia de las referencias utilizadas, los resultados de integridad y las observaciones pendientes para facilitar la revisión y validación de KRN-005.
