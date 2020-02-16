
1. ##### Нормальный LA на сервере виртуального хостинга колеблется от 0 до 2. LA резко увеличивается до 50. Как понять причину повышения нагрузки? Напишите команды для анализа проблемы и вероятные причины начиная с самой вероятной.

    Среднее значение отражает не только нагрузку на процессор, но и количество процессов, находящихся в ожидании ресурсов, их можно разделить на прерываемые и непрерывные. То есть если у нас LA = 50 за минуту, то это может означать, что за минуту 49 процессов находятся в состоянии ожидания процессора, а один занимает его время.

    Найти LA (за 1, 5, 15 мин) можно с помощью следующих команд:

    ```
    uptime
    cat /proc/loadavg
    ```

    Обычно резкое увеличение LA связано с задачами находящимися в непрерывном состоянии (TASK_UNINTERRUPTIBLE): их можно найти с помощью `top` или `ps`, они маркируется состоянием "D" (STAT column). Данные процессы могут быть, к примеру, следствием выполнения операций ввода/вывода на дисковые устройства. Для определения занятости дисковых устройств можем воспользоваться утилитой *iostat* (расширенная статистика использования устройств ввода/вывода с интервалом в 2 секунды):

    `iostat -xd 2 3`

2. ##### Каким образом можно гарантированно ограничить каждого пользователя виртуального хостинга от выедания им всех ресурсов cpu и памяти linux сервера, учитывая что mod_php/mod_perl не установлены?

    Мы можем воспользоваться механизмом Control Group/s, который являются основой реализации Linux контейнеров (LXC):

    - ограничить текущую сессию ядром 0 процессора:

      ```
      mkdir /sys/fs/cgroup/cpuset/group_cpu_core0
      # get PID of the current session
      echo $$ > /sys/fs/cgroup/cpuset/group_cpu_core0/tasks
      echo 0 > /sys/fs/cgroup/cpuset/group_cpu_core0/cpuset.cpus
      ```

    Проверить:

    `cat /proc/$$/status`

    - ограничить по памяти:

    ```
    mkdir /sys/fs/cgroup/memory/group0_128M
    echo $$ > /sys/fs/cgroup/cpuset/group0_128M/tasks
    echo 128M > /sys/fs/cgroup/cpuset/group0_128M/memory.limit_in_bytes
    ```

    Проверить:

    `cat /sys/fs/cgroup/memory/group0_128M/memory.oom_control`

    Более элегантный путь использования cgroups - это постараться вместо них использовать контейнеры LXC, новая версия которых использует улучшенную версию CGroup v2:

     ```
     sudo lxc-create -n JhonWolfDebian -t JhonWolfDebian -f /usr/share/doc/lxc/examples/JhonWolfDebian.conf
     sudo lxc-start -d JhonWolfDebian
     lxc exec JhonWolfDebian -- su JhonWolf
     ```

3. ##### Какие методы для борьбы с исходящим спамом через web скрипты и sendmail существуют в mta postfix и exim? Spamassasin и другие спам фильтры рассматривать не нужно.

    **Прописывать SPF - Sender Policy Framework** - с каких почтовых серверов ожидать почту в нашем домене, например:

    Отредактируем наш файл зоны: `/etc/named/db/example.org`

        ```
        @   86400    IN TXT   "v=spf1 a mx ~all"
        ```

      где

      `v=spf1` - версия SPF,

      `a,mx` - должны существовать записи A, MX для почтового сервера отправителя;

      `-all` - фильтруем отправителей, не прошедших данную верификацию

    Далее идет пример фильтрации спама исходящей почты на примере postfix (добавляем записи в `/etc/postfix/main.cf`).

    **Анализ адреса почтового сервера отправителя.**

    Должны существовать две записи A и PTR, соответсвующие почтовому серверу отправителя и прописано следующее правило (/etc/postfix/main.cf): `reject_unknown_client_hostname`

    Приветствие - заголово HELO - должен включать полное доменное имя почтового сервера отправителя, иначе отбрасываем сообщение:

    ```
    reject_invalid_helo_hostname
    reject_non_fqdn_helo_hostname
    ```

    Запрещаем сервера, для которого не существует A или MX записи: `reject_unknown_helo_hostname`

    **Анализ адреса отправителя.**

    Существует ли домен отправителя: `reject_non_fqdn_sender`

    Существует ли сам отправитель: `reject_unknown_sender_domain`

    Проверяем отправителя: существует ли он на почтовом сервере: `reject_unverified_sender`

    **Анализ имени получателя.**

    Проверка адреса (FQDN) получателя: `reject_non_fqdn_recipient`

    Не отправлять почту получателям, для которых у нас нет почтового ящика: `reject_unlisted_recipient`

    Отправляем только на известные адреса: `reject_unauth_destination`


