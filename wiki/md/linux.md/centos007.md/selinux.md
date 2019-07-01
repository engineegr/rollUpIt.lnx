#### SELinux
-------------

1. ##### Get status

SELinux is enabled by default on the CentOS 7, to **get status**:

`sestatus`

2. ##### Configure SELinux for TFTP server

2.1 Check status

`getsebool -a | grep tftp`

3. ##### To make it being permissive

4. #### Permissive mode

When SELinux is running in **permissive mode**, SELinux policy is not enforced. The system remains operational and **SELinux does not deny any operations but only logs AVC messages**, which can be then used for troubleshooting, debugging, and SELinux policy improvements. Each AVC is logged only once in this case.
