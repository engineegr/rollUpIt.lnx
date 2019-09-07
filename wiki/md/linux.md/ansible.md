##### Ansible
-------------

1. ###### Installation

- Linux CentOS 7
`yum -y install ansible`

- MacOS:
```
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
pip install --user ansible
```

2. ###### Basic

- create inventory file: `/etc/ansible/hosts`
- make passwordless ssh access unless use `-k` key: `ansible srvfarm -vvv  -a "free -h M" -u root`

- playbook: a set of instruction to be passed to servers, it is comprised of tasks. There is a master playbook and role-related playbooks so that an ansible project is made of:

1. inventory file `hosts`
2. site.yml - master playbook which group of hosts that will be managed using our available roles.
3. roles - a directory that consists roles playbooks: they can consist tasks, handlers, vars and etc

3. ##### Vagrant

3.1 Basic

- Add a box and init a directory:
```
vagrant box add centos/7
vagrant init centos/7
```

- Inject a playbook to vagrant config (./Vagrantfile): add the following lines before last `end`:
```
config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.xml"
    ansible.become = true
end
```

- Basic `playbook.xml`:
```
---
- hosts: all
  tasks:
  - name: Ensure NTP is installed
    yum: name=ntp state=installed
  - name: Start NTP service
    service: name=ntpd state=started enabled=yes
```

3.2 SSH keys.

- Primarly Vagrant uses *insecure_private_key* located in `~/.vagrant.d/insecure_private_key` and we can download a public part of the key with the url:

```
curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub > ~/.ssh/authorized_keys
```

Hence Vagrant can connect to a vm (vm has a public part included in `~/.ssh/authorized_kyes`)

There is an option in the **config.ssh**:

`config.ssh.insert_key (boolean)` - If true, Vagrant will automatically insert a keypair to use for SSH, replacing Vagrant's default insecure key inside the machine if detected. By default, this is true.
This only has an effect if you do not already use private keys for authentication or if you are relying on the default insecure key. If you do not have to care about security in your project and want to keep using the default insecure key, set this to false.

So that if we set to true: `config.ssh.insert_key (boolean)` every vm will use own pair private/public ssh key: 

`IdentityFile /Users/likhobabin_im/Workspace/Sys/Vagrant/srvfarm001.labs.local/.vagrant/machines/fw/virtualbox/private_key`

4. ##### About command and shell module

A typical example are the Ansible modules **Shell** and **Command**. In the most use cases both modules lead to the same goal. Here are the main differences between these modules.

- With the `command` module the command will be executed without being proceeded through a shell. As a consequence some variables like $HOME are not available. And also stream operations like  <, >, | and & will not work.

- The `Shell` module runs a command through a shell, by default /bin/sh. This can be changed with the option executable. Piping and redirection are here therefor available.

The `command` module is more secure, because it will not be affected by the user’s environment.

>[!Links]
>1.[Ansible Guide: Create Ansible Playbook for LEMP Stack](https://www.howtoforge.com/ansible-guide-create-ansible-playbook-for-lemp-stack/)
>2.[Run scripts in Ansible tasks](https://docs.ansible.com/ansible/latest/modules/script_module.html)

