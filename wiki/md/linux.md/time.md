#### Time 
---------

1. ##### How to determine the current timezone?

`ls /etc/localtime`

2. ##### How to change the timezone?

`timedatectl set-timezone America/Chicago`

3. ##### How to find timezones?

`ls -la /usr/share/zoneinfo/[America/Chicago]`

4. ##### How to change time?

- to set Y/M/D:
`date +%Y%m%d -s "20081128"`

- to set time:
`date +%T -s "14:15:00"`

5. ##### Using timedatectl: see https://www.cyberciti.biz/faq/howto-set-date-time-from-linux-command-prompt/