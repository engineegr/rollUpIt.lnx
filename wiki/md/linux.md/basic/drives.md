#### Drives

Тут приводится работа с новым жестким диском.

1. ##### Identification

    Определить установленный диск можно с помощью lsblk: `lsblk -o +MODEL,UUID,SERIAL`

2. ##### Создание таблицы разделов: MBR/GPT, раздела и ФС

    Утилиты: parted (не понимает GPT), gparted (GUI verison of parted, can recognize and install GPT), fdisk, cfdisk, sfdisk.

    Для создания GPT-таблицы используем ключ g в fdisk.

    При создании ФС на разделе диска мы можем выставить LABEL, который далее используется для идентификации раздела в fstab и при выполнении монтирования с помощью mount:

    ```
    sudo mkfs -t ext4 -L spare /dev/sdb1
    ```

    fstab:

    ```
    LABEL=spare /spare ext4 errors=remount-ro 0 0
    ```

3. ##### Sector Size

    Традиционно размер сектора равен 512 B, но современные ЖД адресуют сектора размером 4 KiB, но эмулируют 512 B сектор - 512e

4. ##### Storage Hardware interface

    - Serial ATA - 6 Gb/s, hot swapping and command queuing (организация очередей команд)

    - PCI - 16 Gb/s, M.2 - union SATA, PCI and USB 3.0 

    - SAS - Serial SCSI (Small Computer Serial Interface) - 12 Gb/s

    5. ##### Ephemeral device names

    Никогда не полагайся на буквенное наименование ЖД (/dev/sda), так как ядро может изменить данное наименование для заданного ЖД

6. ##### hdparam and camcontrol

    Данные утилиты могут обращаться напрямую к firmware ЖД и изменять его параметры: для выдачи полной информации о ЖД - `hdparam -I `; `camcontrol devlist`

    `hdparam` можно использовать в целях *secure erase*:

    ```
    $ sudo hdparm --user-master u --security-set-pass password /dev/disk
    $ sudo hdparm --user-master u --security-erase password /dev/disk
    ```

7. ##### SMART

    Для теста ЖД с помощью SMART используем smartmontools package, который включает smartd деймон, утилиту управления smartctl, конфигурация:

    `/etc/smartd.conf`


    Those four sensitive SMART parameters are
        
    • Scan error count

    • Reallocation count

    • Off-line reallocation count

    • Number of sectors on probation

    SMART can predicts about 64 % of failures.