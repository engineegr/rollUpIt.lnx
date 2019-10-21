#### Sys diagnostic

1. ###### Kernel

    *How to know about kernel crash?*

    Firstly user `kdump` mechanism: it writes dumps locally or remotely then we can analyze a problem root

    *How to analyze a dump?*

    Use `crash` command. It can be used to analyze dumps:

    **netdump**

    Loads and configures the netdump kernel modules. Once these are loaded, when the kernel crashes it will send the oops message and a dump of physical memory to the machine that runs the **netdump-server**. This can then be used to debug the problem using gdb and a kernel image.

    **diskdump**

    Diskdump works by taking absolute control of the system when a panic occurs. It shuts down all interrupts to keep the processor from getting distracted; it also freezes all other processors on SMP systems. It then checksums its own code, comparing against a value computed at initialization time; if the checksums fail to match, diskdump assumes that it has been corrupted as a result of whatever went wrong and refuses to run.

    The next step involves finding a place to store the crash dump. Diskdump can be set up with multiple dump partitions. For each possibility, it queries the state of the driver, then reads and verifies the entire crash dump space. The diskdump authors are (rightly) fearful of overwriting important data while the system is in an unstable state, so diskdump requires that every block of the crash dump partition be initialized with a special pattern. If any blocks fail the test, that destination will not be used.

    **kdump**

    Создается два ядра: основное и аварийное (именно оно используется для сбора дампа памяти). При загрузке основного ядра под аварийное ядро выделяется определенный размер памяти. При помощи kexec во время паники основного ядра загружается аварийное и собирает дамп.

    *How to differ virtual vm from physical?*

    `dmidecode -t system | grep "Product name"`

    *How to know when a fs was checked lastly?*

    ```
    tune2fs -l <DeviceName> | grep 
    ```

    *How to check filesystem forcely?*

    Create a file **forcefsck** in a partition root.

    *How to automatically mount/umount a filesystem?*

    Use service `automounter`: it can automatically umount a fs when it is idle

    *How to load in a single mode?*

    change parameters of linux16/vmlinuz (compressed kernel) from `ro` to `rw init=/sysroot/bin/bash`
    To permamently change of grub parameters:
    Edit the appropriate kernel line in /etc/grub.d/40_custom or /etc/defaults/grub

    *Input/output*

    *How to check status of input/output?*

    `sar`
    `iostat`
    `vmstat`

    *How to know which process listens and what ports?*

    `netstat` - show info about network connections: `netstat -ltnp` (`l` - listening,  `t` - tcp, `n` - numeric, `p` - process ID)

    `fuser` - shows the PIDs of processes using the specified files or file systems in Linux: `fuser 80/tcp`

    `lsof` - shows all open files: `lsof -i :80`

    About GPT/MBR see (https://www.howtogeek.com/193669/whats-the-difference-between-gpt-and-mbr-when-partitioning-a-drive/)

    *How to check linux distributive version?*

    - Linux CentOS / Redhat:

    See the following files:
    ```
    /etc/centos-release
    /etc/os-release
    /etc/redhat-release
    /etc/system-release
    ```

    *How to know who logins now?*

    `who -u`

    `lastlog` - history of login

    `pkill -9 -u <usernmae>` - kill all user's sessions.

    *How to check password for quality?*

    Linux CentOS
    Password quality is set in `/etc/security/pwquality.conf`
    To check a password use `pwscore`


    *How to know what method is used for passwords encryption?*

    `authconfig --test`

    `grub-crypt --sha-512` - to generate an encrypted password

    *How to sync two folders?*

    If you want the contents of folders A and B to be the same, put /home/user/A/ (with the slash) as the source. This takes not the folder A but all of it's content and puts it into folder B. Like this:

    `rsync -avut --delete "/home/user/A/" "/home/user/B"`
    where

    -a Do the sync preserving all filesystem attributes
    
    -v run verbosely
    
    -u only copy files with a newer modification time (or size difference if the times are equal)
    

    --delete delete the files in target folder that do not exist in the source
    
    Manpage: https://download.samba.org/pub/rsync/rsync.html

    >[!Note]:
    >1. [25 Question on the job review] (https://habr.com/ru/post/280093/)
    >2.[About GPT/MBR](https://www.howtogeek.com/193669/whats-the-difference-between-gpt-and-mbr-when-partitioning-a-drive/)
    >3. [About password encryption](https://thornelabs.net/posts/hash-roots-password-in-rhel-and-centos-kickstart-profiles.html)

