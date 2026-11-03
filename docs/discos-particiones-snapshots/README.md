# Provisionar VM, discos, particiones y snapshots

## 1. Configuración de la máquina virtual

- Nombre de la máquina virtual: Kernel
- Sistema operativo: Ubuntu 25.04 (64 bits)
- Memoria RAM: 4783 MB
- Procesadores: 1
- Controlador de almacenamiento: SATA (AHCI)
- Cantidad de puertos SATA: 2

### Discos configurados

| Disco | Tamaño virtual | Controlador |
|---|---:|---|
| Kernel.vdi | 35.21 GB | SATA, puerto 0 |
| Kernel-data.vdi | 10 GB | SATA, puerto 1 |

El disco adicional `Kernel-data.vdi` aparece en Ubuntu como `/dev/sdb`.

### Pasos para reproducir la configuración

1. Crear una máquina virtual llamada `Kernel`.
2. Instalar Ubuntu 25.04 de 64 bits.
3. Asignar 4783 MB de memoria RAM y 1 procesador.
4. Crear un disco principal de 35.21 GB.
5. Crear un segundo disco virtual VDI de 10 GB.
6. Conectar el disco adicional al controlador SATA, en el puerto 1.
7. Iniciar Ubuntu y verificar que el disco adicional aparezca como `/dev/sdb`.

## 2. Particionado del disco adicional

Se utilizó una tabla de particiones GPT en el disco `/dev/sdb`.

| Partición | Sistema de archivos | Tamaño aproximado | Punto de montaje |
|---|---|---:|---|
| /dev/sdb1 | ext4 | 5 GB | /mnt/datos1 |
| /dev/sdb2 | xfs | 5 GB | /mnt/datos2 |

### Comandos utilizados

```bash
sudo parted /dev/sdb --script mklabel gpt
sudo parted /dev/sdb --script mkpart primary ext4 1MiB 5GiB
sudo parted /dev/sdb --script mkpart primary xfs 5GiB 100%
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.xfs /dev/sdb2
sudo mkdir -p /mnt/datos1 /mnt/datos2
sudo mount /dev/sdb1 /mnt/datos1
sudo mount /dev/sdb2 /mnt/datos2
```

## 3. Verificación de discos y particiones

Para verificar los sistemas de archivos y puntos de montaje se utilizó:

```bash
lsblk -f
```

Para consultar la tabla de particiones:

```bash
sudo parted /dev/sdb print
```

El disco `/dev/sdb` utiliza GPT y contiene dos particiones: una ext4 y otra XFS.

## 4. Montaje de las particiones

Las particiones se encuentran montadas en las siguientes rutas:

- `/dev/sdb1` en `/mnt/datos1`, con sistema de archivos ext4.
- `/dev/sdb2` en `/mnt/datos2`, con sistema de archivos XFS.

Para verificar los montajes se utilizaron:

```bash
df -h
mount | grep /mnt/datos
```

## 5. Configuración de montaje persistente

Se configuró el archivo `/etc/fstab` para que las particiones se monten automáticamente al iniciar Ubuntu.

Entradas configuradas:

```text
UUID=620bf47a-2818-44eb-9425-930ba4ddcfc1  /mnt/datos1  ext4  defaults,nofail  0 2
UUID=aae32898-f920-48f5-819a-14818001965c  /mnt/datos2  xfs   defaults,nofail  0 0
```

Los UUID permiten identificar las particiones independientemente del nombre que el sistema les asigne.

## 6. Prueba de persistencia después del reinicio

Se reinició la máquina virtual y se ejecutó:

```bash
df -h | grep /mnt/datos
```

Después del reinicio se comprobó que las dos particiones continuaban montadas:

- `/dev/sdb1` en `/mnt/datos1`.
- `/dev/sdb2` en `/mnt/datos2`.

Esto confirma que la configuración de montaje persistente funciona correctamente.

## 7. Instantáneas de la máquina virtual

Se registran las siguientes instantáneas en VirtualBox:

| Nombre | Fecha |
|---|---|
| ONYX-Estado-Inicial | 28/10/2026 18:11 |
| snap-particiones | Fecha por verificar |
| ONYX-KRN004-Antes-de-Compilacion | 03/11/2026 00:06 |

La instantánea `ONYX-KRN004-Antes-de-Compilacion` conserva un punto de restauración del estado de la máquina virtual y su configuración de discos y particiones. Su fecha de creación corresponde al 03/11/2026.

## 8. Evidencias

Las capturas de pantalla de la configuración, particiones, montajes, persistencia e instantáneas se almacenan en:

`docs/discos-particiones-snapshots/evidencias/`

- `snapshot-onyx-krn004.png`: captura de la lista de instantáneas de VirtualBox.
