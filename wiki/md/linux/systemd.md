#### Systemd
-------------

1. ##### Units
    1. What can be a **Unit**?
    
    - a service;
    
    - a socket;
    
    - a device
    
    - a mount point
    
    - an automount point
    
    - a swap file or partition
    
    - a startup target
    
    - a watched filesystem path
    
    - a timer controlled and supervised by systemd
    
    - a resource management slice
    
    - a group of externally created processes
    
    2. Unit Structure
    ```
    [Unit]
    Description=The nginx HTTP and reverse proxy server After=network.target remote-fs.target nss-lookup.target
    [Service]
    Type=forking
    PIDFile=/run/nginx.pid ExecStartPre=/usr/bin/rm -f /run/nginx.pid ExecStartPre=/usr/sbin/nginx -t ExecStart=/usr/sbin/nginx ExecReload=/bin/kill -s HUP $MAINPID KillMode=process
    KillSignal=SIGQUIT
    TimeoutStopSec=5
    PrivateTmp=true
    [Install] 
    WantedBy=multi-user.target
    ```

2. ##### General command
    1. List of units: `systemctl list-units --type=service`
    2. Change operation mode to the specified target: `systemctl isolate multiuser.target` - The isolate subcommand is so-named because it activates the stated target and its dependencies but deactivates all other units.
    3. To get current target: `systemctl get-default`
    4. To set permanently: `systemctl set-default target`

    >[Targets]
    > 1. poweroff.target (0 - runlevel)
    > 2. emergency.target - system recovery (emergency)
    > 3. rescue.target - single-user mode (1)
    > 4. multi-user.target - cmd line only (2)
    > 5. multi-user.target - networking (3)
    > 6. multi-user.target - not normally used in init (2)
    > 7. graphical.target
    > 8. reboot.target

