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
                


    
    
