#### User management
---------------------

1. ##### Add users

        sudo adduser username
        sudo passwd username

    To add an user to a specific group:

            sudo usermod -aG sudo username


2. ##### Deletion users

    `sudo userdel username`


    To delete the user's home dir and mail spool: `sudo userdel -r username`

3. ##### To create a system user: `adduser -r -s /bin/nologin`

    Where

    `-r`, `--system` : Create a system account.
        
    System users will be created with no aging information in /etc/shadow, and their numeric identifiers are chosen in the SYS_UID_MIN-SYS_UID_MAX range, defined in `/etc/login.defs`, instead of UID_MIN-UID_MAX (and their GID counterparts for the creation of groups).

    Note that useradd will not create a home directory for such an user, regardless of the default setting in /etc/login.defs (CREATE_HOME). You have to specify the `-m` options if you want a home directory for a system account to be created.

4. ##### User password

    - Change:

    `chage -d <date> <Username>`

    - To force a user to change a password on login:

    `chage -d 0 <Username>`

5. ##### Wheel vs sudo

    Also **sudo** allows the ability to run only certain commands as root instead of granting unlimited root privileges. Further, IIRC wheel group members must still know the root password to su whereas that is not the case with sudo.

6. ##### How to generate a sha512 password in CentOS 7?

    Use python:
    `python -c 'import crypt; print(crypt.crypt("somesecret", crypt.mksalt(crypt.METHOD_SHA512)))'`

7. ##### How to empty an user's password?

    - Edit sudoers (to allow the user run `sudo`):

    `user ALL=(ALL) NOPASSWORD:ALL`

    - Delete password:

    `sudo passwd -d $(whoami)`

8. ##### Differences /etc/profile vs /etc/bashrc?

    /etc/profile - run only in interactive shell login unless we get many errors kind of "unbound var": don't run it from .sh scripts.

    /etc/bashrc - run either in interactive shell login or in non-interactive shell login:

[More details](https://devacademy.ru/article/razbiraiemsia-s-failami-etc-profile-i-etc-bashrc/):

>Файл /etc/profile не очень-то отличается от этих файлов. Он используется для задания общесистемных переменных окружения в оболочках пользователя. Иногда это те же переменные, что и в .bash_profile, но этот файл используется для задания первоначальных PATH или PS1 для всех пользователей оболочек системы.

>Помимо .bash_profile, в своем домашнем каталоге вы также часто будете встречать файл .bashrc. Этот файл предназначен для задания псевдонимов команд и функций, используемых пользователями оболочки bash.

>Аналогично тому, как /etc/profile является общесистемной версией  .bash_profile, файл  /etc/bashrc в Red Hat и файл /etc/bash.bashrc в Ubuntu являются общесистемной версией .bashrc.
> Стоит отметить, что в Red Hat реализация /etc/bashrc также выполняет сценариий оболочки в /etc/profile.d, но только если пользовательская оболочка является Интерактивной оболочкой (т.е. Login Shell (стартовой оболочкой))

> Разница проста: файл /etc/profile выполняется только для интерактивных оболочек, а файл /etc/bashrc – как для интерактивных, так и для неинтерактивных. Вообще-то, в Ubuntu файл /etc/profile вызывает файл /etc/bashrc напрямую.

9. ##### exit vs logout?

    Logout will not work on non login shells, like gnome-terminal/x-term or anyother shell you get on telnet,ftp,etc.

    Exit is for any shell, login shell or non-login shell

    Also, when you exit the login shell (assuming the shell is bash), the script `~/.bash_logout` is executed, giving you the opportunity to clean up anything you need before exiting. For example, in my .bash_login, I mount some CIFS remote drives (Windows shares, NAS directories, etc), so when I logout, those mounts are terminated properly.

>[Link]
>1.[How to generate a sha512 password](https://unix.stackexchange.com/questions/52108/how-to-create-sha512-password-hashes-on-command-line)
> 
