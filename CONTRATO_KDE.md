cat << 'EOF' > CONTRATO_KDE.md
# CONTRATO TÉCNICO DE INTEGRACIÓN: ONYX OS <-> KDE PLASMA

**Fecha:** 2026-11-02  
**Sistema Operativo:** ONYX OS (Linux Kernel Core)  
**Entorno de Escritorio:** KDE Plasma Framework  

---

## 1. systemd (Init & System Manager)
* **Gestión de Servicios:** El kernel de ONYX OS mantendrá soporte nativo para los cgroups v2 requeridos por `systemd`.
* **Sesión de Usuario:** Los componentes de KDE Plasma (`plasmashell`, `kwin`) se ejecutarán como unidades de usuario de systemd (`systemd --user`).
* **Ciclo de Vida:** Apagado, reinicio y suspensión coordinados vía targets de systemd (`plasma-workspace.target`).

## 2. D-Bus (Inter-Process Communication)
* **Bus del Sistema y Sesión:** Implementación de `dbus-daemon` o `dbus-broker` activo al arranque.
* **Interfaz KDE:** Protocolos de comunicación entre el kernel/servicios base y las APIs de KDE (`org.kde.KWin`, `org.freeware.Notifications`).
* **Seguridad:** Reglas estricta de políticas de bus bajo `/usr/share/dbus-1/system.d/` para restringir accesos privilegiados.

## 3. logind (Session & Power Management)
* **Control de Sesiones:** `systemd-logind` gestionará el registro de usuarios, asientos (seats) y desbloqueo de dispositivos hardware.
* **Manejo de Energía:** Eventos de energía (cierre de tapa, botón de encendido) delegados a `logind` para su integración con Powerdevil en KDE.
* **Dispositivos sin Privilegios:** Interfaz de acceso seguro a nodos `/dev/input/*` y `/dev/dri/card*` pasando descriptores de archivo a KWin sin requerir root.

## 4. udev (Device Management)
* **Detección Dinámica:** `systemd-udevd` para la gestión en tiempo real de eventos Hotplug (USB, monitores, periféricos).
* **Reglas de Periféricos:** Reglas asignadas en `/etc/udev/rules.d/` para conceder permisos al grupo de usuarios activos.
* **Integración KDE:** Dispositivos de almacenamiento montados mediante UDisks2 e integrados en el plasmoide de gestión de discos.

## 5. GPU / DRM (Direct Rendering Manager)
* **Subsistema del Kernel:** Módulos KMS (Kernel Mode Setting) y DRM activos para renderizado directo en la GPU.
* **Acceso HW:** Soporte para controladores de aceleración 3D (Mesa / DRM i915, amdgpu, o nouveau/nvidia).
* **Buffer Management:** Integración de asignadores GBM (Generic Buffer Management) para la gestión de buffers de pantalla entre el kernel y KWin.

## 6. Wayland (Display Server Protocol)
* **Compositor Principal:** KWin_Wayland se establece como el servidor de despliegue predeterminado.
* **Protocolos Extendidos:** Soporte para extensiones `wl_shell`, `xdg_shell`, y `org_kde_kwin_*`.
* **XWayland:** Capa de compatibilidad `Xwayland` habilitada bajo demanda para aplicaciones heredadas de X11.

## 7. Red (Network Stack)
* **Demonio Principal:** `NetworkManager` como servicio base de red gestionado por systemd.
* **Frontend KDE:** Cliente `plasma-nm` para la gestión de interfaces Ethernet, Wi-Fi y VPNs desde la barra de tareas.
* **Resolución de Nombres:** Integración con `systemd-resolved` para manejo dinámico de DNS y mDNS.

## 8. Audio (Sound Subsystem)
* **Servidor de Audio:** `PipeWire` (con `wireplumber` como gestor de sesión) predeterminado para audio y transmisión de video/pantalla.
* **Compatibilidad ALSA/PulseAudio:** Emulación mediante `pipewire-pulse` y `pipewire-alsa` para garantizar soporte universal.
* **Control KDE:** Control de volumen y ruteo de entradas/salidas gestionado mediante la interfaz de audio de Plasma (`plasma-pa`).

## 9. Rutas de Paquetes (Package & System Layout)
* **Binarios del Sistema:** `/usr/bin/` (Ejecutables globales de KDE y utilidades de ONYX OS).
* **Librerías del Sistema:** `/usr/lib/` o `/usr/lib64/` (Bibliotecas Qt, KDE Frameworks y KF6).
* **Configuración Global:** `/etc/xdg/` (Plantillas de configuración por defecto para KDE).
* **Datos de Aplicación:** `/usr/share/` (Iconos, esquemas de color de Plasma, temas de KWin y archivos `.desktop`).
* **Archivos del Kernel:** `/boot/vmlinuz-onyx` y `/boot/initramfs-onyx.img` para la carga inicial de los módulos base.

---
**Firmado:** Equipo de Desarrollo de ONYX OS & KDE Integration Group
EOF
