#### SSHD
----------

1. ##### Passwordless authentication:

    - generate key: `sshkey-gen -t rsa` - leave the passphrase is empty unless it will ask you when you will authenticate the srv;

    - copy the public key (.ssh/id_rsa.pub) to the remote server:

    `cat .ssh/id_rsa.pub | ssh <user_name>@<remote_srv> 'cat >> .ssh/authorized_keys'`
    or
    `ssh-copy-id remote_username@server_ip_address`

    - change permissions to .ssh and authorized_keys:

    `cat ~/.ssh/id_rsa.pub | ssh remote_username@server_ip_address "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`

    - change sshd_config on the remote server: turn off password authentication, PAM: it disables password authentication at all.

    ```
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    UsePAM no
    ```

>[Note]
> 1. [Passwordless ssh authentication](https://linuxize.com/post/how-to-setup-passwordless-ssh-login/)