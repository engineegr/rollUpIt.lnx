#### SELinux
-------------

1. ##### Get status

    SELinux is enabled by default on the CentOS 7, to **get status**:

    `sestatus`

2. ##### Configure SELinux for TFTP server

    2.1 Check status

    `getsebool -a | grep tftp`

3. ##### Permissive mode

    When SELinux is running in **permissive mode**, SELinux policy is not enforced. The system remains operational and **SELinux does not deny any operations but only logs AVC messages**, which can be then used for troubleshooting, debugging, and SELinux policy improvements. Each AVC is logged only once in this case.
    To make any change to SELinux, first modify /etc/selinux/config and change the policy to **permissive**:

    ```
    # vim /etc/selinux/config

             # This file controls the state of SELinux on the system.
             # SELINUX= can take one of these three values:
             # enforcing – SELinux security policy is enforced.
             # permissive – SELinux prints warnings instead of enforcing.
             # disabled – No SELinux policy is loaded.
             SELINUX=permissive
             # SELINUXTYPE= can take one of three two values:
             # targeted – Targeted processes are protected,
             # minimum – Modification of targeted policy. Only selected processes are protected.
             # mls – Multi Level Security protection.
             SELINUXTYPE=targeted
    ```

>[!Links]
>1. http://www.cyberphoton.com/tftp-server-in-rhel7/
>2. https://docs.fedoraproject.org/en-US/quick-docs/changing-selinux-states-and-modes/