### Bugs in Cent OS 007
------------------------

1. ##### CentOS setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
*To fix:*

Add
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
to 
/etc/environment

>[Note!]
> LC_ALL - It forces applications to use the default language for output
> 
> You'll typically set $LANG to your preference with a value that identifies your region (like fr_CH.UTF-8 if you're in French speaking Switzerland, using UTF-8). The individual LC_xxx variables override a certain aspect. LC_ALL overrides them all. The locale command, when called without argument gives a summary of the current settings.
> 

2. ##### When launch *locale*:

        -bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8)

*To fix:*

Comment SendEnv LANG LC_\* in */etc/ssh_config* on the host that you connect from with *ssh* 

3. ##### Fixing There are unfinished transactions remaining. You might consider running yum-complete-transaction first to finish them in CentOS 007

> [!Note]
> yum-complete-transaction(8) – Linux man page
> yum-complete-transaction is a program which finds incomplete or aborted yum transactions on a system and attempts to complete them. It looks at the transaction-all* and transaction-done* files which can normally be found in /var/lib/yum if a yum transaction aborted in the middle of execution.
> 
> If it finds more than one unfinished transaction it will attempt to complete the most recent one first. You can run it more than once to clean up all unfinished transactions.

*To fix:*

        sudo yum install yum-utils
        sudo yum-complete-transaction --cleanup-only
        sudo yum update 

4. ##### When try to use user services we get the following error:
        
        Failed to get D-Bus connection: No such file or directory

*To fix:* No fix is available for CentOS7/RHEL

5. ##### kernel: [drm:vmw_host_log [vmwgfx]] *ERROR* Failed to send host log message.

Solution: Change video graphic controller to VBoxVGA

6. ##### systemd-udevd: invalid key/value pair in file /usr/lib/udev/rules.d/59-fc-wwpn-id.rules on line 12, starting at character 25 (';')

Solution: Edit /usr/lib/udev/rules.d/59-fc-wwpn-id.rules - replace *;* with *,*
[link](https://bugzilla.redhat.com/show_bug.cgi?id=1750417)
