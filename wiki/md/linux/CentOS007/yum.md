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

    >[!Links]
    > 1. https://jonathansblog.co.uk/yum-cron