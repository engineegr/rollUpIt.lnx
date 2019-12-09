#### Unattended upgrade

1. ##### Prepare: `apt-get install unattended-upgrades apt-listchanges`

    2. ##### Edit `/etc/apt/apt.conf.d/50unattended-upgrades` to set which packets to be upgrade:

Example 001.
```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
Unattended-Upgrade::Mail "**YOUR_EMAIL_HERE**";

// Automatically upgrade packages from these 
Unattended-Upgrade::Origins-Pattern {
      "o=Debian,a=stable";
      "o=Debian,a=stable-updates";
      "o=Debian,a=proposed-updates";
      "origin=Debian,codename=${distro_codename},label=Debian-Security";
};

// You can specify your own packages to NOT automatically upgrade here
Unattended-Upgrade::Package-Blacklist {
//      "vim";
//      "libc6";
//      "libc6-dev";
//      "libc6-i686";

};

Unattended-Upgrade::MailOnlyOnError "true";
Unattended-Upgrade::Automatic-Reboot "false";
```

proposed-updates are Stable-proposed-updates is an apt repository that contains the files that are being prepared for the next Debian/Stable point release =>  As mentioned above, packages in **stable-proposed-updates** aren't yet officially part of Debian Stable and one should not assume they have the same quality and stability (yet!). Those new versions of the packages needs to be reviewed (by the stable release manager) and tested (by some users) before entering stable.

**Unofficial statement**: However, the quality is usually very high (It should still be considered higher quality than Debian Testing, Backports... ) You are welcome to test those updates if you can recover minor problems (but don't test on production servers ;-).

3. ##### When to run upgrade: editor `/etc/apt/apt.conf.d/20auto-upgrades`

```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

4. ##### Example of unattended installation grub-pc: it initiates a dialog (need to avoid it):

Use keys:
```
grub-pc grub-pc/mixed_legacy_and_grub2  boolean true
grub-pc grub2/device_map_regenerated    note
grub-pc grub2/kfreebsd_cmdline  string
grub-pc grub-pc/install_devices_disks_changed   multiselect     /dev/disk/by-id/ata-VBOX_HARDDISK_VB38163666-39861de7
grub-pc grub2/kfreebsd_cmdline_default  string  quiet
grub-pc grub-pc/install_devices multiselect     /dev/disk/by-id/ata-VBOX_HARDDISK_VB38163666-39861de7-part1
grub-pc grub-pc/timeout string  5
grub-pc grub2/force_efi_extra_removable boolean false
grub-pc grub-pc/install_devices_failed  boolean false
grub-pc grub-pc/install_devices_failed_upgrade  boolean true
grub-pc grub-pc/kopt_extracted  boolean false
grub-pc grub2/update_nvram      boolean true
grub-pc grub-pc/install_devices_empty   boolean false
grub-pc grub-pc/postrm_purge_boot_grub  boolean false
grub-pc grub-pc/hidden_timeout  boolean false
grub-pc grub2/linux_cmdline_default     string  quiet
grub-pc grub2/linux_cmdline     string  ipv6.disable_ipv6=1 net.ifnames=0 biosdevname=0 net.ifnames=0 biosdevname=0
grub-pc grub-pc/chainload_from_menu.lst boolean true
```

To reconfigure the package:

`sudo dpkg-reconfigure grub-pc`

To set the key:
```
echo grub-pc grub2/linux_cmdline     string  ipv6.disable_ipv6=1 net.ifnames=0 biosdevname=0 net.ifnames=0 biosdevname=0
echo grub-pc grub-pc/install_devices_disks_changed   multiselect     /dev/disk/by-id/ata-VBOX_HARDDISK_VB38163666-39861de7 | sudo debconf-set-selections
echo grub-pc grub-pc/install_devices multiselect     /dev/disk/by-id/ata-VBOX_HARDDISK_VB38163666-39861de7-part1 | sudo debconf-set-selections

```

*Requirements*: `apt-get install debconf-utils`

>[Links]
>1. [How to Setup Unattended Upgrades on Debian 9 (Stretch)] https://www.vultr.com/docs/how-to-set-up-unattended-upgrades-on-debian-9-stretch
>2. [How to reconfigure a package](https://www.tecmint.com/dpkg-reconfigure-installed-package-in-ubuntu-debian/)
>3. [How to set a key](https://unix.stackexchange.com/questions/106552/apt-get-install-without-debconf-prompt)
>4. [Bug with grub-pc](https://github.com/hashicorp/vagrant/issues/289)
>5. [habrahabr о unattended updates](https://habr.com/ru/company/flant/blog/330406/)

