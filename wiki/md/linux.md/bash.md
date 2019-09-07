#### Bash
---------

0. ##### Основы

    **0.1 Логические операции в `if [ ]; then fi`**

    `-z`- строка пуста

    `-n`- строка не пуста

    `=, (==)`- строки равны

    `!=`- строки неравны

    `-eq`- равно

    `-ne`- неравно

    `-lt,(< )`- меньше

    `-le,(<=)`- меньше или равно

    `-gt,(>)`-больше

    `-ge,(>=)` -больше или равно

    `!` -отрицание логического выражения

    `-a,(&&)` -логическое «И»

    `-o,(||)`- логическое «ИЛИ»

    `-a file`- Does the file exist? (same as -e)

    `-b file`- Is the file a block special device?

    `-c file`- Is the file character special (for example, a character device)? Used to identify serial lines and terminal devices.

    `-d file`- Is the file a directory?

    `-e file`- Does the file exist? (same as -a)

    `-f file`- Does the file exist, and is it a regular file (for example, not a 
    directory,
    socket, pipe, link, or device fi le)?

    `-g file`- Does the fi le have the set-group-id (SGID) bit set?

    `-h file`- Is the fi le a symbolic link? (same as -L)

    `-k file`- Does the file have the sticky bit set?

    `-L file`- Is the file a symbolic link?

    `-n string`- Is the length of the string greater than 0 bytes?

    `-O file`- Do you own the file?

    `-p file`- Is the fi le a named pipe?

    `-r file`- Is the file readable by you?

    `-s file`- Does the fi le exist, and is it larger than 0 bytes?

    `-S file`- Does the file exist, and is it a socket?

    `-t fd`- Is the file descriptor connected to a terminal?

    `-u file`- Does the file have the set-user-id (SUID) bit set?

    `-w file`- Is the file writable by you?

    `-x file`- Is the file executable by you?

    `-z string`- Is the length of the string 0 (zero) bytes?

    `expr1 -a expr2`- Are both the first expression and the second expression true?

    `expr1 -o expr2`- Is either of the two expressions true?

    `file1 -nt file2`- Is the first file newer than the second fi le (using the 
    modifi cation timestamp)?

    `file1 -ot file2`- Is the first file older than the second fi le (using the modifi cation timestamp)?

    `file1 -ef file2`- Are the two files associated by a link (a hard link or a symbolic link)?

    `var1 = var2`- Is the first variable equal to the second variable?

    `var1 -eq var2`- Is the first variable equal to the second variable?

    `var1 -ge var2`- Is the first variable greater than or equal to the second 
    variable?

    `var1 -gt var2`- Is the first variable greater than the second variable?

    `var1 -le var2`- Is the first variable less than or equal to the second variable?

    `var1 -lt var2`- Is the first variable less than the second variable?

    `var1 != var2`- Is the first variable not equal to the second variable?

    `var1 -ne var2`- Is the first variable not equal to the second variable?

    **0.2 Use `&&` and `||`**

    ```
    if [ $condition1 ] && [ $condition2 ] then
    ...
    fi

    if [[ $condition1 && $condition2 ]]; then
    ...
    fi
    ```

    **Shorten** logical && and ||

    Example 001.
    ```
    # Perform simple single command if test is false
    dirname="/tmp/testdir"
    [ -d "$dirname" ] || mkdir "$dirname"
    ```

    Example 002.
    ```
    # Perform simple single action if test is true
    [ $# -ge 3 ] && echo "There are at least 3 command line arguments."
    ```

