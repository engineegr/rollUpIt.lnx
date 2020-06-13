##### Systemd

1. ##### Основы

    Основной демон управления, загружаемый ядром, - `systemd`, он контролирует юниты:

    - сервисы;

    - сокеты;

    - устройства;

    - точки монтирования;

    - таимерами;

    - цели (target)

     Все компоненты управления описываются через Units, например,

         ```
        #  This file is part of systemd.
        #
        #  systemd is free software; you can redistribute it and/or modify it
        #  under the terms of the GNU Lesser General Public License as published by
        #  the Free Software Foundation; either version 2.1 of the License, or
        #  (at your option) any later version.

        [Unit]
        Description=Run on first boot
        After=ntp.service
        # see https://unix.stackexchange.com/questions/216045/systemd-configure-unit-file-so-that-login-screen-is-not-shown-until-service-exi
        Before=getty@tty1.service getty@tty2.service getty@tty3.service getty@tty4.service getty@tty5.service getty@tty6.service

        [Service]
        # We are sure that the next job  won't be started untill the service is forked and exits unless systemctl will report failure.
        Type=oneshot
        ExecStart=/usr/local/src/post-scripts/rollUpIt.lnx/tests/base/test_runOnFirstBoot.sh

        [Install]
        WantedBy=multi-user.target
         ```

    И хранятся:

    `/etc/systemd/{system | users}` - библиотека пользовательских/системных юнитов

    `/lib/systemmd/` - библиотека системных юнитов

    `/usr/lib/systemd/` - примеры юнитов

    Уровни запуска описываются с помощью target: для запуска определенного юнита на заданном уровне - выставим параметр *WantedBy*

    - rescue.target

    - multi-user.target

    - reboot.target

    - shutdown.target

    - halt,hibernat,hybrid-slip 

    Для установки заданного уровня:

    `systemctl isolate multi-user.target`

2. ##### Зависимости

    Важно: все сервисы запускаются параллельно, за исключением сервисов, для которых жестко выставлена зависимость: секция [Unit] директива `After/Before`.

    *Systemd* играет роль всеобъемлющего демона - он знает какие процессы являются сокетами, и задействуют их только в том случае, если к ним идет подключение, не зависимо является ли сокет сокет IPC-взаимодействия (межпроцессорное взаимодействия) в рамках одной системы (ФС - адресное пространство, взаимодействие идет в рамках одного ядра) или это сокет в рамках Интернет домена (тип - Поточный или Датаграммный). 

    Основные директивы зависимостей (секция Units) - *см. стр 51 - Unix and Linux Admin Handbook*:

    - Require - наиболее строгая зависимость, приводит к выдаче ошибки, если не выполняется

    - Wants - наименее строгое

    - Conflicts - негативная зависимость 

    Противоположные зависимости (WantedBy or RequiredBy): 

    Используем команду `systemctl add-wants multi-user.target my.service` - данный сервис включили в многопользовательский режим. Либо вручную, создав запись в `/etc/systemd/system/multi-user.target.wants/`. Либо мы можем добавить запись WantedBy в секцию [Install], но если сервис выгружен, то она будет проигнорирована.

    Но зависимости Wants,Requires,WantedBy and etc не дают гарантии порядка запуска, systemd определяет порядок запуска на основе директив *After, Before*

    Полезно знать, как вывести все сервисры загруженные до/после:

    `systemctl list-dependencies --before networking`

3. ##### Основные команды

    - `systemctl status <service-name>`

    - `systemctl list-dependencies --before networking`

    - `systemctl status --type=timer`

    - `systemctl --state=failed`
    
    - `systemctl get-default` - return current runlevel (target)

4. ##### Создание/редактирование сервисов

    За основу можно взять коллекцию в /usr/lib/systemd и поместить в `/etc/systemd/{system|user}`, активировав с помощью:

    `systemctl enable <service-name>`

    Для редактирование параметров в уже созданном сервисе потребуется:

    - создать папку /etc/systemd/system/<service-name>.d/ и поместить от одного до несколько файлов `xyz.conf` внутрь и переписав некоторые параметры: 

        ```
        [Unit]
        Requires=
        Requires=ntp.service
        ```

    Далее запустим *systemctl daemon-reload*

    - либо через команды:

    ```
    systemctl edit ntp.service 
    # Edit
    systemctl restart ntp.service
    ```

5. ##### Логирование

    Логирование осуществляется с помощью `journalctl`, но по умолчанию не сохраняются после перезагрузки, для этого: отредактируем `/etc/systemd/journal.conf`:

    ```
    [Journal]
    Storage=persistent
    ```

    Вывод лога загрузки (как альтернатива к dmesg):

    `journalctl --list-boots`

    Состояние сервиса:

    `journalctl -u ntp -xe`

6. ##### Типы сервисов

    - *oneshot* - считается запущенным после того (from activating to inactive), как его процесс завершил выполнение, после этого не является активным (если только не выставлен параметр `RemainAfterExit=`);

    - *simple* - считается запущенным сразу же после выполнения процесса (systemd не заботит результат выполнения).

    - *exec* - то же, что и *oneshot*, но systemd считает данный сервис запущенным успешно, если и дочерний процесс, и родительский завершились успешно;

    - *forking* - создается дочерний процесс, и как только родительский процесс завершает выполение, считается что данный сервис стартовал. Поведение его схоже с традиционными сервисами Unix (SysV Init), поэтому требуется определить `PIDFile=` 

    *Выбор типа сервиса.* (https://unix.stackexchange.com/questions/308311/systemd-service-runs-without-exiting, https://stackoverflow.com/questions/39032100/what-is-the-difference-between-systemd-service-type-oneshot-and-simple)

    Если нам нужен результат запуска сервиса, то следует использовать:

    - simple + заведомо подготовленный сокет;

    - *notify*, *dbus* или *forking* сервисы

    Если мы реализуем long-running задачу, то следует использовать *simple*.
    По умолчанию, тип сервиса - *oneshot*