4. ##### Как организовать ежедневное резервное копирование сервера виртуального хостинга создавая при этом минимум нагрузки на него, учитывая, что он содержит около 10-ти миллионов файлов, а общий объем данных около 300Гб?

    Есть два известных мне продукта, которые позволяют создавать инкрементральное резервное хранилище - rsnapshot и rdiff-backup, как показывает практика шустрее себя ведет rsnapshot. Rsnapshot автоматически создает задачи в cron с временными отрезками *hourly, daily, weekly, monthly*.

    Рассмотрим настройку rsnapshot на примере Debian 9. 

    - Настройка `ssh` 

        Резервное копирование будет проводиться с удаленной машины на локальное хранилище, поэтому сгенерируем закрытый и публичный ключи (`ssh-keygen -t rsa`), скопируем публичный ключ на удаленную машину (`.ssh/autorized_keys`). Предворительно надо настроить `sshd` сервис на удаленной машине на возможность аутентификации с помощью публичного ключа (`/etc/sshd_config`):

        ```
        PubkeyAuthentication yes
        ChallengeResponseAuthentication no
        UsePAM no
        ```

    - Настройка прав доступа (на удаленной машине):

    ```
    sudo chmod -R 700 ~/.ssh/
    sudo chmod 600 ~/.ssh/authorized_keys
    ```

    - Установка: `sudo apt-get install rsnapshot` 

    - Настройка `rsnapshot`

      Пусть

      + `/path/to/bck` - путь, где хранятся снимки;

      + `backup_user@lamp-srv:/path/from/foo` - что резервируем;

      + Конфигурация `/etc/rsnapshot.conf`:

        ```
        snapshot_root /rsnapshot/bck/root

        cmd_cp   /bin/cp
        cmd_ssh /usr/bin/ssh
        cmd_rm          /bin/rm
        cmd_du          /usr/bin/du

        retain  daily   6
        # retain  weekly  4
        # retain  monthly 3

        verbose         2
        loglevel        3
        logfile         /var/log/rsnapshot.log
        lockfile        /var/run/rsnapshot.pid

        backup  backup_user@lamp-srv:/path/to/foo  /path/to/bck
        ```

    - Запуск: `rsnapshot daily`

