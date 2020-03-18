#### Cron

1. ##### Run a task from cron manually

    1.1 Create a task in *crontab*:

    ```
    * * * * *   /usr/bin/env > /tmp/cron-env
    ```

    1.2 Use the stored `env` settings run a target script:

    ```
    #!/bin/bash
    # runasCron.sh
    /usr/bin/env -i $(cat /home/username/tmp/cron-env) "$@"
    ```

    Run the target script:

    ```
    runasCron.sh target_script.sh
    ```

2. ##### Day of month and day of week ambiguity

    Example:

    `0,30 * 1 * 1` means: "Run the task every half hour on Monday *and* on the first day of the month"

3. ##### % sign in crond

    % adds a new line and all followed that is standard input:

    ```
    0,30 * 1 * * cat - % This is a new line
    ```

4. #### Environment variable in cron

    Although `sh` is involved in executing the command, the shell does not act as a *login shell* and does not read the contents of `~/.profile` or `~/.bash_profile`. As a result, the command’s environment variables might be set up somewhat differently from what you expect. If a command seems to work fine when executed from the shell but fails when introduced into a crontab file, the environment is the likely culprit. If need be, you can always wrap your command with a script that sets up the ap- propriate environment variables.

    To set env variable:

    ```
    PATH=/bin:/usr/bin
    * * * * * echo $(date) - $(uptime) >> ~/uptime.log
    ```

>[Links]
>1. [How to run a task from cron manually](https://unix.stackexchange.com/questions/42715/how-can-i-make-cron-run-a-job-right-now-for-testing-debugging-without-changing)
