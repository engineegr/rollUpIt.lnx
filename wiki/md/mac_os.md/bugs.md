### Bugs in Mac OS
------------------------

1. ##### VirtualBox: VBoxNetAdpCtl: Error while adding new interface: failed to open /dev/vboxnetctl: No such file or directory
    *To fix:*

- Completely uninstall VirtualBox: <code>/Volumes/VirtualBox/VirtualBox_Uninstall.tool</code>

- Reboot, install VirtualBox, Oracle_VM_VirtualBox_Extension_Pack-6.1.22

- Open Security Preferences and Allow Oracle update;

- Reboot;


2. ##### Laravel: LARAVEL 5 SEEDER ОШИБКА CLASS DOES NOT EXIST

<code>composer dumpautoload</code>


3. ##### Update https://steilgut.voodoopages.net

- Update npm packages: <code>npm update</code>

- Update Node.js: 

```
sudo npm cache clean -f
sudo npm install -g n
sudo n stable
```

- Install GD library: <code>apt-get install php8.0</code>