5. ##### На одного из клиентов виртуального хостинга направлена DDOS атака. Ваши действия по его предотвращению? Как можно настроить linux сервер так, чтобы воздействие ddos атаки на одного клиента минимально сказалось на общей производительности и доступности сервера?

    Основные виды DDoS атак: TCP,UDP,ICMP DDoS атаки. Для борьбы с данными видами атак можно воспользоваться "старым-добрым" `iptables` и его модулями `limit`,`recent` и `SYNPROXY`.

    Защита против *TCP DDoS*

    ```
    # iptables -N syn_flood
    # iptables -A INPUT -p tcp --syn -j syn_flood 
    # не более одного обращения в секунду
    # iptables -A syn_flood -m limit --limit 1/s --limit-burst 3 -j RETURN
    # иначе отбрасываем пакеты
    # iptables -A syn_flood -j DROP
    ```

    Защита против *UDP DDoS* (модуль `recent`)

    ```
    # iptables -N udp_flood 
    # iptables -A INPUT -p udp -j udp_flood
    # iptables -A udp_flood -m state –state NEW –m recent –update –seconds 1 –hitcount 10 -j RETURN 
    # iptables -A udp_flood -j DROP
    ```

    Защита против *ICMP DDoS* (модуль `limit`)

    ```
    # iptables -N syn_flood
    # iptables -A INPUT -p icmp -j icmp_flood 
    # не более одного подключения в секунду
    # iptables -A icmp_flood -m limit --limit 1/s --limit-burst 3 -j RETURN
    # иначе отбрасываем пакеты
    # iptables -A icmp_flood -j DROP
    ```


    Настройка *SYNPROXY*

    Для использования цепочки `SYNPROXY` мы изначально выключаем из работы `conntrack` для целевого трафика `iptables -t raw -I PREROUTING -i "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst -m tcp --syn -j CT --notrack` и перенаправляем его в цепочку `SYNPROXY`:

    ```
    iptables -I INPUT -i "${wan_iface}" -p tcp -m set --match-set   "${in_tcp_port_set}" dst \
        -m conntrack --ctstate INVALID,UNTRACKED \
        -j LOG --log-prefix "iptables [WAN{INVALID_UNTRACKED}->INPUT]"

    iptables -I INPUT -i "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst \
        -m conntrack --ctstate INVALID,UNTRACKED \
        -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
    ```

    для того, чтобы проверить, что TCP-соединение будет установлено: если запрос проходит правило "трех рукопожатий" (SYN/SYN-ACK/ACK), то модуль `SYNPROXY` иницирует новое подключение в `conntrack`. 

    Необходимость в настройке `SYNPROXY` нужна для решения так называемой проблемы "listen state lock", когда сокет, к которому подключается, находится в данном состоянии пока не завершится установка подключения (`SYN/ACK-SYN/ACK`).

    Изначально TCP-flood можно предотвратить отфильтровав `INVALID` пакеты:

    ```
    # /sbin/sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
    # iptables -I INPUT -i "${wan_iface}" -p tcp -m set --match-set \   "${in_tcp_port_set}" dst -m conntrack --ctstate INVALID \
    -j DROP"
    ```

    А SYN-flood с помощью включения cookies:

    ```
    # Enable  permanently
    if [[ -z "$(sed -E -n '/net\.ipv4\.tcp_syncookies/p' /etc/sysctl.conf)" ]]; then
      sed -i -e '$a\\nnet.ipv4.tcp_syncookies = 1' /etc/sysctl.conf
    else
      sed -i -E 's/\#.*net\.ipv4\.tcp_syncookies.*=.*/net.ipv4.tcp_syncookies = 1/' /etc/sysctl.conf
    fi
    ```

    Но это не дает нам возможности избавиться от "listen state lock" сокетов, поэтому используется `SYNPROXY`. За основу данных рассуждений взята статья на http://redhat.com: https://www.redhat.com/en/blog/mitigate-tcp-syn-flood-attacks-red-hat-enterprise-linux-7-beta.

    Пример настройки linux-сервера для работы с iptables и модулем SYNPROXY:

    - настройки параметров ядра: фрагмент из файла `synproxy.sh`: см. https://github.com/gonzo-soc/rollUpIt.lnx/blob/master/libs/lnx_debian09/iptables/synproxy.sh

    ```
    prepareSYNPROXY_FW_RUI() {
      local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
      printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

      # Enable cookies and timestamps: read more https://www.redhat.com/archives/rhl-devel-list/2005-January/msg00447.html
      sysctl -w net/ipv4/tcp_syncookies=1
      # Enable  permanently
      if [[ -z "$(sed -E -n '/net\.ipv4\.tcp_syncookies/p' /etc/sysctl.conf)" ]]; then
        sed -i -e '$a\\nnet.ipv4.tcp_syncookies = 1' /etc/sysctl.conf
      else
        sed -i -E 's/\#.*net\.ipv4\.tcp_syncookies.*=.*/net.ipv4.tcp_syncookies = 1/' /etc/sysctl.conf
      fi

      sysctl -w net/ipv4/tcp_timestamps=1
      if [[ -z "$(sed -E -n '/net\.ipv4\.tcp_timestamps/p' /etc/sysctl.conf)" ]]; then
        sed -i -e '$a\\nnet.ipv4.tcp_timestamps = 1' /etc/sysctl.conf
      else
        sed -i -E 's/\#.*net\.ipv4\.tcp_timestamps.*=.*/net.ipv4.tcp_timestamps = 1/' /etc/sysctl.conf
      fi

      # Exclude NEW established connections from conntrack: new ACK connections will be excluded and be passed to SYN/ACK-SYN/ACK process
      # see https://superuser.com/questions/1258689/conntrack-delete-does-not-stop-runnig-copy-of-big-file
      sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
      if [[ -z "$(sed -E -n '/net\.netfilter\.nf_conntrack_tcp_loose/p' /etc/sysctl.conf)" ]]; then
        sed -i -e '$a\\nnet.netfilter.nf_conntrack_tcp_looses = 0' /etc/sysctl.conf
      else
        sed -i -E 's/\#.*net\.netfilter\.nf_conntrack_tcp_loose.*=.*/net.netfilter.nf_conntrack_tcp_looses = 0/' /etc/sysctl.conf
      fi

      echo 2500000 >/sys/module/nf_conntrack/parameters/hashsize
      sysctl -w net/netfilter/nf_conntrack_max=0
      if [[ -z "$(sed -E -n '/net\.netfilter\.nf_conntrack_max/p' /etc/sysctl.conf)" ]]; then
        sed -i -e '$a\\nnet.netfilter.nf_conntrack_max = 2500000' /etc/sysctl.conf
      else
        sed -i -E 's/\#.*net\.netfilter\.nf_conntrack_max.*=.*/net.netfilter.nf_conntrack_max = 2500000/' /etc/sysctl.conf
      fi

      printf "${debug_prefix} ${GRN_ROLLUP_IT} Exit the function ${END_ROLLUP_IT}\n"
    }
    ```

    - правила `iptables` (при условии, что `iptables -p OUTPUT ACCEPT`):

    ```
    iptables -t raw -I PREROUTING -i "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst -m tcp --syn -j CT --notrack

    iptables -I INPUT -i "${wan_iface}" -p tcp -m set --match-set   "${in_tcp_port_set}" dst \
        -m conntrack --ctstate INVALID,UNTRACKED \
        -j LOG --log-prefix "iptables [WAN{INVALID_UNTRACKED}->INPUT]"

    iptables -I INPUT -i "${wan_iface}" -p tcp -m set --match-set "${in_tcp_port_set}" dst \
        -m conntrack --ctstate INVALID,UNTRACKED \
        -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
    ```

    где 

    - `in_tcp_port_set` - набор открытых портов `ipset` в цепочке `INPUT`;

    - `wan_iface` - WAN интерфейс на сервере;

    Для мониторинга работы SYNPROXY можем воспользоваться командой:
    `# watch -n1 cat /proc/net/stat/synproxy`

