#### Backup drive

1. ##### Use *dd*:

1.1. Split the drive into chunks and zip them
dd if=/dev/hda | gzip -c | split -b 2000m - /mnt/smb_share/backup.img.gz

1.2 Restore procedure:

cat /mnt/smb_share/backup.img.gz.* | gzip -dc | dd of=/dev/hda

>[Links!]
>1. [About dd vs dump](http://www.bblisa.org/pipermail/bblisa/2006-December/001101.html)
>2. [About dd](http://wiki.linuxquestions.org/wiki/Dd)