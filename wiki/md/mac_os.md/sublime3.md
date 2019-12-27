#### Sublime setup

1. ##### Vi mode

- activate:
[Preferences] -> [Settings] and remove from ignored package **Vintage**

- vi quick escape:
[Preferences] -> [Key bindings] and add the following:

```
{
    "keys": ["j", "j"],
    "command": "exit_insert_mode",
    "context":
    [
        { "key": "setting.command_mode", "operand": false },
        { "key": "setting.is_widget", "operand": false }
    ]
}
```

- usefull shortcuts:

Vintage supports these `Ctrl key bindings`

- `Ctrl+[` Escape
- `Ctrl+R` Redo
- `Ctrl+Y` Scroll down one line
- `Ctrl+E` Scroll up one line
- `Ctrl+F` Page Down
- `Ctrl+B` Page Up
