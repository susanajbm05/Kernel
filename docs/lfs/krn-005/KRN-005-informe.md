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

Se descargaron desde el sitio oficial de Linux From Scratch los archivos wget-list y md5sums.

- wget-list contiene las direcciones de descarga.
- md5sums contiene las sumas MD5 publicadas para los archivos incluidos en el manifiesto.

Ambos archivos se conservaron en esta carpeta como evidencia de las referencias utilizadas.

## 4. Descarga e inventario

Se utilizó la lista wget-list mediante la herramienta Wget.

Resultados:

- Entradas registradas: 99.
- Archivos encontrados localmente: 98.
- Archivos faltantes: 1.
- Archivo faltante: lfs-bootscripts-20250827.tar.xz.

El inventario detallado se encuentra en inventario-fuentes.csv e incluye nombre, tipo, URL, tamaño en bytes y estado de descarga.

## 5. Verificación de integridad

Se ejecutó el procedimiento md5sum -c md5sums.

Resultados:

- Archivos incluidos en el manifiesto: 94.
- Verificaciones correctas: 94.
- Verificaciones fallidas: 0.

El registro completo se encuentra en verificacion-md5.txt.

MD5 permite comprobar la coincidencia con los valores publicados en el manifiesto, pero no se considera un algoritmo criptográfico moderno. Por ello, esta evidencia acredita la verificación respecto a dicha referencia.

## 6. Entradas adicionales sin suma en el manifiesto

La comparación entre wget-list y md5sums identificó cinco entradas sin una suma correspondiente:

- lfs-bootscripts-20250827.tar.xz
- sysklogd-2.7.2.tar.gz
- sysvinit-3.14-consolidated-1.patch
- sysvinit-3.14.tar.xz
- udev-lfs-20230818.tar.xz

Cuatro archivos están presentes localmente y uno está pendiente de descarga.

No se les asignó un estado de verificación MD5 porque no aparecen en el manifiesto. Tampoco se inventaron sumas de comprobación.

Estas entradas quedan pendientes de revisión para confirmar su correspondencia con LFS 13.1-systemd antes de considerarlas parte del conjunto definitivo de fuentes.

## 7. Evidencias conservadas

La carpeta docs/lfs/krn-005/ contiene:

- wget-list: lista de direcciones de descarga.
- md5sums: manifiesto de sumas MD5.
- verificacion-md5.txt: registro de verificación.
- inventario-fuentes.csv: inventario de recursos.
- KRN-005-informe.md: informe técnico.

Las fuentes descargadas se mantienen en ~/lfs-sources y no se incorporan directamente al repositorio.

## 8. Conclusión

Se generó un inventario de los recursos indicados en la lista de referencia y se verificó la integridad de los 94 archivos incluidos en el manifiesto MD5, con 94 resultados correctos y cero fallidos.

También se identificaron cinco entradas sin suma correspondiente en el manifiesto. Estas se mantienen diferenciadas y pendientes de revisión para evitar declarar verificaciones que no se realizaron.

El trabajo conserva evidencia reproducible de las referencias utilizadas, los resultados de integridad y las observaciones pendientes para completar la validación del conjunto definitivo correspondiente a LFS 13.1-systemd.
