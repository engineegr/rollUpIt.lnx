#### Remote System Installation
--------------------------------

1. ##### PXE - Preboot Execution Environment

PXE - a mini OS 

PXE => ROM of network controller 
PXE <= API => BIOS

How a client load a boot image from TFTP?

Client gets the suitable DHCP responce on a DISCOVERY packet with **PXE flag turned on.** The repsonce consists a **tftp-server** and a **boot file** addresses

2. ##### How to setup PXE?
2.1 [SYSLINUX boot loaders](http://syslinux.org) has a H. Peter Anvin’s **PXELINUX**: it locates a boot file into a tftp-server's **tftpboot** dir. So that we downloads a boot loader and a config file. It is hardware independent and can be used for Windows image deploying. 

3. ##### How to cook PXE with PXELINUX ?
3.1. Prerequisite: 
- SYSLINUX image, kernel or any initrd images: we need just install syslinux package;
- DHCP, tftp - servers.

So that the necessary packages:
```
yum install dhcp tftp tftp-server syslinux wget vsftpd
```

3.2 Boot folder structure:

/tftpboot : 
- pxelinux.0 (from syslinux image, it is a **bootloader** file name) + vmlinuz + initrd (from a CentOS iso - images/pxeboot/) 
- config files are stored in the pxelinux.cfg: because more than one system may be booted from the same server, the configuration file name depends on the IP address of the booting machine so taht it can be IP, MAC or UUID:
```
    /mybootdir/pxelinux.cfg/b8945908-d6a6-41a9-611d-74a6ab80b83d
    /mybootdir/pxelinux.cfg/01-88-99-aa-bb-cc-dd
    /mybootdir/pxelinux.cfg/C0A8025B
    /mybootdir/pxelinux.cfg/C0A8025
    /mybootdir/pxelinux.cfg/C0A802
    /mybootdir/pxelinux.cfg/C0A80
    /mybootdir/pxelinux.cfg/C0A8
    /mybootdir/pxelinux.cfg/C0A
    /mybootdir/pxelinux.cfg/C0
    /mybootdir/pxelinux.cfg/C
    /mybootdir/pxelinux.cfg/default
```
where C0A8025B - IP addres in hex - 192.168.2.91

3.3 DHCP Config

*Basic*

```
    allow booting;
    allow bootp;
    
    # Standard configuration directives...
    
    option domain-name "domain_name";
    option subnet-mask subnet_mask;
    option broadcast-address broadcast_address;
    option domain-name-servers dns_servers;
    option routers default_router;
    
    # Group the PXE bootable hosts together
    group {
        # PXE-specific configuration directives...
        next-server TFTP_server_address;
        filename "/tftpboot/pxelinux.0";
        
        # You need an entry like this for every host
        # unless you're using dynamic addresses
        host hostname {
            hardware ethernet ethernet_address;
            fixed-address hostname;
        }
    }
```
*Important*: if your particular TFTP daemon runs under **chroot** (`tftp-hpa` will do this if you specify the "-s" (secure) option; this is highly recommended), you almost certainly should not include the /tftpboot prefix in the filename statement. 

3.4 [Basic plot: pxe,tftp,dhcp](https://www.unixmen.com/install-pxe-server-centos-7/)

>[!Definition]
>1. initrd - In computing (specifically in regards to Linux computing), initrd (initial ramdisk) is a scheme for loading a temporary root file system into memory, which may be used as part of the Linux startup process. An image of this initial root file system (along with the kernel image) must be stored somewhere accessible by the Linux bootloader or the boot firmware of the computer. The bootloader will load the kernel and initial root file system image into memory and then start the kernel, passing in the memory address of the image. At the end of its boot sequence, the kernel tries to determine the format of the image from its first few blocks of data, which can lead either to the initrd or initramfs scheme. 
>2. Initrd and vmlinuz. The initrd is just a scheme of final root filesystem, it is a primar root file system but the vmlinuz is a kernel of the OS, it consists of all object files needed for the OS to function. It is compliled from source and placed from /usr/src/linux/arch/i386/linux/boot/bzImage to /boot/vmlinuz. The initrd is bound to the kernel and loaded as part of the kernel boot procedure. The kernel then mounts this initrd as part of the two-stage boot process to load the modules to make the real file systems available and get at the real root file system. The initrd contains a minimal set of directories and executables to achieve this, such as the insmod tool to install kernel modules into the kernel.

>[!Links]
>1. [What is VMLINUZ and Difference between VMLINUZ and INITRD](http://postsbylukman.blogspot.com/2017/06/what-is-vmlinuz.html)
>2. [PXELINUX](https://wiki.syslinux.org/wiki/index.php?title=PXELINUX)

