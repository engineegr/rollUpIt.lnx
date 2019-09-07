### Tmux
---------

1. #### Start as a systemd service:
    1. Needs to create service unit: tmuxd.service
    
            [Unit]                    
            Description=Start tmux in detached session             
            [Service]               
            Type=forking              
            User=%I                   
            ExecStart=/usr/bin/tmux new-session -s %u_ts -d                   
            ExecStop=/usr/bin/tmux kill-session -t %u_ts           
            [Install]            
            WantedBy=multi-user.target

    2. Copy the unit into ~/.config/systemd/user/ and enable it:

            systemctl --user enable tmuxd.service

    >[!Note]
    > After that we get the error: *Failed to get D-Bus connection: No such file or directory*. See *CentOS007/bugs* how to resolve it.

2. #### Copy mode [based on](http://www.rushiagr.com/blog/2016/06/16/everything-you-need-to-know-about-tmux-copy-pasting-ubuntu/)
    1. Rebind keys to in favour of vim:
    
            # copy mode
            bind P paste-buffer                      
            bind-key -t vi-copy 'v' begin-selection  
            bind-key -t vi-copy 'y' copy-selection   
            bind-key -t vi-copy 'r' rectangle-toggle   

    2. Make copy to clipboard (from the remote terminal's clipboard): [try it](https://stackoverflow.com/questions/37444399/vim-copy-clipboard-between-mac-and-ubuntu-over-ssh)

3. #### iTerm2
    
    To force working meta-key in tmux we need change settings: `Profiles/Keys/Left option acts as +Esc`

4. #### Swap panes:

The swap-pane command can do this for you. The `{` and `}` keys are bound to *swap-pane -U* and *swap-pane -D* in the default configuration.

So, to effect your desired change, you can probably use Prefix `{` when you are in the right pane (or Prefix `}` if you are in the left pane).

The -U and -D refer to “up” and “down” in the pane index order (“up” is the same direction that Prefix o moves across panes). You can see the pane indices with display-panes (*Prefix q*, by default).

5. #### [Install in CentOS 7](https://gist.github.com/suhlig/c8b8d70d33462a95d2b0307df5e40d64) : 2.7 version

```
# Install tmux on rhel/centos 7

# install deps
yum install gcc kernel-devel make ncurses-devel

# DOWNLOAD SOURCES FOR LIBEVENT AND MAKE AND INSTALL
curl -OL https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
tar -xvzf libevent-2.1.8-stable.tar.gz
cd libevent-2.1.8-stable
./configure --prefix=/usr/local
make
sudo make install
cd ..

# DOWNLOAD SOURCES FOR TMUX AND MAKE AND INSTALL
curl -OL https://github.com/tmux/tmux/releases/download/2.7/tmux-2.7.tar.gz
tar -xvzf tmux-2.7.tar.gz
cd tmux-2.7
LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib" ./configure --prefix=/usr/local
make
sudo make install
cd ..

# pkill tmux
# close your terminal window (flushes cached tmux executable)
# open new shell and check tmux version
tmux -V
```

6. ##### [Inner and outer session in tmux](https://www.freecodecamp.org/news/tmux-in-practice-local-and-nested-remote-tmux-sessions-4f7ba5db8795/)

7. ##### Select a text

Assuming your prefix key is C-a:

- Go to the copy mode: `C-a [`
- Move the middle of a line
- Press `C-v`
- Press `Space`
- Move the selection with `jkhl`
- Once you are happy with your selection press `Enter` (or y if you have the binding in your conf file).
- You can paste the latest copy buffer by: `C-a ]`

    
    
