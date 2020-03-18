#### yum
---------

1. ##### Maintain yum 
    
    1. Install `yum-cron`:

            yum install yum-cron

        >[!Notes]
        > yum-cron is an alternate interface to yum that is optimised to be convenient to call from cron. It provides methods to keep repository metadata up to date, and to check for, download, and apply updates. Rather than accepting many different command line arguments, the different functions of yum cron can be accessed through config files.

    2. Turn on `yum-cron`:
            
            systemctl enable yum-cron
            systemctl start yum-cron

    3. To configure `yum-cron`: edit **/etc/yum/yum-cron.conf**:

        If there are updates available **the daily cron** is set to download but not install the available updates and send messages to **stdout**. The default configuration is sufficient for critical production systems where you want to receive notifications and do the update manually after testing the updates on test servers. To change the behavior and install updates we need to edit `commands` section: set `apply_updates` to *yes*, to send email when yum-cron finds new updates, we need to set `emit_via = stdio,email` in **emitters** section:

        ```
        [commands]
        update_cmd = security
        update_messages = yes
        download_updates = yes
        apply_updates = no
        random_sleep = 360

        [email]
        email_from = root@centos.host
        email_to = me@example.com
        email_host = localhost
        ```
        

    >[!Links]
    > 1. https://jonathansblog.co.uk/yum-cron