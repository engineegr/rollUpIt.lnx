##### UDEV

1. ###### HAL

    - HAL - описывает абстракцию устройств (представляет устройства ввиде виртуальных устройств для ядра)

    - DBUS - Desktop BUS - позволяет информацию об оборудовании от ядра передать программам на пользовательском уровне

    - UDEV - работает на уровне пользователя и позволяет взаимодействовать с устройствам. Работает по событиям.


2. ##### Виртуальная ФС Devtmpfs /dev/

    Данный каталог содержит файловые записи (драйверы устройств) всех обнаруженных устройств, при чем при выводе через `ls -ha` выдаст нам информацию о типах устройств:

    - b - блочное (хард-диски и т.д.)
      
    - c - символьное устройство (teletype - терминалы)

    и т.д.

    Данный каталог представляет собой виртуальную ФС Devfs (хранится в RAM)
    Данная организация каталога устройств позволяет обращаться к устройствам с пользовательского пространства.

    Устройства могут отображаться в несколько файлов, таким образом система обращается к версии драйвера и экземпляру устройства (major номер - версия драйвера, minor - экземпляр устройства):

    ```
    ls -laht sda
    brw-rw----. 1 root disk 8, 0 Mar  2 21:26 sda
    ```

    Устройства различаются по типу: блочные (считывают несколько байт за раз) и символьные (один байт за раз).
    Когда приклодное ПО обращается к устройству ядро перехватывает данный запрос и отправляет нужную команду из таблицы на драйвер устройства.

    В редких случаях мы можем создать собственное устройство через `mknod` команду. 

3. ##### Sysfs -> /sys

    Информацию, конфигурация, состояние устройств и udev выстраивает данные устройства ввиде дерева (/sys/devices); при чем блочные устройства попадают в /sys/block, если у наc на них есть драйвера. udev берет данные об устройства из /sys каталога.

    *Sys* включает:

    devices - все найденные устройства

    bus - устройства шин PCI, USB, SCSI (шина объединяющая разнотипные устройства: hardrive, optical drive and etc)

    dev - блочные и символьные устройства

    class - иерархически выстроенная директория по типу устройств

    firmware - информация о hardware подсистемах ACPI

    kernel - internal and virtual память, используемая на ядре

    power - состояние питания системы

4. ##### ProcFS -> /proc

    - информацию о процессах;

    - информацию о процессоре: /proc/cpuinfo;

    - информацию о том куда и что смонтировано;

    - мы также можем менять конфигурацию ядра через параметры в /proc/sys

5. #### Обнаружение устройств

    `lsmod` - device module info

    `lspci` - pci devices

    `lspcmcia` - pcmcia cards

    `lshal` - HAL devices

    `lshw` - all hardware

    `lsusb` - usb devices

6. ##### Udev command

    `settle` - дождаться завершения всех событий в Udev

    `info` - информация об устройстве
    Все пути, характеризующие устройства в sys, выводятся относительно /sys.

    `trigger` - звпустить событие

    `control` - управление демоном

    `monitor` - следить за устройствами (монитор событий ядра - `sudo udevadm monitor -k -p`)

    `test` - симуляция событий (`sudo udevadm test /proc/sys/`)

7. ##### Module control

    `lsmod` - list all installed module

    `modinfo` 

    `rmmod` - remove a module

    `insmod`    

    `modprobe` - intellectual install a module

8. ##### Устройства и ядро

    Ядро взаимодействует с устройством через специализированный язык и драйвер.

9. ##### Udev конфигурация

    /etc/udev/udev.conf
    /etc/udev/rules.d/ - правила обнаружения устройств
    /lib/udev/rules.d/

