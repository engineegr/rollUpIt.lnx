#### Partitions

1. ##### Создание разделов (MBR): fdisk

    Типы разделов:

    - primary: в MBR мы можем создать до 4 разделов, так как MBR слишком мала, чтобы хранить больше информации о разделах - всего 512 Byte, информация о каждом разделе занимает 16B, значит общее количество информации о 4 primary разделов или 3 primary + 1 extended = 64B. 

    - раcширенный: это контейнер, в который мы помещаем логические диски, для сохранения информации о логических дисках выделяется 2048 sectors (1 sector = 512B), т.е. между 4ым и 5ым разделами, где 4 - extended, а 5 - logical, а это в сумме дает - 2048 * 512B = 1 048 576 B => количество extended разделов = 65536 штук, но на практике MBR таблица разделов поддерживает до 60 разделов => 3 primary, 1 extended + 56 logical. 

        links:

        - https://unix.stackexchange.com/questions/5730/whats-the-limit-on-the-no-of-partitions-i-can-have

        - https://en.wikipedia.org/wiki/Fdisk

    - logical 

    Для создания раздела используем fdisk: создадим 1 extended раздел + 1 logical: see https://codingbee.net/rhcsa/rhcsa-creating-partitions

    После создания мы можем узнать все о созданных разделах с помощью `lsblk, parted` программ.

    После создания разделов мы можем изменить ID раздела: тип файловой системы (FreeBSD, Linux - ext3/4/ | xfs, NTFS and etc). Для этого надо зайти в `fdisk` и выбрать ключ t.

2. ##### Создание ФС на примере ext4

    Используем `mkfs -t ext4 /dev/sdb2` команду

    Узнать всю информацию о созданном разделе можно с помощью blkid:

    ```
    sudo blkid -p /dev/sdb5
    ```

    Информация о геометрии устройства (размер сектора): `sudo blkid -i /dev/sdb`

