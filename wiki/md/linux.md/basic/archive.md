#### Архивы

1. ##### Копирование папки в режиме архива, промежуточным сжатием

    `# rsync -arRv $src $dst, where`, где 

    - a - режим архива; аналогично -rlptgoD (no -H,-A,-X)
    - r - рекурсивно
    - R - сохраняет относительный путь, т.е. src = /home/ws/proj; dst = /backup
    тогда на выходе будет /backup/home/ws/proj
    - z - compression
    - v - verbose

    rsync
    Used links:
    https://linux.die.net/man/1/rsync
    https://serverfault.com/questions/180853/how-to-copy-file-preserving-directory-path-in-linux


2. ##### Как создать архив (tar)?

    `# tar cfvz $dst $src, where`

     -c - create archive
     -f - destination archive name (test.tar.gz, for example)
     -v - verbose
     -z - compression mode (gzip)
     -j - bzip2
     --lzip - lzip
     --lzma - lzma
     --lzop - lzop
     --zstd - zstd

     **Важно:**

     1) Мы можем определить тип архивирования на основе названия выходного файла (используем `--auto-compress`):
         `$ tar caf archive.tar.bz2 .`

     2) Сжатый архив не может изменяться. 

         Опции 
         
         `--update, -u` 

         `--delete`
         
         `--append, -r`
         
         `--concatenate, -A`

         Не работают

3. ##### Как просмотреть архив?

    `# tar --list --file=<file_name> $path_to_file`


    >[Links] 
    > 1. https://www.gnu.org/software/tar/manual/tar.html#SEC135
    > 2. tar + rsync tips: https://unix.stackexchange.com/questions/30953/tar-rsync-untar-any-speed-benefit-over-just-rsync


4. ##### Создание архива и транспортировка его через pipe с использованием ssh и cat?

    `tar cvfz - ./opt | ssh likhobabin_im@192.168.145.1 "cat > /Users/likhobabin_im/Workspace/backup/gns3-vm/gns3-vm_opt_projects/17032019/$(date +%Y%m%d_%H%M)_opt_gns3_vm.tar.gz"`

    >[Links] 
    > 1. https://unix.stackexchange.com/questions/70581/scp-and-compress-at-the-same-time-no-intermediate-save

5. ##### Find + tar + ssh

    `# find . -mindepth 1 -maxdepth 1 -not -regex "$rexp" -print0 | xargs -0 tar cvpfz - | ssh "$2" "cat > $3"`

    >[Links] 
    > https://www.linuxquestions.org/questions/linux-general-1/using-find-%7C-tar-%7C-ssh-to-transfer-files-changed-in-the-last-24-hours-936356/

6. ##### Прогресс-бар с tar

    `tar cf - /folder-with-big-files -P | pv -s $(($(du -sk /folder-with-big-files | awk '{print $1}') * 1024)) | gzip > big-files.tar.gz`