#### User management
---------------------

1. ##### Add users

        sudo adduser username
        sudo passwd username

    To add an user to a specific group:

            sudo usermod -aG sudo username


2. ##### Deletion users

        sudo userdel username


    To delete the user's home dir and mail spool:

            sudo userdel -r username


        
    