[!Important]
>1. The [ command is an ordinary command. Although most shells provide it as a built-in for efficiency, it obeys the shell's normal syntactic rules. `[` is exactly equivalent to test, except that `[` requires a `]` as its last argument and test doesn't. **Inside single brackets**, you need to use double quotes around variable substitutions, like in most other places, because they're just arguments to a command (which happens to be the `[`command). Inside double brackets, you don't need double quotes, because the shell doesn't do word splitting or globbing: it's parsing a conditional expression, not a command.

**0.3 Резервные переменные:**
    
    `$DIRSTACK`- содержимое вершины стека каталогов

    `$EDITOR`- текстовый редактор по умолчанию

    `$EUID`- Эффективный UID. Если вы использовали программу `su` для выполнения команд от другого пользователя, то эта переменная содержит UID этого пользователя, в то время как...

    `$UID`- ...содержит реальный идентификатор, который устанавливается только при логине.

    `$FUNCNAME`- имя текущей функции в скрипте.

    `$GROUPS`- массив групп к которым принадлежит текущий пользователь

    `$HOME`- домашний каталог пользователя

    `$HOSTNAME`- ваш hostname

    `$HOSTTYPE`- архитектура машины.

    `$LC_CTYPE`- внутренняя переменная, котороя определяет кодировку символов

    `$OLDPWD`- прежний рабочий каталог

    `$OSTYPE`- тип ОС

    `$PATH`- путь поиска программ

    `$PPID`- идентификатор родительского процесса

    `$SECONDS`- время работы скрипта(в сек.)
    
    `$#`- общее количество параметров переданных скрипту

    `$*`- все аргументы переданыне скрипту(выводятся в строку)

    `$@`- тоже самое, что и предыдущий, но параметры выводятся в столбик

    `$!`- **PID** последнего запущенного в фоне процесса

    `$$`- **PID** самого скрипта

    `$?`- Код выход предыдущей каманды (exit status)

    0.4 **Strings**

    To compare two string use "=="
    ```
    if [[ "$stringA" == "$stringB" ]]; then
      # Do something here
    else
      # Do Something here
    fi
    ```

    To conc strings:
    ```
    # var01="A"
    # var02="B"
    # res=$var01$var02 
    or
    # res+=$var01
    # res+=$var02
    ```

0.5 **Functions**

    About `FUNCNAME`

      >An  array  variable  containing the names of all shell functions
      currently in the execution call stack.  The element with index 0
      is the name of any currently-executing shell function.  The bottom-most element is "main".  This variable exists  only  when  a
      shell  function  is  executing.  Assignments to FUNCNAME have no
      effect and return an error status.  If  FUNCNAME  is  unset,  it
      loses its special properties, even if it is subsequently reset.
 
    `$?` reads the exit status of the last command executed. After a function returns, `$?` gives the exit status of the last command executed in the function.

0.6 **Variables**

    [See more here](https://mywiki.wooledge.org/BashFAQ/073)

    `$#`    - кол-во переданных переменных

    `${!#}` - значение последней переменной

    `${var:-value}` — If variable is unset or empty, expand this to value 

    `${var#pattern}` - Chop the shortest match for pattern from the front of
    var’s value.

    `${var##pattern}` - Chop the longest match for pattern from the front of
    var’s value.

    `${var%pattern}` - Chop the shortest match for pattern from the end of var’s value.

    `${var%%pattern}` - Chop the longest match for pattern from the end of
    var’s value.

    Example 003.
    ```
    MYFILENAME=/home/digby/myfile.txt
    FILE=${MYFILENAME##*/} — FILE becomes myfile.txt
    DIR=${MYFILENAME%/*} — DIR becomes /home/digby
    NAME=${FILE%.*} — NAME becomes myfile
    ```

**0.7 Arithmetic operations**
    Example 004. Basic
```
    #!/bin/bash
    # Counting to 11 in 10 different ways.

    n=1; echo -n "$n "

    let "n = $n + 1"   # let "n = n + 1"  also works.
    echo -n "$n "

    : $((n = $n + 1))
    # ":" necessary because otherwise Bash attempts
    # + to interpret "$((n = $n + 1))" as a command.
    echo -n "$n "

    (( n = n + 1 ))
    #  A simpler alternative to the method above.
    #  Thanks, David Lombard, for pointing this out.
    echo -n "$n "

    n=$(($n + 1))
    echo -n "$n "

    : $[ n = $n + 1 ]
    # ":" necessary because otherwise Bash attempts
    # + to interpret "$[ n = $n + 1 ]" as a command.
    #  Works even if "n" was initialized as a string.
    echo -n "$n "

    n=$[ $n + 1 ]
    #  Works even if "n" was initialized as a string.
    #* Avoid this type of construct, since it is obsolete and nonportable.
    #  Thanks, Stephane Chazelas.
    echo -n "$n "
    ```

    Example 005. Incrementation
    ```
    # Now for C-style increment operators.
    # Thanks, Frank Wang, for pointing this out.

    let "n++"          # let "++n"  also works.
    echo -n "$n "

    (( n++ ))          # (( ++n ))  also works.
    echo -n "$n "

    : $(( n++ ))       # : $(( ++n )) also works.
    echo -n "$n "

    : $[ n++ ]         # : $[ ++n ] also works
    echo -n "$n "

    exit 0
```

Example 006. Compound operations
```
    #!/bin/bash

    a=24
    b=47

    if [ "$a" -eq 24 ] && [ "$b" -eq 47 ]
    then
      echo "Test #1 succeeds."
    else
      echo "Test #1 fails."
    fi

    # ERROR:   if [ "$a" -eq 24 && "$b" -eq 47 ]
    #+         attempts to execute  ' [ "$a" -eq 24 '
    #+         and fails to finding matching ']'.
    #
    #  Note:  if [[ $a -eq 24 && $b -eq 24 ]]  works.
    #  The double-bracket if-test is more flexible
    #+ than the single-bracket version.       
    #    (The "&&" has a different meaning in line 17 than in line 6.)
    #    Thanks, Stephane Chazelas, for pointing this out.


    if [ "$a" -eq 98 ] || [ "$b" -eq 47 ]
    then
      echo "Test #2 succeeds."
    else
      echo "Test #2 fails."
    fi

    #  The -a and -o options provide
    #+ an alternative compound condition test.
    #  Thanks to Patrick Callahan for pointing this out.

    if [ "$a" -eq 24 -a "$b" -eq 47 ]
    then
      echo "Test #3 succeeds."
    else
      echo "Test #3 fails."
    fi

    if [ "$a" -eq 98 -o "$b" -eq 47 ]
    then
      echo "Test #4 succeeds."
    else
      echo "Test #4 fails."
    fi
```

**0.8 How to run bash-code in command line**

    `# sh -c 'if( test -e /Users ); then echo Exists; else echo Not Exists; fi'`

    `# sh -c '[[ -e /Users ]] && ( echo Exists; ) || ( echo Not Exists; )' `

**0.9 Some tips**
    - `fc` - Returns text of the last command in the editor
    - `find / -perm -a=x -print0 | xargs -0 ls -la` - When you are writing scripts, a useful weapon to know about is find’s `-print0` option. In combination with `xargs -0`, this option makes the find/xargs combination **work correctly regardless of the whitespace contained within filenames**.
    - Use the following construction to produce multiple strings in a file or variable:

Example 09.1
```
  cat <<EOFF >$cfg_fp
# TODO: insert a common options
authoritative;
log-facility local7;

# allow it in a specific pool
deny bootp;
deny booting;

$([ "${domain_name}" = "#nd" ] && echo '' || echo "option domain-name \"${domain_name}\";")
$([ -z "$ns_str" ] && echo '' || echo "$ns_str")
$([ "${opt_broadcast}" = '#nd' ] && echo '' || echo "option broadcast-address ${opt_broadcast};")
$([ "${opt_router}" = '#nd' ] && echo '' || echo "option routers ${opt_router};")
$([ "${opt_subnetmask}" = '#nd' ] && echo '' || echo "option subnet-mask ${opt_subnetmask};")

$([ "${def_lease}" = '#nd' ] && echo '' || echo "default-lease-time ${def_lease};")
$([ "${max_lease}" = '#nd' ] && echo '' || echo "max-lease-time ${max_lease};")

EOFF
```

In relating to a variable:

Example 09.2. We have to add '\n' and option `-e` to **echo**
```
    local subnet_cfg_str=$(
      cat <<EOF
subnet ${subnet} netmask ${subnetmask} {
  pool {
    range ${unfold_addr_01} ${unfold_addr_02};
    $([ "${def_router}" = '#nd' ] && echo '' || echo "option routers ${def_router};")
EOF
    )
    if [[ "$next_srv" != '#nd' && "$filename" != '#nd' ]]; then
      subnet_cfg_str="$subnet_cfg_str\n$(
        cat <<-EOF
    next-server ${next_srv};
    filename "${filename}";
  }
}
EOF
echo -e "$subnet_cfg_str" >>$cfg_fp
```

Appending a minus sign to the redirection operator `<<-`, will cause all leading tab characters to be ignored. This allows you to use indentation when writing here-documents in shell scripts. Leading whitespace characters are not allowed, only tab. If you are using a heredoc inside a statement or loop, use the `<<-` redirection operation that allows you to indent your code.

Example 09.3

```
if true; then
    cat <<- EOF
    Line with a leading tab.
    EOF
fi
```

**0.10 About regexp**
    
Since parentheses can nest, how do you know which match is which? Easy: the matches arrive in the same order as the opening parentheses. There are as many captures as there are opening parentheses, regardless of the role (or lack of role) that each parenthesized group played in the actual matching. When a parenthe- sized group is not used (e.g., Mu(')?ammar when matched against “Muammar”), its corresponding capture is empty.

If a group is matched more than once, the contents of **only the last match are returned**. For example, with the pattern
`(I am the (walrus|egg man)\. ?){1,2}` - matching the text
*I am the egg man. I am the walrus.*
there are two results, one for each set of parentheses:
*I am the walrus.     
walrus*

Both capture groups actually matched twice. However, only **the last text**to match each set of parentheses is actually captured.
**By default**, reg expressions use greedy algorithm of matching:
`<head .*> </head>` - firstly it matches all from `<head` to the end but using backtracking it goes back up to `/>` and it is not very fast method. Instead we can define the expression as that: `<head[^>]*></head>` or use the lazy form: `<head.*?></head>`. So that prefer **lazy** technique to greedy.

**Lazy (as opposed to greedy)** wild card operators: *? instead of *, and +? instead of +. These versions match as few characters of the input as they can. If that fails, they match more. In many situations, these operators are more efficient and closer to what you want than the greedy versions.

**Built-in regular expressions** are naughty: we shouln't use single and double quotes in conditions:
```
   if [[ ! "$def_lease" =~ ^([[:digit:]]*)$ ]]; then
     printf "$debug_prefix ${RED_ROLLUP_IT} Error: Invalid default lease: it must be a digit.\nSee help${END_ROLLUP_IT}\n" >&2
     help_DHCPSRV_RUI
     exit 1
   fi
```

1. ##### Check a variable type: user `declare`

    [From](https://www.tldp.org/LDP/abs/html/declareref.html):

    > The declare or typeset builtins, which are exact synonyms, permit modifying the properties of variables. This is a very weak form of the typing [1] available in certain programming languages. The declare command is specific to version 2 or later of Bash. The typeset command also works in ksh scripts.

    **1.1 Check if a variable is **array****

    ```
    checkIfArray() {
        local var=$( declare -p $1 )
        local reg='^declare -n [^=]+=\"([^\"]+)\"$'
        while [[ $var =~ $reg ]]; do
                var=$( declare -p ${BASH_REMATCH[1]} )
        done

        case "${var#declare -}" in
        a*)
                echo "ARRAY"
                ;;
        A*)
                echo "HASH"
                ;;
        i*)
                echo "INT"
                ;;
        x*)
                echo "EXPORT"
                ;;
        *)
                echo "OTHER"
                ;;
        esac
    }

    declare -a var001=("sudo","tcpdump")
    ```

    [Where BASH_REMATCH stores the regular exp result](https://rtfm.co.ua/bash-regulyarnye-vyrazheniya-i-bash_rematch/)

2. ##### Pass a reference to the variable

    [See more here](https://mywiki.wooledge.org/BashFAQ/006)

    **2.1 Regular variable**

    ```
    function foo() {
        local __var1=$1
        # some calculation with __var1
        # save the result
        eval $__var1="'$__var1'"
        ...
    }

    local var1=0
    foo var1
    ```

    **2.2 Arrays: pass an array by reference**

    ```
    function foo() {
        local __array001=${1}[@]
        # use indirect reference
        for i in "${!__array001}" do
        done
    }

    declare -a array001=("one" "two" three)
    foo array001
    ```

    Where **indirect references** are references that point to origin references and then we can calculate their values:

    ```
    local var1="apple"
    local var2=var1

    echo "${!var2}" # "apple" unless "var1"
    ```

    >[!Links]
    > 1. [Arrays](https://unix.stackexchange.com/questions/20171/indirect-return-of-all-elements-in-an-array)
    > 2. [Online bash](https://paiza.io/projects/tqZ6e_L0UPtnBkRNWxZKLg?language=bash)

3. ##### Error processing

    **3.1 Print into stderr**

    ```
    printferr() {
        printf "%s\n, $*" >&2 
    }

    echoerr() {
        >&2 echo "$*"
    }
    ```

4. ##### SQL

**4.1 To inject sql-scripts from command line**

 - Use option '-e' with mysql:
 `# mysql --skip-column-names -B -e "SHOW /*!50002 GLOBAL */ STATUS LIKE 'Uptime'"`

 where:
 (1) -e - to indicate the statement string to execute
 (2) -B - generate tab-delimeted output

**4.2 Use <<<MARKER or "here-document"**

Example 007
```
#!/bin/sh
# count_rows.sh - count rows in cookbook database table

# require one argument on the command line
if [ $# -ne 1 ]; then
echo "Usage: count_rows.sh tbl_name";
exit 1;
fi

# use argument ($1) in the query string
mysql cookbook <<MYSQL_INPUT
SELECT COUNT(*) AS 'Rows in table:' FROM $1;
MYSQL_INPUT
```

5. ##### Descriptors
    Descriptors are processed from **left to right**.

    Example 008
    ```
    # POSIX
    foo() {
      echo "This is stdout"
      echo "This is stderr" 1>&2
    }
    foo >/dev/null 2>&1             # produces no output
    foo 2>&1 >/dev/null             # writes "This is stderr" on the screen
    ```

    1. In the first case we redirect the point to /dev/null that **stdout** references to and then stderr started to point to the same place.  
    2. In the second case we redirect stderr to the stdout's point and then redirect stdout to another point to /dev/null

    So descriptors works in the same way as references in `C`.
    Another example redirect errors only to **stdout**: `find ... 2>&1 >/dev/null | grep "some errors"`

    A **File Descriptor** (FD) is a number which refers to an open file. Each process has its own private set of FDs, but FDs **are inherited by child processes from the parent process**.
    We can redirect file descriptors to standard descriptors like that:

    Example 009
    ```
    echo "unexpected error: $foo" 1>&2
    while read -r line 0<&3; do ...
    ```
    Here we fetch in **stdin** content of the 3d descriptor's file. 
    Another example we can manipulate a socket state with use of descriptors:

    Example 010
    ```
    #!/usr/bin/env bash
    exec 3<> /dev/tcp/www.google.com/80 || exit 1
    printf 'HEAD / HTTP/1.1\nHost: www.google.com\nConnection: close\n\n' >&3
    cat <&3
    ```
    Here we open input and output redirections of the socket in FD `3` and then pass http-request after that we read returned result of the socket.
    To close descriptors:

    Example 010
    ```
    exec 3>&-   # Close FD 3
    exec 4<&-   # Close FD 4
    ```

    Compound commands and functions provide something analogous to block level variable scope for file descriptors. When you enter a compound command and provide it redirections, the effect should be similar to starting a subshell process with its own independent file descriptor table so that upon leaving, the original FDs are restored (though you can still close/move/manipulate FDs associated with an outer "scope" using exec and different redirects). Since **without forking, the OS maintains only one set of FDs for the entire process**, the shell must maintain its **own stack of FD mappings** in order to simulate nested FD scope.

    We can use a trick with `time` command that allows us to read redirections of an expression preliminary without its execution:
    ```
    # Keep both stdout and stderr unmolested.
    exec 3>&1 4>&2
    foo=$( { time bar 1>&3 2>&4; } 2>&1 )  # Captures time only.
    exec 3>&- 4>&-
    ```
    The goal of this code is to capture the results from bash's time command in a variable, while letting the timed command's stdout and stderr go wherever they were originally supposed to go. This is tricky because time also writes to stderr, not to a separate FD. However, since bash's time is a magic keyword that uses its own "scope" for redirections (much like a curly-brace command grouping), we can apply redirections at different levels to get the results we want.


6. ##### Work with files
    
    **Read files from a directory**

    **Don't do it**:
    ```
    for f in $(ls *.mp3); do    # Wrong!
    some command $f         # Wrong!
    done

    for f in $(ls)              # Wrong!
    for f in `ls`               # Wrong!

    for f in $(find . -type f)  # Wrong!
    for f in `find . -type f`   # Wrong!

    files=($(find . -type f))   # Wrong!
    for f in ${files[@]}        # Wrong!
    ```
    Why?
    - If a filename contains whitespace, it undergoes WordSplitting. Assuming we have a file named 01 - Don't Eat the Yellow Snow.mp3 in the current directory, the for loop will iterate over each word in the resulting file name: 01, -, Don't, Eat, etc.

    - If a filename contains glob characters, it undergoes filename expansion ("globbing"). If ls produces any output containing a * character, the word containing it will become recognized as a pattern and substituted with a list of all filenames that match it.

    - If the command substitution returns multiple filenames, there is no way to tell where the first one ends and the second one begins. Pathnames may contain any character except NUL. Yes, this includes newlines.

    - The ls utility may mangle filenames. Depending on which platform you're on, which arguments you used (or didn't use), and whether its standard output is pointing to a terminal or not, ls may randomly decide to replace certain characters in a filename with "?", or simply not print them at all. Never try to parse the output of ls. ls is just plain unnecessary. It's an external command whose output is intended specifically to be read by a human, not parsed by a script.

    - The CommandSubstitution strips all trailing newline characters from its output. That may seem desirable since ls adds a newline, but if the last filename in the list ends with a newline, `...` or $() will remove that one also.

    - In the ls examples, if the first filename starts with a hyphen, it may lead to pitfall #3.

    **Right way** - Use globbing:

    ```
    for file in ./*.mp3; do    # Better! and...
        some command "$file"   # ...always double-quote expansions!
    done
    ```
    What happens if there are no \*.mp3-files in the current directory? Then the for loop is executed once, with i="./*.mp3", which is not the expected behavior! The workaround is to test whether there is a matching file:
    ```
    # POSIX
    for file in ./*.mp3; do
        [ -e "$file" ] || continue
        some command "$file"
    done
    ```

    **Read a file**

6.1 Don't trimm leading/trailing spaces

```
    while IFS= read -r line; do
      printf '%s\n' "$line"
    done < "$file"
```
Where 
- we set `IFS` to nil.
- The -r option to read prevents backslash interpretation (usually used as a backslash newline pair, to continue over multiple lines or to escape the delimiters). Without this option, any unescaped backslashes in the input will be discarded. You should almost always use the -r option with read.

6.2 Trim leading/trailing whitespaces

```
    # Leading/trailing whitespace trimming.
    while read -r line; do
      printf '%s\n' "$line"
    done < "$file" 
```

6.3 To operate on individual fields within each line, you may supply additional variables to read:

```
    # Input file has 3 columns separated by white space (space or tab characters only).
    while read -r first_name last_name phone; do
      # Only print the last name (second column)
      printf '%s\n' "$last_name"
    done < "$file"
```

6.4 If the field delimiters are not whitespace, you can set IFS

```
# Extract the username and its shell from /etc/passwd:
while IFS=: read -r user pass uid gid gecos home shell; do
  printf '%s: %s\n' "$user" "$shell"
done < /etc/passwd
```
    You do not necessarily need to know how many fields each line of input contains. If you supply more variables than there are fields, the extra variables will be empty. If you supply fewer, the last variable gets "all the rest" of the fields after the preceding ones are satisfied.

6.5 To avoid lines started with `#` - comments:

```
    # Bash
    while read -r line; do
      [[ $line = \#* ]] && continue
      printf '%s\n' "$line"
    done < "$file"
```

6.6 If your input source is the contents of a variable/parameter, bash can iterate over its lines using a here **string**

```
    while IFS= read -r line; do
      printf '%s\n' "$line"
    done <<< "$var"
```

6.7 Read a command result line by line:

```
    find . -type f -print0 | while IFS= read -r -d '' file; do
        mv "$file" "${file// /_}"
    done
```

But using a pipe to send **find's output** into a while loop places the loop in a *SubShell*, which means any state changes you make (changing variables, cd, opening and closing files, etc.) **will be lost when the loop finishes**. To avoid that, you may use a *ProcessSubstitution*:

```
    while IFS= read -r line; do
      printf '%s\n' "$line"
    done < <(find . -type f -print0)
```

6.8 Read a file passed as argument

```

#!/bin/sh
rf.sh

exec 0<$1 counter=1
while read line; do
echo "$counter: $line" donecounter=$((counter + 1))

# rf.sh /etc/passwd 
```

7. ##### Colorize bash

Install grc: https://github.com/garabik/grc, then run `install.sh "" ""`
DON'T forget to check *path to python* in `grc` and `grcat` executive file: 
```
#! /usr/bin/env python3.7
```

>[Links]
>1. [Great Greg's Wiki](https://mywiki.wooledge.org/)