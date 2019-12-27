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

>[Links]
>1. [How to run a task from cron manually](https://unix.stackexchange.com/questions/42715/how-can-i-make-cron-run-a-job-right-now-for-testing-debugging-without-changing)
