**Laboratory**

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Lab - 0000 Standalone Server with Oracle Grid (Oracle Restart/Auto Storage Management)](#lab---0000-standalone-server-with-oracle-grid-oracle-restartauto-storage-management)
  - [Prepare infrastructure](#prepare-infrastructure)
- [Links](#links)

<!-- /code_chunk_output -->


## Lab - 0000 Standalone Server with Oracle Grid (Oracle Restart/Auto Storage Management)

Make Oracle Base Installation (Standalone Database Server with Oracle Grid Standalone) in Linux-based env from .rpm; 

Version: **19c**

### Prepare infrastructure
* OS: Rocky Linux 9.4
* RPMs: 
  * oracle-database-preinstall-19c-1.0-2.el8.x86_64.rpm
  * oracle-database-ee-19c-1.0-1.x86_64.rpm
* Root dir according to OFA: */u01*
* Set *ORACLE_BASE*: /u01/app/oracle 
* Env requirements: 
  * umask = 022 (check file /etc/login.defs)
  * DISPLAY: X-Server variable (see samples from: https://askubuntu.com/questions/432255/what-is-the-display-environment-variable)
* The following steps are implemented during preinstall rpm deploy:
  * Create groups *oinstall*, *dba*: *chown oracle:oinstall /u01/app/oracle*
  * Create user *oracle* and provide him privileges: *chown oracle:oinstall /u01/app/oracle*

Use the **Oracle Database Preinstallation RPM** only for the first time, it does

* Automatically downloads and installs any additional RPM packages needed for installing Oracle Grid Infrastructure and Oracle Database, and resolves any dependencies

* Creates an **oracle** user, and creates the oraInventory (**oinstall**) and OSDBA (**dba**) groups for that user

* As needed, sets sysctl.conf settings, system startup parameters, and driver parameters to values based on recommendations from the Oracle Database Preinstallation RPM program

* Sets hard and soft resource limits

* Sets other recommended parameters, depending on your kernel version

* Sets numa=off in the kernel for Linux x86_64 and Linux aarch64 machines.

System **package dependencies**
See https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/supported-oracle-linux-9-distributions-for-x86-64.html

**[Disable Transparent HugePages](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/disabling-transparent-hugepages.html)**

Transparent HugePages memory differs from standard HugePages memory because the kernel khugepaged thread allocates memory dynamically during runtime. Standard HugePages memory is pre-allocated at startup, and does not change during runtime.

Check: 

```
[ilya@localhost oracle_db]$ cat /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]
```

To disable change grub2 parameters: */etc/default/grub*
```
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet numa=off transparent_hugepage=never"
GRUB_DISABLE_RECOVERY="true"
```
And regenrate grub: `# grub2-mkconfig -o /boot/grub2/grub.cfg` then restart

**[Configure disk scheduler](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/setting-the-disk-io-scheduler-on-linux8.html)**

Disk I/O schedulers reorder, delay, or merge requests for disk I/O to achieve better throughput and lower latency.

Linux has multiple disk I/O schedulers available, including mq-deadline, none, kyber, and bfq on Oracle Linux 8 and later, RHEL 8 and later, and SUSE Linux Enterprise Server 15 and later systems. You should consult with your storage vendor for the appropriate I/O scheduler configuration to achieve best performance on Oracle Automatic Storage Management (Oracle ASM).

In general, Oracle recommends that you set the I/O Scheduler to mq-deadline for rotating storage devices (HDDs) and to none for non-rotating storage devices such as SSDs and NVMe on Oracle Linux 8 and later, RHEL 8 and later, and SUSE Linux Enterprise Server 15 and later systems.

On all cluster nodes, enter the following command as root to verify the configured disk I/O scheduler value.

Check:
```
[ilya@localhost oracle_db]$ cat /sys/block/sda/queue/scheduler
none [mq-deadline] kyber bfq
```

## Links
* https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/overview-of-oracle-linux-configuration-with-oracle-rpms.html