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
