#### Ext4magic

1. ##### Install on Linux Centos:

    Compiling the src receives the following errors:

    "configure: error: You must install the develop packages "ext2fs , blkid , e2p , uuid" to build ext4magic"

    Prerequisites:

    - file-devel
    - bzip2-devel
    - util-linux
    - libuuid-devel
    - e2fsprogs-devel
    - libblkid
    - libblkid-devel
    - zlib-devel
    - file-5.04

2. ##### Restore process:

    - create a copy of fs journal:

    dumpfs 

    - create an image of the partiotion:

    `dd if=/dev/sdb6 of=/mnt/data/restore/dev_sda6_home/dev_sda6.img`

>[Links]
>1. [How to](http://ext4magic.sourceforge.net/howto_en.html)
>2. [How to undelete a bunch of files](https://blog.dbi-services.com/oooooops-or-how-to-undelete-a-file-on-an-ext4-filesystem/)