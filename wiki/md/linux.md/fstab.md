#### fstab

1. ##### Field 4 - options

*defaults* - use default options: rw, suid, dev, exec, auto, nouser, and async.

The next few sections are what usually scare away newcomers, but they’re really not so complicated.  There’s a large set of options available, but there’s a handful or so of very common ones.  Let’s take a look at them. (The default option is first, followed by alternatives, but as Linux distros can be very different, your mileage may vary.)

*auto/noauto*:  Specify whether the partition should be automatically mounted on boot.  You can block specific partitions from mounting at boot-up by using “noauto”.

*exec/noexec*:  Specifies whether the partition can execute binaries.  If you have a scratch partition that you compile on, then this would be useful, or maybe if you have /home on a separate file system.  If you’re concerned about security, change this to “noexec”.

*ro/rw*:  “ro” is read-only, and “rw” is read-write.  If you want to be able to write to a file-system as the user and not as root, you’ll need to have “rw” specified.

*sync/async*:  This one is interesting.  “sync” forces writing to occur immediately on execution of the command, which is ideal for floppies (how much of a geek are you?) and USB drives, but isn’t entirely necessary for internal hard disks.  What “async” does is allow the command to execute over an elapsed time period, perhaps when user activity dies down and the like.  Ever get a message asking to your “wait while changes are being written to the drive?”  This is usually why.

*nouser/user*:  This allows the user to have mounting and unmounting privileges.  An important note is that “user” automatically implies “noexec” so if you need to execute binaries and still mount as a user, be sure to explicitly use “exec” as an option.

2. ##### Dump/fsck options (field 6)

*Field 5* Indicates whether to use the backup utility dump for the file system. 0 means no backup.

*Field 6.* Indicates the sequence of the file system checks (with the fsck utility) when the system is booted:

0: file systems that are not to be checked

1: the root directory

2: all other modifiable file systems; file systems on different drives are checked in parallel

3. ##### Mount disk info

While */etc/fstab* lists the file systems and where they should be mounted in the directory tree during startup, it does not contain information on the actual current mounts.

The */etc/mtab* file lists the file systems currently mounted and their mount points. The mount and umount commands affect the state of mounted file systems and modify the /etc/mtab file.

The kernel also keeps information for */proc/mounts*, which lists all currently mounted partitions. For troubleshooting purposes, if there is a conflict between /proc/mounts and /etc/mtab information, the /proc/mounts data is always more current and reliable than /etc/mtab.

4. ##### Typical fstab

```
/etc/fstab

# <device>                                <dir> <type> <options> <dump> <fsck>
UUID=CBB6-24F2                            /boot vfat   defaults  0      2
UUID=0a3407de-014b-458b-b5c1-848e92a327a3 /     ext4   defaults  0      1
UUID=b411dc99-f0a0-4c87-9e05-184977be8539 /home ext4   defaults  0      2
UUID=f9fe0b69-a280-415d-a03a-a32752370dee none  swap   defaults  0      0
```

>[Links]
>1. [What is the fstab](https://www.howtogeek.com/howto/38125/htg-explains-what-is-the-linux-fstab-and-how-does-it-work/)
>2. 