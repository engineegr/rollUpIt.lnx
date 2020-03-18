#### UEFI

0. ##### Немного фактов

    UEFI видит все типы (FAT16/32, ext4 and etc) разделы, для которых в конкретной реализации прошивки имеются драйверы. ESP же отличается от остальных разделов только тем, что а) для FAT драйвер иметь обязательно и б) на разделе ESP осуществляется поиск загрузчиков и автоматическое создание соответсвующих переменных BootXXXX, если загрузчики нашлись.

    Раздел ESP призван объединить все точки загрузки для разных ОС: debian, centos, windows and etc.

    В Linux есть управленец всеми точками загрузки - *efibootmgr*, он действует напрямую через UEFI и изменяет его параметры (они записываются в NVRAM): он умеет добавлять/удалять/менять порядок точек загрузок, таким образом нам даже GRUB не нужен, мы можем напрямую загрузить нужный нам дистрибутив.

    `efibootmgr -o 0001,000A,0003` - меняем порядок загрузки

    `efibootmgr -b 001 -B` - удаляем точку загрузки

1. ##### Создание загрузочного раздела FAT32 ESP (CentOS 7)

    - Устанавливаем следующие пакеты:
    
        ```
        yum -y install dosfstools efibootmgr efivar grub2-efi shim
        ```

        Примечание: пакеты `grub2-efi, shim` записывают UEFI-версию загрузчиков в `/boot/efi/centos/`. Мы можем перестроить их просто перустановив: `yum reinstall grub2-efi, shim`. Также они создают UEFI-версию grub.cfg в `/etc/grub-efi.cfg`.

    - Создание GPT раздела и форматирование его в FAT32 (используем parted):
    
         ```
         parted /dev/sda mklabel gpt
         mkpart primary fat32 2048s <end-sector>s 
         ```

    - Для загрузки в UEFI через GRUB мы оставляем `/boot/` раздел, создаем внутри него папочку `/boot/efi` и монтируем туда наш раздел FAT32:

        ```
        sudo mount /dev/sdb8 /mnt/root 
        sudo mount /dev/sdb6 /mnt/root/boot 
        sudo mount /dev/sdb2 /mnt/root/boot/efi

        sudo mount --bind /dev /mnt/root/dev &&
        sudo mount --bind /dev/pts /mnt/root/dev/pts &&
        sudo mount --bind /proc /mnt/root/proc &&
        sudo mount --bind /sys /mnt/root/sys

        sudo chroot /mnt/root
        ```
    
    - Устанавливаем EFI GRUB на наш загрузочный диск /dev/sda (там, где размещается boot раздел, не ESP-раздел):
    
        ```
        grub2-install --target=x86_64-efi --efi-directory=/boot/efi/ --bootloader-id={anyname} --boot-directory=/boot /dev/sda
        ```

        **Важно:** здесь мы указываем на БУ (/dev/sda), где размещается загрузочный раздел - `mount /dev/sda1 /boot`. В результате создается EFI точка входа с названием <anyname> и с тем же названием папка в `/boot/efi/EFI/<anyname>`

    - Генерируем EFI-версию grub:

        `grub2-mkconfig -o /boot/grub2/grub.cfg`

        Нужно обратить внимание, что опции загрузки ядра ОС и первичной RAM FHS (initrd) для EFI имеют характерные имена - `initrdefi` и `linuxefi`, если мы тут укажем `initrd` или `linux`, то это вызовет сбой и loop-загрузку точки входа меню:

        ```
        ### BEGIN /etc/grub.d/10_linux ###
        menuentry 'CentOS Linux (3.10.0-1062.12.1.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-1062.12.1.el7.x86_64-advanced-ffb4798f-6586-4308-a3a5-c91f944b8930' {
            load_video
            set gfxpayload=keep
            insmod gzio
            insmod part_msdos
            insmod xfs
            set root='hd0,msdos1'
            if [ x$feature_platform_search_hint = xy ]; then
              search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1 --hint-baremetal=ahci0,msdos1  daac344e-def0-47db-8f55-9575114e6bbd
            else
              search --no-floppy --fs-uuid --set=root daac344e-def0-47db-8f55-9575114e6bbd
            fi
            linuxefi /vmlinuz-3.10.0-1062.12.1.el7.x86_64 root=/dev/mapper/DATA-lv001--root ro crashkernel=auto console=ttyS0,115200 console=tty0 rhgb debug rdloaddriver=raid10 rdloaddriver=raid1 rd.md.uuid=d8a02b5a:26f11160:e7600b8f:a1ffa884 rd.lvm.lv=DATA/lv001-root
            initrdefi /initramfs-3.10.0-1062.12.1.el7.x86_64.img
        }
        ```

        **Стоит отметить**, что файл конфигурации grub.cfg обязателен для `/boot/efi/EFI/centos/`, но дополнительные точки входа могут ссылаться на `/boot/grub2/grub.cfg` (т.е. для **/boot/efi/EFI/grub/** grub.cfg необязателен), что приведет к отказу загрузки в BIOS-режиме:)

    - Добавляем запись в /etc/fstab:

        `UUID=13A6-95A2                            /boot/efi vfat umask=0077,shortname=winnt 0 0`

    - Ошибки:
    
        В VirtualBox получаем ошибку Guru при запуске в UEFI-режиме, исправляем:
        
        `VBoxManage setextradata pxe-srv_centos_7-1810  VBoxInternal/EM/TripleFaultReset 1`

**Дополнение**
    
- Основываясь на замечаниях из [habra-habr](https://habr.com/ru/post/314412/) статьи, можно воспользоваться загрузчиком systemd-boot (скопировать из /usr/lib/systemd/boot/efi/systemd-bootx64.efi) и подготовить под него структуру файлов в /boot:

        ```
        /boot/efi/loader/loader.conf
        cat loader.conf

        default     archlinux
        timeout     10
        editor      1
        ```

    Далее создаем каталог `entries`: каждый `.conf` файл является точкой входа для загрузки ОС:

        ```
        title          Arch Linux
        linux          /efi/archlinux/vmlinuz-linux
        initrd         /efi/archlinux/initramfs-linux.img
        options        root=/dev/mapper/vg1-lvroot rw initrd=\EFI\archlinux\intel-ucode.img
        ```

    Примечание: автоматический установщик CentOS 8 создает/подключает переменные (из `/etc/grub.d/00_header`) в `/boot/efi/EFI/centos/grub.cfg` и использует их в `/boot/loader/entries/<menu-entry 001>.conf`. Сами переменные могут определяться в `/boot/grub2/grubenv` или `/boot/efi/EFI/centos/grub2/grubenv`. Данную структуру установщик создает с помощью `grub2-switch-to-blscfg` (только для **CentOS 8**): 

            ```
            [root@localhost ~]# cat /boot/loader/entries/f620e5ae41694b8499fd1f338b4f2d03-4.18.0-147.el8.x86_64.conf
            title CentOS Linux (4.18.0-147.el8.x86_64) 8 (Core)
            version 4.18.0-147.el8.x86_64
            linux /vmlinuz-4.18.0-147.el8.x86_64
            initrd /initramfs-4.18.0-147.el8.x86_64.img $tuned_initrd
            options $kernelopts $tuned_params
            id centos-20191204215851-4.18.0-147.el8.x86_64
            grub_users $grub_users
            grub_arg --unrestricted
            grub_class kernel
            ```

    Переменные:
    - `$tuned_initrd` -> `./efi/EFI/centos/grub.cfg:set tuned_initrd=""`
    
    - `$kernelopts` -> `./efi/EFI/centos/grubenv:kernelopts=root=UUID=80c961de-0c21-44a3-b8e2-e7916053edea ro crashkernel=auto resume=UUID=2872386b-5c35-4987-a8ff-67fe1989616a rd.md.uuid=7b7ef199:b99816b0:c17d198b:a30da901 rhgb quiet`
    
    Где root UUID -> UUID нашего RAID-массива ; resume UUID -> UUID swap; rd.md.uuid=7b7ef199:b99816b0:c17d198b:a30da901 -> UUID `/dev/md/mdXXX`    

    - `$tuned_params`-> `./efi/EFI/centos/grub.cfg:set tuned_params=""`

2. ##### Продвинутый загрузчик rEFInd (http://www.rodsbooks.com/refind/)

- Качаем `src` с git-репозитория

- Ставим зависимости: `yum -y gnu-efi gnu-efi-devel`

- Строим/инсталлируем: `$(src_dir)/make && make install`
Перед этим редактируем пути в Make.common:

    ```
    EFIINC          = /usr/include/efi
    GNUEFILIB       = /usr/lib64
    EFILIB          = /usr/lib
    EFICRT0         = /usr/lib64/gnuefi
    ```

- Появится 2 папки: /boot/efi/EFI/{Boot-rEFInd-Backup,tools} - вторая пустая, вообще, скрипт не устанавливает полностью то, что нужно, поэтому копируем вручную в /boot/efi/EFI/Boot-rEFInd-Backup файл *$(src)/refind/refind_x64.efi и $(src)/icons/, $(src)/refind.sample.conf -> refind.conf*. Переименовываем папку по своему разумению `Boot-rEFInd-Backup -> rEFInd`

- Создаем запись в UEFI с помощью efibootmgr:

    `efibootmgr -c -d /dev/sdb -L "rEFIind" -l \\EFI\\rEFInd\\refind_x64.efi`

- **Profit!**

>[Links] 
>1. https://habr.com/ru/post/314412/
>2. https://www.thegeekdiary.com/centos-rhel-7-how-to-reinstall-grub2-from-rescue-mode/
>3. https://askubuntu.com/questions/831216/how-can-i-reinstall-grub-to-the-efi-partition
>4. https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/anaconda_customization_guide/sect-boot-menu-customization


