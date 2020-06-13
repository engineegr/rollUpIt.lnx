#### Permissions

1. ##### Sticky bit

    Данный бит используется, чтобы запретить удаление/переименование/перемещение файла не владельцами: например, umask = *1000* -> разрешает все права доступа для всех, но запрещает удаление/переименование/перемещение файла:

    Установить/удалить:

    ```
    chmod +/-t test.txt
    ```


2. ##### Setuid, setgid

    *umask -> 4000 (setuid)* -> run a command on behalf of the command owner

    *umask -> 2000 (setgid)* -> all created files inside a directory with setgid has group = group of the parent directory rather than the user created the files. The bit is not related to run command inside the dir.


3. ##### Soft vs hard link

    Soft link - содержит путь к файлу, если мы удаляем файл ссылка уже указывает на null

    Hard link - полное отражение файл (права доступа, номер inode): указывает на inode, если мы удаляем сам файл, hard link все еще указывает на inode и вернет содержимое файла. Т.е. ведет себя как указатель или directory entries.  

    И hard, и soft links описываются отдельными directory inode.

    inode - это метаданные, указывающие на блок данных, из которых состоит файл, и inode содержит атрибуты файла (права доступа, указатели на данные).

    Существенное ограничение в отношении hardlinks:

    - они могут быть созданы только в рамках одной и той же ФС.

    - не могут линковаться на директории;

