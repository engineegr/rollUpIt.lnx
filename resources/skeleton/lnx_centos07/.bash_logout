# ~/.bash_logout: executed by bash(1) when login shell exits.

# when leaving the console clear the screen to increase privacy
BL_LOG="bash_logout.log"

if [ ! -z "$(tmux list-session | grep -e '^tmux_env[:].*')" ]; then 
    tmux kill-session -t tmux_env &>>$BL_LOG
    echo "[tmux_env] session has been killed successfully"
else
    echo "No [tmux_env] session" >> $BL_LOG 
fi

if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi

