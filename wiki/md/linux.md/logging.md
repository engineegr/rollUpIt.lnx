#### Logging

0. ##### System logs

    - System boot log: `dmesg`
    - Logging about user login: `wtmp` to watch the log: `last`
    - Last logging: `lastlog` (stored inside `wtmp`)

1. ##### Journald

    - To configure settings of `journald` we need to create a configuration set inside `/etc/systemd/journald.conf.d`

    - One of the major setting is to save `journald` logs on drive (`/var/log/journal`): to archieve it we must set option `Storage=persistent`:

    ```
    add_conf_dir="/etc/systemd/journald.conf.d/"
    add_storage_conf="${add_conf_dir}"/storage.conf

    if [[ ! -e "${add_storage_conf}" ]]; then
        mkdir /etc/systemd/journald.conf.d/
        cat << END > /etc/systemd/journald.conf.d/storage.conf 
    [Journal]
    Storage=persistent
    END
        systemctl restart systemd-journald
    fi
    ```

2. ##### Rsyslog

    - Config files: `/etc/rsyslog.conf` and `/etc/rsyslog.d`
    - Don't just exit the daemon with `TERM` if you want to compress or rotate log files. Before that send `HUP` signal:
    ```
    sudo kill -HUP `/bin/cat /var/run/syslogd.pid`
    ```

>[!Notes]
>1. To color logs: use `grc` or `ccze` app