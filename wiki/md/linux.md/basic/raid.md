#### RAID (Redundant Arrays Of Inexpensive Disks)

1. ##### Основы

    Репликация может быть достигнута 2 путями:

    - Зеркалирование;

    - Проверка четности (выделяется отдельный диск для хранение контрольной суммы) 

    *Вычисление контрольных сумм.* Контроль четности работает так: все информационные биты в байте складываются по модулю 2 и если число единиц в нем четное - контрольный бит устанавливается в ноль, а если нечетное — в единицу. При считывании данных информационные разряды снова суммируются и полученный результат сравнивается со значением контрольного бита. Если они совпадают - данные верны, а если нет - значения одного или нескольких разрядов ошибочны.

    **RAID уровни**

    - Just a bunch of disk -> объединяет блоки данных для воспроизведения виртуального ЖД;

    - RAID 0 
        Распеределяет данные по нескольким блочным устройствам, считывание/запись происходит при одновременном обращении к данным БУ; надежность такого типа RAID проигрывает в надежности одного БУ;

    - RAID 1 
        Зеркалирование. Запись медленная, но в чтение сравниа с RAID 0.
        Failure tolerance = 1 drive. 

    - RAID 0 + 1 - зеркалирует RAID 0, требуется как минимум 4 БУ

        1a - 1b - 1a - 1b

        2a - 2b - 2a - 2b
        
        3a - 3b - 3a - 3b
        
        4a - 4b - 4a - 4b

    - RAID 1 + 0 - RAID 0 зеркал RAID 1

        1a - 1a - 1b - 1b

        2a - 2a - 2b - 2b
        
        3a - 3a - 3b - 3b
        
        4a - 4a - 4b - 4b

    - RAID 5 
        
        1a - 1b - 1c - 1p
        
        2a - 2b - 2p - 2c
        
        3a - 3p - 3b - 3c
        
        4p - 4a - 4b - 4c

        где p - код четности

        Как видим при RAID 5 коды четности распределяются по блокам всех 4 дисков. Минимальное количество дисков - 3, полезность N - 1, где N - количество БУ, то есть 67% - это полезные данные.
        Контрольные суммы - результат операции XOR: c = a XOR b.
        Производительность при произвольной операции Read-Write = - 10-25% от RAID 0.
        
        При выходе из строя одного БУ, состояние - degrade or critical, для восстановление требуется длительные операции чтения, что может вызвать отказ следующего БУ, массив будет не восстановить.
        Failure tolerance = 1 drive.
        
        RAID5 подвержен проблеме "write hole", когда при обновлении блока четности (XOR) возникают ошибки, блок записывается неверный, и это всплывает при восстановлении данных, существует прием для восстановления ошибок - "scrubbing". В ZFS данная проблема отсутсвует, поэтому RAID 5 в контексте данной ФС называется RAID Z.

    - RAID 6 - используется 2 контрольные суммы, отказоустойчивость - 2 диска, минимальное - 4.

    На уровне ФС ZFS поддерживает разбиение на блоки (stripping), зералирование, RAID 5/6.

    Для того, чтобы избежать провисания по производительности используется hot spares - горячее резервирование - ЖД, который заменит поврежденный на время восстановления RAID - массива.

2. ##### Создание

    Подготовка: создание таблицы разделов GPT и сам раздел, маркируем под RAID.

    RAID 5: 3 drives - minimum

    `mdadm --create /dev/md/md001_rd5 --level=raid5 --raid-devices=3 /dev/sda1 /dev/sda2 /dev/sda3 # make the array as active, after reboot system will discover the array and set as active on itself`

    Данная команда создает символьную ссылку /dev/md/md001_rd5 на /dev/md<i>

3. ##### Управление

    Просмотреть состояние: `watch cat /proc/mdstat`

    Демонтировать массив: `mdadm -S /dev/md/md001_rd5`

    Для восстановление потребуется конфигурационный файл (/etc/mdadm/mdadm.conf или /etc/mdadm.conf) и команда:

    `mdadm -As /dev/md/md001_rd5`

    Конфигурационный файл можно наполнить с помощью команды над активным массивом, но не использовать опцию *DEVICE*, а лучше *UUID*:

    ```
    mdadm --detail --scan
    ARRAY /dev/md/extra metadata=1.2 name=ubuntu:extra UUID=b72de2fb:60b30
    3af:3c176048:dc5b6c8b
    ```

    `mdadm` имеет также режим мониторинга (работает как сервис через *systemd*): для нотификации мы можем использовать MAILADDR и PROGRAM в /etc/mdadm.conf (/etc/mdadm/mdadm.conf), для включения сервиса:

    ```
    sudo update-rc.d mdadm enable

    sudo systemctl enable mdmonitor
    ```

4. ##### Тестирование

    Мы можем симулировать выход из строя одного и ЖД в массиве:

    `mdadm /dev/md/md001_rd5 -f /dev/sda1`

    в /proc/mdstat

    ```
    Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5]
    [raid4] [raid10]
    md127 : active raid5 sda1[F] sda2[3] sda3[1](0)
    2096886784 blocks super 1.2 level 5, 512k chunk, algo 2 [3/2] [UU_]
    unused devices: <none>
    ```

    в /var/log/messages:

    ```
    $ sudo tail -1 /var/log/messages
    Apr 10 16:18:39 ubuntu kernel: md/raid:md127: Disk failure on sdg1,
    disabling device.#012md/raid:md127: Operation continuing on 2 devices.
    ```