6. ##### На OpenVZ ноде LA достигает 300. Как понять причину повышения нагрузки? Напишите команды для анализа проблемы и вероятные причины начиная с самой вероятной.

    На OpenVZ выделяется пул памяти SLM, который одновременно является и физической и виртуальной памятью, сваппингом части SLM управляет хост, на VPS вся память SLM представлена как физическая, хотя на самом деле она свапится, иногда сильно. Отсюда можно сделать вывод, что часть при высоком LA идет обращения к `swap` разделу на хосте: для анализа статистики можно использовать команду `iostat` на хосте.
    Для мониторинга swap-раздела можно использовать следующие команды:

    ```
    # swapon -s
    # cat /proc/swaps
    # free -m
    ```

7. ##### Как смигрировать Xen domU с одной ноды на другую с минимальным даунтаймом при условии что общее дисковое хранилище не используется и в качестве виртуальных дисков используется lvm? Опишите несколько вариантов.

    Рассмотрим сценарий миграции Xen domainU с исходного хоста на новый.

    Алгоритм.

    *Пререквизиты*:

    Путь к образу диска ноды: `/xen/src_XenGuest_001.img`, где располагается корневая система виртуальной машины

    Адреса: 172.17.0.140/25 - исходный хост, 172.17.0.141/25 - целевой хост

    *Шаги*:

    - Настройка параметров миграции: сначала разрешим миграцию, отредактировав файл конфигурации (/etc/xen/xend-config.sxp):
            ```
            (xend-relocation-server yes)
            ```

         Далее разрешим миграцию с определенного хоста:
             ```
             (xend-relocation-hosts-allow '192.168.2.20')
             ```

          Закомментируем следующие параметры: порты должны совпадать на исходном и целевом хостах, - используем значения по-умолчанию

          ```
          #(xend-port            8000)
          #(xend-relocation-port 8002)
          ```

          Данные изменения применим на *исходном и целевом хостах*

    - Новый хост должен иметь доступ к корневому разделу ВМ (которая располагается на старом хосте), то есть к `/xen/src_XenGuest_001.img`: это можно обеспечить монтируя соответствующий раздел NFS (добавляем запись в `/etc/exports` на старом хосте):

        `/xen    172.17.0.141(rw,no_root_squash,async)`, 

        где 172.17.0.141 - адрес нового хоста. 

        Обнoвляем конфигурацию:

        `exportfs -a`

    - Монтируем данный раздел на новом хосте:

        ```
        mkdir /mnt/xen
        mount 172.17.0.140:/xen /mnt/xen
        ```

    - Проверяем что исходная ВМ может быть запущена как на исходном хосте, так и на новом:

        На исходном хосте:

        ```
        # cd /xen
        # xm create src_XenGuest_001.cfg -c
        ```

        На новом хосте:

        ```
        # cd /mnt/xen
        # xm create src_XenGuest_001.cfg -c
        ```

    - Далее производим live-миграцию (выполняем операции на исходном хосте):

        Вычисляем ID исходной гостевой domainU ВМ:

        ```
        # xm list
        Name                                      ID Mem(MiB) VCPUs State   Time(s)
        Domain-0                                   0      864     2 r-----   3995.3
        centos.5-1                                 1      127     1 -b----     82.6

        # xm migrate 1 172.17.0.141 -l 
        ```

    - Смотрим логи;

    Данный метод основан на статьях: 

    - https://www.virtuatopia.com/index.php?title=Migrating_Xen_domainU_Guests_Between_Host_Systems

    - https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/virtualization/chap-Virtualization-Virtualized_guest_installation_overview

    - https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/virtualization/chap-Virtualization-Guest_operating_system_installation_procedures

    - https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/virtualization/chap-virtualization-xen_live_migration

8. ##### Предложите способы ограничения количества одновременных подключений с одного ip (система: LAMP + nginx)? Каковы условия применимости каждого из указанных способов?

    Использовать модуль:

    - ngx_http_limit_conn_module

    Пример ограничения числс соединений с одного ip-адреса, равному одному подключению: 

    ```
    http {
      limit_conn_zone  $binary_remote_addr  zone=perip:10m;
      server {
          location /download/ {
              limit_conn  perip  1;
          }
      }
    }
    ```

    Можно использовать данную директиву, распространяя ограничения на ip-адрес или виртуальный сервер:

    ```
    limit_conn_zone $binary_remote_addr zone=perip:10m;
    limit_conn_zone $server_name zone=perserver:10m;

    server {
        ...
        limit_conn perip 10;
        limit_conn perserver 100;
    }
    ```

    Где, как мы видим, `$binary_remote_addr` и `$server_name` являются ключами.

    Так же в nginx есть модуль ограничения по скорости (nginx_limit_speed_module), тем самым мы можем реализовать простейший шейпинг:

    ```
    http {
      limit_speed_zone  one  $binary_remote_addr  10m;
      server {
          location /download/ {
              limit_speed  one  100k;
          }
      }
    }
    ```

    Ссылка на документацию: http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html