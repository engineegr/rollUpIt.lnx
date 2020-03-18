#### Control groups

1. ###### Control Groups. Basic.

There is 12 sub system belong to cgroup:

blkio — устанавливает лимиты на чтение и запись с блочных устройств;

cpuacct — генерирует отчёты об использовании ресурсов процессора;

cpu — обеспечивает доступ процессов в рамках контрольной группы к CPU;

cpuset — распределяет задачи в рамках контрольной группы между процессорными 
ядрами;

devices — разрешает или блокирует доступ к устройствам;

freezer — приостанавливает и возобновляет выполнение задач в рамках контрольной группы

hugetlb — активирует поддержку больших страниц памяти для контрольных групп;

memory — управляет выделением памяти для групп процессов;

net_cls — помечает сетевые пакеты специальным тэгом, что позволяет 
идентифицировать пакеты, порождаемые определённой задачей в рамках контрольной группы;

netprio — используется для динамической установки приоритетов по трафику;

pids — используется для ограничения количества процессов в рамках контрольной группы.

2. ###### Question 002

Каким образом можно гарантированно ограничить каждого пользователя виртуального
хостинга от выедания им всех ресурсов cpu и памяти linux сервера, учитывая что
mod_php/mod_perl не установлены?

Мы можем воспользоваться механизмом CGroups, который являются основой реализации Linux контейнеров (LXC):

- ограничить текущую сессию ядром 0 процессора:

```
mkdir /sys/fs/cgroup/cpuset/group_cpu_core0
# get PID of the current session
echo $$ > /sys/fs/cgroup/cpuset/group_cpu_core0/tasks
echo 0 > /sys/fs/cgroup/cpuset/group_cpu_core0/cpuset.cpus
```

Проверить:

```
cat /proc/$$/status 
```

- ограничить по памяти:

```
mkdir /sys/fs/cgroup/memory/group0_128M
echo $$ > /sys/fs/cgroup/cpuset/group0_128M/tasks
echo 128M > /sys/fs/cgroup/cpuset/group0_128M/memory.limit_in_bytes
```

Проверить:

```
cat /sys/fs/cgroup/memory/group0_128M/memory.oom_control
```

Более элегантный путь использования cgroups - это постараться вместо них использовать контейнеры LXC), новая версия которых использует улучшенную версию CGroup v2:

 ```
 sudo lxc-create -n JhonWolfDebian -t JhonWolfDebian -f /usr/share/doc/lxc/examples/JhonWolfDebian.conf
 sudo lxc-start -d JhonWolfDebian
 lxc exec JhonWolfDebian -- su JhonWolf
 ```
