#### Boot process

1. ##### Boot process

    Загрузочный процесс начинается с того, что CPU загружает из ROM утилиты BIOS/UEFI, которая проводит проверку системы (Power On Self Test), загружает сохраненные параметры из CMOS, определяет блочное устройство, с которого будем загружаться, и 

    *BIOS (Basic Input Output System)*: находит Master Boot Record (состоит из firts stage boot-loader, обычно файл boot.img и примитивной таблицы разделов) и запускает с нее first stage boot-loader (~ 512 bytes), это первый этап, тот в свою очередь загружает second-stage bootloader (core.img), который в состоянии считать информацию о таблице разделов загрузочного устройства, и запустить загрузчик ОС (Grub, LILO and etc), это второй этап.

    GRUB загружает выбранный образ ядра и initramfs, initramfs размещается в RAM в tempfs ФС. Данный подход называется initrd. Ранее initramfs назывался initrd и размещался на блочном устройстве. 

    Second stage boot loader (aka filesystem driver, core.img) живет в "мертвой зоне" после MBR и перед первым разделом на диске (который должен начинаться с 64ого блока - 64 * 512 B = 32 KB), то есть его размер ~ 32 KB - 512 B.

    *UEFI (Unified Extensible Firmware Interface)* имеет отдельный раздел ESP (EFI System Partition, FAT), который хранит информацию о boot target application (стандартный путь - /efi/{boot|Ubuntu}/bootx64.efi:

    UEFI понимает *GUID Partition Table* и считывает информацию о ESP и приложении, которое на нем хранится для обращения к boot target. Boot target может быть Grub, LILO, само ядро ОС Linux.
    UEFI также определяет API для обращения к железу, мы можем обращаться к настройкам UEFI из-под OS:

    ```
    efibootmgr -v 

    BootCurrent: 0004
    BootOrder: 0000,0001,0002,0004,0003
    Boot0000* EFI DVD/CDROM PciRoot(0x0)/Pci(0x1f,0x2)/Sata(1,0,0) Boot0001* EFI 
    Boot0001* EFI Hard Drive PciRoot(0x0)/Pci(0x1f,0x2)/Sata(0,0,0)
    Boot0002* EFI Network PciRoot(0x0)/Pci(0x5,0x0)/MAC(001c42fb5baf,0)
    ```

    Так для смены порядка загрузки (загрузка с сети):

    ```
    efibootmgr -o 0002,0001
    ```

2. #### Grub

    Конфигурация хранится в /boot/grub/grub{2}.cfg, для смены очередности загрузки, параметров загрузки ядра, установки пароля обращаемся к */etc/grub.d/40_custom*, а для смены переменных GRUB - к `/etc/default/grub`

    Для загрузки в single mode - добавляем { 1 | single | -s | systemd.unit=rescue.target}

    Для создания/обновления конфигуации grub:
    ```
    grub{2}-mkconfig --output /boot/grub2/grub.cfg
    ```

    или 

    ```
    update-grub
    ```
