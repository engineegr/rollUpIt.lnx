#### Sublime setup

1. ##### Create user and grant access to a database from all hosts

```
create user 'user' identified by 'password';
grant all privileges on super_db.* to 'user'@'%';
flush privileges;

show databases;
use super_db;
show tables;
```