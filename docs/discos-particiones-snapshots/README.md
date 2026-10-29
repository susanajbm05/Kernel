# Provisionar VM, discos, particiones y snapshots

## Disco agregado
- Archivo: Kernel-data.vdi
- Tamaño: 10 GB, formato VDI
- Controlador: SATA (aparece en la VM como /dev/sdb)

## Particiones (tabla GPT)
- sdb1: ext4, 5 GB, montada en /mnt/datos1
- sdb2: xfs, ~5 GB, montada en /mnt/datos2

## Comandos usados
sudo parted /dev/sdb --script mklabel gpt
sudo parted /dev/sdb --script mkpart primary ext4 1MiB 5GiB
sudo parted /dev/sdb --script mkpart primary xfs 5GiB 100%
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.xfs /dev/sdb2
sudo mkdir -p /mnt/datos1 /mnt/datos2
sudo mount /dev/sdb1 /mnt/datos1
sudo mount /dev/sdb2 /mnt/datos2

## Montaje persistente (/etc/fstab)
UUID=620bf47a-2818-44eb-9425-930ba4ddcfc1  /mnt/datos1  ext4  defaults,nofail  0 2
UUID=aae32898-f920-48f5-819a-14818001965c  /mnt/datos2  xfs   defaults,nofail  0 0