5. ##### Замена поврежденного диска

    - Отмечаем диск как поврежденный:
    
    `mdadm --manage /dev/md/md001_rd5 -f /dev/sda2`

    - Удаление диска/partition:

    `mdadm --manage /dev/md/md001_rd5 -r /dev/sda2`

    - Копируем таблицу разделов с живого диска: если в основе - GPT, то используем утилиту `gdisk`, иначе - `sfdisk`:

    `sgdisk -R /dev/sda1 /dev/sdb1`

     Или

    `sfdisk -d /dev/sda1 | sfdisk /dev/sdb1`

    - Далее выбираем UUID для новой таблицы разделов:

    `gdisk -G /dev/sdb1`

    - Далее добавляем диск:

    `mdadm --manage /dev/md/md001_rd5 --add /dec/sdb1`

6. ##### Добавление spare-диска/партиции

    `mdadm /dev/md/md001_raid005 --add-spare /dev/sda4`

7. ##### Вывод детальной информации

    `mdadm --detail --query /dev/md/md001_raid005`

8. ##### Расширение существующего массива

    Делаем все то же, что и при замене поврежденного диска, но на последнем шаге выполняем операцию `grow`:

    `mdadm --grow /dev/md/md001_rd5 --raid-device=4 --backup-file=/mnt/backup/md001_rd5`

9. ##### Восстановление массива

    Восстановление массива происходит с помощью backup файла: загружаемся с LiveCD (если у нас на массиве хранился корневой раздел, к примеру) и далее

    `mdadm --assemble /dev/md0 /dev/sda1 /dev/sda2 /dev/sda3 --backup-file=/mnt/backup/md001_rd5`

    Для того, чтобы восстановить с нуля массив из-под LiveCD:

    `mdadm -A --scan`

10. ##### Миграция на LVM (LVM root partitions, RAID 10 based, CentOS 7)

    Сценарий: мигрировать существующую систему на LVM (LVM boot, root), где в основе LVM лежит RAID 1 + 0 (RAID 0 зеркал)

    Пререквизиты: на всех 4 ЖД создадим GPT таблицу разделов и один раздел.

    Шаги:

    - Создание RAID10:
        
        `mdadm --create /dev/md/md001_rd10 --raid-device=4 --level=raid10 /dev/sda1 /dev/sda2 /dev/sda3 /dev/sda4`

    - Создадим *PV* из данного раздела;

    - Создадим *VG DATA*;

    - Создание LVs: *lv000_boot (2G), lv001_root (10 G), lv002_home (8 GB), lv003_var (4 G), lv004_tmp (2 G), lv005_swap (1G)*

    - Миграция: мы можем смигрировать **root** раздел без необходимости загрузки с LiveCD, для этого смонтируем существующий корневой раздел через `-o bind`:

        ```
        # mkdir -p /mnt/old/root
        # mount -o bind / /mnt/old/root
        ```

        То же самое проделаем в отношении к остальным разделам: *boot, var, home*

        Копируем с помощтю *rsync* (**ОБРАТИ ВНИМАНИЕ**: применяем --exclude= опцию для того, что исключить */mnt*, иначе начнем копировать в новый *root* самого себя):

        `sudo rsync -avr --exclude='/mnt/*' /mnt/old/root/ /mnt/new/root/ 2>&1 | tee ~/Workspace/Sys/cp_root_$(13032020_1340).log`

    - Обновим */etc/fstab*: UUID можем взять из вывода команды `blkid`

    - Переходим в chroot-jail нашей новой корневой системы:

        ```
        mount -o bind /dev /mnt/new/root/dev
        mount -o bind /sys /mnt/new/root/sys
        mount -o bind /proc /mnt/new/root/proc
        chroot /mnt/new/root
        ```

    - Делаем boot резервную копию:
    
        `tar cfvz /root/Workspace/Sys/backup/boot/boot_130320201556.tar.gz /boot`

    - После обновления необходимо переустановить загрузчик, обновить информацию о GRUB2 для загрузчика (stage-2):

        `grub2-install /dev/sda` - указываем то блочное устройство, на котором распалагается наш загрузочный раздел (на RAID массив загрузчик не ставится, то есть операция `grub2-install /dev/md127` не проходит, не ставится также на каждый диск по отдельности, находящийся в RAID, если они имеют таблицу разделов GPT).

    - Далее потребуется найти UUID нашего RAID массива и добавить параметр командной строки, передаваемый ядру ОС (`/etc/default/grub`). Также укажем название нашего LVM корневого раздела:

        `GRUB_CMDLINE_LINUX="crashkernel=auto console=ttyS0,115200 console=tty0 rhgb debug rdloaddriver=raid10 rdloaddriver=raid1 rd.md.uuid=d8a02b5a:26f11160:e7600b8f:a1ffa884 rd.lvm.lv=DATA/lv001-root"`


    - Обновляем grub и initramfs:
    
        ```
        grub2-mkconfig -o /boot/grub2/grub.cfg
        dracut -v -f /boot/initramfs-$(uname -r).img $(uname -r) 2>&1 | tee /root/Workspace/Sys/backup/dracut_130320201602.log
        ```

        Примечание: можем принудительно добавить RAID драйвер и обновить все initramfs:

        `dracut --regenerate-all -fv --mdadmconf --fstab --add=mdraid --add-driver="raid1 raid10 raid456"`

        (см. https://forums.centos.org/viewtopic.php?t=54901)

>[Links]
>1. [Migrate from single-partition boot device to LVM in CentOS7](
https://www.linuxsysadmins.com/migrate-single-partition-boot-device-to-lvm/)
>2. [RAID couldn't be loaded by dracut](https://forums.centos.org/viewtopic.php?t=54901)
>3. [Why dracut can't load RAID automatically in CentOS 7](https://unix.stackexchange.com/questions/266119/md-raid-not-mounted-by-dracut)
>4. [How to reinstall grub2 in CentOS 7](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/sec-reinstalling_grub_2)