3. ##### Dependencies
    Systemctl starts services based on technique called **demand-on**:
    **systemd** takes over the functions of the old *inetd* and also extends this idea into the domain of the **D-Bus interprocess communication system**. In other words, systemd knows which network ports or IPC connection points a given service will be hosting, and it can listen for requests on those channels without actually starting the service. If a client does materialize, systemd simply starts the actual service and passes off the connection. The service runs if it’s actually used and remains dormant otherwise.

    **systemd** assumes that the average service is an add-on that shouldn’t be running during the early phases of system initialization. Individual units can turn off these assumptions with the line in [Unit] section.
            
            DefaultDependencies=false

    Explicit deps:

     - WantedBy=<service001> - service001 requires the current service to start to complete own starting process (but not required)
     
     - RequredBy=<service001> - service001 requires the current service to start to complete own starting process (strict condition - fails if it can't start the current service)
     
     - and etc see (51, UNIX and Linux System Administration Handbook - Fifth Edition)

    **To involve an explicit deps:** 
    - we can extend a unit’s Wants or Requires cohorts by creating a *unit-file.wants* or *unit-file.requires* directory in /etc/systemd/system and adding **symlinks** there to other unit files.
    
    - use the command `sudo systemctl add-wants multi-user.target my.local.service`
    
    > [Dependencies]
    > In most cases, such ad hoc dependencies are automatically taken care of for you, courtesy of the [Install] sections of unit files. This section includes *WantedBy* and *RequiredBy* options that are **read only** when a unit is enabled with systemctl enable or disabled with systemctl disable. On enablement, they make systemctl perform the equivalent of an add-wants for every WantedBy or an add-requires for every RequiredBy.

4. ##### Execution order

When the system transitions to a new state, systemd first traces the various sources of dependency information outlined in the previous section to identify the units that will be affected. It then uses **Before** and **After** clauses from the unit files to sort the work list appropriately. To the extent that units have no Before or After constraints, they are free to be adjusted **in parallel.**

5. ##### Service Type

Difference between **oneshot** and **simple** ([from](https://stackoverflow.com/questions/39032100/what-is-the-difference-between-systemd-service-type-oneshot-and-simple)):

The Type=**oneshot** service unit:

- blocks on a start operation until the first process exits, and its state will be reported as "activating";

- once the first process exits, transitions from "activating" straight to "inactive", unless RemainAfterExit=true is set (in which case it becomes "active" with no processes!);

- may have any number (0 or more) of ExecStart= directives which will be executed sequentially (waiting for each started process to exit before starting the next one);

- may leave out ExecStart= but have ExecStop= (useful together with RemainAfterExit=true for arranging things to run on system shutdown).

The Type=**simple** service unit:

- does not block on a start operation (i. e. becomes "active" immediately after forking off the first process, even if it is still initializing!);

- once the first process exits, transitions from "active" to "inactive" (there is no RemainAfterExit= option);

- is generally discouraged because there is no way to distinguish situations like "exited on start because of a configuration error" from "crashed after 500ms of runtime" and suchlike.

Both Type=oneshot and Type=simple units:

- ignore any children of the first process, so do not use these modes with forking processes (note: you may use Type=oneshot with KillMode=none, but only do this if you know what you are doing).

From [**man**](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
1. If set to simple (the default if ExecStart= is specified but neither Type= nor BusName= are), the service manager will consider the unit started **immediately** after the main service process has been forked off (even if it fails). It is expected that the process configured with ExecStart= is the main process of the service. In this mode, if the process offers functionality to other processes on the system, its communication channels should be installed before the service is started up (e.g. sockets set up by systemd, via socket activation), as the service manager will immediately proceed starting follow-up units, right after creating the main service process, and before executing the service's binary. Note that this means systemctl start command lines for simple services will report success even if the service's binary cannot be invoked successfully (for example because the selected User= doesn't exist, or the service binary is missing).

2. The **exec** type is similar to simple, but the service manager will consider the unit started immediately **after the main service binary has been executed**. The service manager will delay starting of follow-up units until that point. (Or in other words: simple proceeds with further jobs right after fork() returns, while exec will not proceed before both fork() and execve() in the service process succeeded.) **Note that this means systemctl start command lines for exec services will report failure when the service's binary cannot be invoked successfully** (for example because the selected User= doesn't exist, or the service binary is missing).

3. If set to forking, it is expected that the process configured with ExecStart= will call fork() as part of its start-up. The parent process is expected to exit when start-up is complete and all communication channels are set up. The child continues to run as the main service process, and the service manager will consider the unit started when the parent process exits. This is the behavior of traditional UNIX services. If this setting is used, it is recommended to also use the PIDFile= option, so that systemd can reliably identify the main process of the service. systemd will proceed with starting follow-up units as soon as the parent process exits.

4. Behavior of oneshot is similar to simple; however, the service manager will consider the unit started after the main process exits. It will then start follow-up units. **RemainAfterExit= is particularly useful for this type of service**. Type=oneshot is the implied default if neither Type= nor ExecStart= are specified.

5. Behavior of **dbus** is similar to simple; however, it is expected that the service acquires a name on the D-Bus bus, as configured by BusName=. systemd will proceed with starting follow-up units after the D-Bus bus name has been acquired. Service units with this option configured implicitly gain dependencies on the dbus.socket unit. This type is the default if BusName= is specified.

6. Behavior of **notify** is similar to exec; however, it is expected that the service sends a notification message via sd_notify(3) or an equivalent call when it has finished starting up. systemd will proceed with starting follow-up units after this notification message has been sent. If this option is used, NotifyAccess= (see below) should be set to open access to the notification socket provided by systemd. If NotifyAccess= is missing or set to none, it will be forcibly set to main. Note that currently Type=notify will not work if used in combination with PrivateNetwork=yes.

7. Behavior of **idle** is very similar to simple; however, actual execution of the service program is delayed until all active jobs are dispatched. This may be used to avoid interleaving of output of shell services with the status output on the console. Note that this type is useful only to improve console output, it is not useful as a general unit ordering tool, and the effect of this service type is subject to a 5s timeout, after which the service program is invoked anyway.

It is generally recommended to use Type=**simple** *for long-running services* whenever possible, as it is the simplest and fastest option. However, as this service type won't propagate service start-up failures and doesn't allow ordering of other units against completion of initialization of the service (which for example is useful if clients need to connect to the service through some form of IPC, and the IPC channel is only established by the service itself — in contrast to doing this ahead of time through socket or bus activation or similar), it might not be sufficient for many cases. If so, notify or dbus (the latter only in case the service provides a D-Bus interface) are the preferred options as they allow service program code to precisely schedule when to consider the service started up successfully and when to proceed with follow-up units. The notify service type requires explicit support in the service codebase (as sd_notify() or an equivalent API needs to be invoked by the service at the appropriate time) — if it's not supported, then forking is an alternative: it supports the traditional UNIX service start-up protocol. Finally, exec might be an option for cases where it is **enough to ensure the service binary is invoked**, and where the service binary itself executes no or little initialization on its own (and its initialization is unlikely to fail). Note that using any type other than simple possibly delays the boot process, as the service manager needs to wait for service initialization to complete. It is hence recommended not to needlessly use any types other than simple. (**Also note it is generally not recommended to use idle or oneshot for long-running services.**)

6. ##### Where to locate the service file and enable it?

Path: `/etc/systemd/system/[name].service`
To enable: `systemctl enable [name].service`

Unit files can live in several different places. **/usr/lib/systemd/system** is the main place where packages deposit their unit files during installation; on some systems, the path is **/lib/systemd/system** instead. The contents of this directory are consid- ered stock, so you shouldn’t modify them. Your local unit files and customizations can go in **/etc/systemd/system**. There’s also a unit directory in /run/systemd/system that’s a scratch area for transient units.

7. ##### Custom services

As a general rule, you should never edit a unit file you didn’t write. Instead, create a configuration directory in **/etc/systemd/system/unit-file.d** and add one or more configuration files there called *xxx.conf*. The xxx part doesn’t matter; just make sure the file has a .conf suffix and is in the right location. override.conf is the standard name.

7. ##### Journal activity

To see log about a unit: `sudo journalctl -u [unit-name]`

8. ##### Systemd timers

    8.1 Relative to events and based on calendar

    - OnActiveSec - Relative to the time at which the timer itself is activated (**Once**)
    - OnBootSec - Relative to system boot time (**Once**)
    - OnStartupSec - Relative to the time at which systemd was started (**Once**)
    - OnUnitActiveSec - Relative to the time the specified unit was last active (**repeatedly**)
    - OnUnitInactiveSec - Relative to the time the specified unit was last inactive (**repeatedly**)
    - OnCalendar (**repeatedly**)

    Example: note that we use a couple - **OnStartupSec**=7min and OnUnitActiveSec=1w - w/o *OnStartupSec* the second expression **OnUnitActiveSec** will be ignored.

    ```
      1 #  This file is part of systemd.
      2 #
      3 #  systemd is free software; you can redistribute it and/or modify it
      4 #  under the terms of the GNU Lesser General Public License as published by
      5 #  the Free Software Foundation; either version 2.1 of the License, or
      6 #  (at your option) any later version.
      7
      8 [Unit]
      9 Description=Everyweek backup: home and etc folders with use of rdiff-backup
     10
     11 [Timer]
     12 # make backup on 7th minuite after the next systemd start ONCELY
     13 OnStartupSec=7min
     14 # make backup weekly
     15 OnUnitActiveSec=1w
     16 # to avoid run several timers simultaneoulsy
     17 AccuracySec=1s
     18 # We can use Calendar to specify an accurate time period: On Monday at 18:00 every week
     19 # Calendar=Mon *-*-* 18:00:00
     20
     21 [Install]
     22 WantedBy=multi-user.target
    ```

    8.2 Command
    - list all timers: `systemctl list-timers`

    8.3 Time expressions

    - 2017-07-04 - July 4th, 2017 at 00:00:00 (midnight)
    - Fri-Mon *-7-4 - July 4th each year, but only if it falls on Fri–Mon
    - Mon-Wed *-*-* 12:00:00 - Mon-Wed at noon
    - Mon 17:00:00
    - weekly - Mondays at 00:00:00 (midnight)
    - monthly - 1st day of the month at 00:00:00 
    - *:0/10 - every 10th min starting at 0th min
    - *-*-* 11/12:10:0 - every day at 11:10 and 23:10

    8.4 Schedule handly

    - W/o creating .timer and .service:
    `systemd-run --on-calendar '*:0/10' /bin/sh -c "cd /app && git pull"`