10. ##### Правила устройств

    Udev опирается на правила для обнаружения устройств: правила ищут соответствие по атрибутам устройств (можем найти через `udevadm info --path=/sys/...`), за поиск соответствия отвечает match, за действие assign_clause:

    `match_clause, [match_clause, ...] assign_clause, [ assign_clause, ... ]`

    Match_clause: `<Key>{<Operator>}=<Value>`, например, `ATTR{size}=="1974271"`.

    Key - свойства устройства, либо действие - добавление, удаление:

    **ACTION** - тип события

    **ATTR{filename}** - атрибут устройства (взятый из /sys)

    **DEVPATH** - путь к устройству

    **DRIVER** - драйвер устройства

    **ENV{key}** 

    **KERNEL** - имя устройства, определяемое на уровне ядра

    **PROGRAM** - запуск внешней программы, определяет соответствие, если запуск вернул 0

    **RESULT** - определяет соответствие со значением, которое было возвращено PROGRAM 

    **SUBSYSTEM** 

    **TEST{omask}** - существует ли файл

    Правила обрабатываются в соответствии с лексическим порядком: [nn]-[rule-name].rules

    Например, напишем правило обнаружения USB флешки: /etc/udev/rules.d/10-local.rules

    - Определим атрибуты для соответствия: `udemadm info -p /sys/block/sdb`

    - Созадим правило соответствия

    ```
    ATTR{model}=="Transend-USB-2.8", KERNEL=="sd[a-z]1"
    # Создадим ссылку на устройство в /dev
    SYMLINK+="my-flash%n"
    ```
    
    - Добавим правила действия: смонтируем в определенный раздел
    
    ```
    ACTION=="add", ATTRS{model}=="USB2FlashStorage", KERNEL=="sd[a-z]1", 
    # Что будем делать после нахождения устройства
    RUN+="/bin/mkdir -p /mnt/ate-flash%n"

    ACTION=="add", ATTRS{model}=="USB2FlashStorage", KERNEL=="sd[a-z]1", 
    # Что делаем во время поиска соответствия
    PROGRAM=="/lib/udev/vol_id -t %N", RESULT=="vfat", 
    # Как только нашли, монтируем
    RUN+="/bin/mount vfat /dev/%k /mnt/ate-flash%n"
    ```

    - Далее обновим систему:

    ```
    udevadm control --reload-rules
    ```

    Пример 2. Монтирование/размонтирование флэшки 

    ```
    # filter sdb5 extended partition
    # ENV{ID_FS_UUID}=="82f7d8dc-7ad1-4317-87ec-9a93fc52406a",KERNEL=="sd[a-z]5",SYMLINK+="super-flash_%k"
    ATTRS{model}=="Transcend 128GB ",KERNEL=="sd[a-z]?",SYMLINK+="super-flash_%k"

    # ACTION=="add",ENV{ID_FS_UUID}=="82f7d8dc-7ad1-4317-87ec-9a93fc52406a",KERNEL=="sd[a-z]5",RUN+="/bin/mkdir -p /mnt/super-flash_%k"
    ACTION=="add",ATTRS{model}=="Transcend 128GB ",KERNEL=="sd[a-z]?",RUN+="/bin/mkdir -p /mnt/super-flash_%k"

    # ACTION=="add",ENV{ID_FS_UUID}=="82f7d8dc-7ad1-4317-87ec-9a93fc52406a",KERNEL=="sd[a-z]5",PROGRAM=="/usr/bin/lsblk -n -o FSTYPE %N | tr -d '\n'",RESULT="ext4"
    ACTION=="add",ATTRS{model}=="Transcend 128GB ",KERNEL=="sd[a-z]?",PROGRAM=="/usr/bin/lsblk -n -o FSTYPE %N | tr -d '\n'",RESULT=="ext4",RUN+="/usr/bin/mount -t ext4 /dev/%k /mnt/super-flash_%k"

    # ACTION=="add",ENV{ID_FS_UUID}=="82f7d8dc-7ad1-4317-87ec-9a93fc52406a",KERNEL=="sd[a-z]5",RUN+="/usr/bin/mount -t ext4 /dev/%k /mnt/super-flash_%k"
    # ACTION=="add",ATTRS{model}=="Transcend 128GB ",KERNEL=="sd[a-z]?",RUN+="/usr/bin/mount -t ext4 /dev/%k /mnt/super-flash_%k"

    ENV{dir_name}="/mnt/super-flash_%k"

    # Точки монтирования почему-то не удаляются
    ACTION=="remove",ATTRS{model}=="Transcend 128GB ",KERNEL=="sd[a-z]?",RUN+="/usr/bin/umount %E{dir_name} && /usr/bin/rmdir %E{dir_name}"
    ```

11. ##### Отладка правил

    Симуляция: `sudo udevadm test --action=remove /sys/block/sdb/sdb5`

    Логирование: `sudo udevadm control --log-priority=info` => события будут отображаться в `/var/log/messages` (CentOS 7)
