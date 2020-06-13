#### LVM

1. ##### Основы

    Преимущества:

    - перемещение LV между физическими ЖД;

    - Изменение размеров LV налету;

    - Создание резервных копий;

    - Замена нагорячую ЖД в пуле VG;

    LVM состоит из

    - Physical group: сюда входят физические устройства, RAID массивы, разделы

    `pvcreate /dev/sdb5`

    - Volume group: это пул ресурсов откуда LV черпает ресурсы

    `vgcreate vg_001 /dev/sdb5`

    - Logical volume

    `sudo lvcreate -L 5G -n lv_001 vg_001`

    Что умеют:

    Physical volume: pv {create; change; display}; pvck;

    Volume group: vg {create; display; change; extend}; vg {ck; scan};

    Logical volume: lv {create, change; displya; resize}

2. ##### Создание snapshot

    - Свободное место под snapshot_dst >= lv_src

    - Snapshots - фиксированного размера, как и логические тома;

    - Перед создание snapshot лучше демонтировать источник

    `sudo lvcreate -L 2G -s -n DATA_lv001-snap DATA/DATA_lv001` , где DATA - volume group

3. ##### Изменение размера LV

    В большую сторону:

    - Увеличиваем LV: деактивируем LV (если мы имеем snapshot на данный LV)

    - Увеличиваем ФС: `resize2fs`

    Отдельно о `resize2fs`: поддерживает изменение размера налету, если ядро от the Linux 2.6

    Если мы захотим изменить размер существующего раздела, то придется перестроить раздел с помощью fdisk (номер начального цилиндра должен совпадать).

    Extra: как мигрировать существующую ФС на LVM - https://www.thegeekdiary.com/centos-rhel-converting-an-existing-root-filesystem-to-lvm-partition/
    Как восстановить LVM из-под LiveCD: https://zeldor.biz/2011/01/mount-lvm-from-livecd/

    В меньшую сторону: делаем наоборот

4. ##### Миграция root to lvm-root (на примере CentOS 7)

    - Создание LVM-раздела для новой / партиции;

    - Загрузка из-под *Live-CD* (например, SystemRescueCD), монтирование старого "/", нового LVM "/", копирование со старого:

    `tar -cvpf - --one-file-system --acls --xattrs --selinux -C /mnt/old/root/ . | tar -C /mnt/new/root/ -xf`

    **Далее все делаем из-под рабочей исходной среды (не из-под Live-CD)**
    
    - Монтируем и делаем chroot:

    ```
    mount --bind /dev /mnt/new/root/dev
    mount --bind /sys /mnt/new/root/sys
    mount --bind /proc /mnt/new/root/proc
    mount /path/to/boot/partition /mnt/new/root/boot
    chroot /mnt/new/root
    ```

    - Обновляем */etc/fstab* информацию о новом корневом разделе: найти UUID можно с помощью:

    `blkid -p /dev/POOL_VG001/lv001_root | sed -E 's/.*UUID=(".*")\sVER.*/\1/g'`

    - Обновляем ФС инициализации (initramfs): перед этим создадим */var/tmp*, чтобы избежать ошибки https://github.com/rear/rear/issues/1455
    
    `dracut -f /boot/initramfs-$(uname -r).img $(uname -r)` 
    
    - Обновляем наш *GRUB*: 

    `grub2-mkconfig -o /boot/grub2/grub.cfg`

    Link: http://cjcheema.com/2019/06/how-to-recover-or-rebuild-initramfs-in-centos-7-linux/

    Дополнения: 

    1. После миграции сломалась аутентификация из-за SELinux (ошибка **systemd-logind: Failed to start user slice user-1000.slice, ignoring: Access denied (org.freedesktop.DBus.Error.AccessDenied)**): 
    см. https://unix.stackexchange.com/questions/229989/new-centos-install-login-broken.
    https://www.linuxsysadmins.com/migrate-single-partition-boot-device-to-lvm/(ищи по *SELinux* и *autorelabel*)
        Решение: создать *.autorelabel* в корне ("/")

    2. Для сохранения возможности загрузки со старого корневого раздела: добавим *menuentry* и укажем старый *initramfs image* и UUID старого корневого раздела:

        ```
        17:09:07 ~ cat /etc/grub.d/40_custom
        #!/bin/sh
        exec tail -n +3 $0
        # This file provides an easy way to add custom menu entries.  Simply type the
        # menu entries you want to add after this comment.  Be careful not to change
        # the 'exec tail' line above.

        menuentry 'CentOS Linux (3.10.0-957.10.1.el7.x86_64) 7 (Core) Old root' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-957.10.1.el7.x86_64-old-root-advanced-992583ae-e430-43fe-a808-850efee2c01a' {
                load_video
                set gfxpayload=keep
                insmod gzio
                insmod part_msdos
                insmod xfs
                set root='hd0,msdos1'
                if [ x$feature_platform_search_hint = xy ]; then
                  search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1 --hint-baremetal=ahci0,msdos1 --hint='hd0,msdos1'  62134c46-014c-477a-a5c9-6036d4f183b1
                else
                  search --no-floppy --fs-uuid --set=root 62134c46-014c-477a-a5c9-6036d4f183b1
                fi
                linux16 /vmlinuz-3.10.0-957.10.1.el7.x86_64 root=UUID=e7ca1c26-634a-4c10-9366-bfb60a0d5f9f ro crashkernel=auto rhgb debug
                initrd16 /initramfs-3.10.0-957.10.1.el7.x86_64-old-root.img
        }
        ```

        Далее необходимо обновить конфигурацию Grub (`/boot/grub2/grub.cfg`):

        `sudo grub2-mkconfig -o /boot/grub2/grub.cf` (CentOS 7)

5. ##### Замена ЖД в LVM

    - Создаем новый pv из ЖД, на который мигрируем;

    - Добавляем новый PV ЖД в существующую VG:

    `sudo vgextend DATA /dev/loop1`

    - Используем `pvmove` с опцией `-n <LV_NAME>`, если хотим перетащить только заданный LV, при этом мы можем прервать данную операцию и продолжить снова просто запустив `pvmove` без аргументов:

    `pvmove -n data1 /dev/loop0 /dev/loop1`

    - Удаляем старый PV:

    `vgreduce vg001 /dev/loop0`


