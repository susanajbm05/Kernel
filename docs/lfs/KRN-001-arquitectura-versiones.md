# KRN-001 - Arquitectura y versiones LFS/BLFS

## 1. Objetivo

Definir y congelar la arquitectura, las versiones de LFS y BLFS, y los
recursos asignados a la máquina virtual de desarrollo de ONYX OS.

## 2. Arquitectura

- Arquitectura objetivo: x86_64.
- Edición de LFS: systemd.
- Edición de BLFS: systemd.

## 3. Versiones seleccionadas

- Linux From Scratch (LFS): 13.1-systemd, versión estable.
- Beyond Linux From Scratch (BLFS): 13.1-systemd, versión estable.
- Compatibilidad: BLFS 13.1-systemd está basado en LFS 13.1-systemd.

## 4. Recursos actuales de la máquina virtual

- Sistema anfitrión: Ubuntu 26.04.1 LTS.
- Arquitectura: x86_64.
- Procesadores asignados: 3.
- Memoria RAM asignada: 5.3 GiB.
- Disco virtual: 80 GB.
- Partición raíz de Ubuntu: `/dev/sda2`, ext4, aproximadamente 42.9 GB.
- Partición dedicada para LFS: `/dev/sda3`, ext4, aproximadamente 42.9 GB, nombre de partición `LFS`.
- Espacio libre en la partición raíz de Ubuntu: aproximadamente 27 GB.
- La partición LFS está creada, pero todavía no está montada.

### Comparación con las recomendaciones oficiales

La guía LFS recomienda al menos cuatro núcleos de CPU y 8 GB
de memoria RAM. La VM actual está por debajo de esos valores,
por lo que las compilaciones podrían tardar más.

La partición dedicada para LFS tiene aproximadamente 42.9 GB,
por encima del mínimo indicado en la guía. El espacio disponible
es adecuado para comenzar, aunque una instalación BLFS extensa
podría requerir más almacenamiento.

## 5. Fuentes oficiales

- LFS estable: https://www.linuxfromscratch.org/lfs/view/stable-systemd/
- BLFS estable: https://www.linuxfromscratch.org/blfs/view/stable-systemd/

## 6. Estado

- Arquitectura objetivo x86_64 definida.
- Versiones LFS 13.1-systemd y BLFS 13.1-systemd seleccionadas.
- Recursos de la máquina virtual documentados.
- Partición dedicada para LFS creada y verificada.
- Evidencias de configuración guardadas en `KRN-001-recursos-vm.txt`.
- La instalación de LFS todavía no ha comenzado.

La arquitectura, las versiones y la configuración de almacenamiento
quedan documentadas para servir como referencia en las tareas
dependientes de KRN-001.
