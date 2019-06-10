#### Regular expression in Bash 
-------------------------------
1. ##### Meta-symbols \<\>
It defines word borders.

```
# cat textfile

This is line 1, of which there is only one instance. 
This is the only instance of line 2.
This is line 3, another line.
This is line 4.

# grep '\<the\>' textfile
This is the only instance of line 2.
```

2. ##### Meta-symbols "\{value\}"
How many times does the previous expression repeat?
```
[0-9]\{5\}
```

3. ##### Built-in Bash regular expression (since 3d version)

It returns 0 if the expression matches otherwise returns 1
```
if [ $str ~= $reg_exp ]; then
...
fi 
```

4. #### Built-in Bash regular expressions: sub-patterns

In addition to doing simple matching, bash regular expressions support sub-patterns surrounded by parenthesis for capturing parts of the match. The matches are assigned to an array variable BASH_REMATCH. The entire match is assigned to BASH_REMATCH[0], the first sub-pattern is assigned to BASH_REMATCH[1] and etc.

```
#!/bin.bash

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 PATTERN STRINGS..."
    exit 1
fi
regex=$1
shift
echo "regex: $regex"
echo

while [[ $1 ]]
do
    if [[ $1 =~ $regex ]]; then
        echo "$1 matches"
        i=1
        n=${#BASH_REMATCH[*]}
        while [[ $i -lt $n ]]
        do
            echo "  capture[$i]: ${BASH_REMATCH[$i]}"
            let i++
        done
    else
        echo "$1 does not match"
    fi
    shift
done
```

##### 5. Match ssh-connection string like **likhobabin_im@domain.com**

1. Linux username 
Length <= 32
[[:alpha:]_][[:alnum:]_-]{30}[$]?
or
With use of lookeahead positive:

(?=^.{1,32}$)^([[:alpha:]_])(?:([[:alnum:]_-][$]?){0,30})$

2. Domain name
(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,}))$

3. IPv4 address
^([:digit:]{1,3}\.){3}([:digit:]{1,3})$

4. Full regular expression
^([[:alpha:]_])?:([[:alnum:]_-][$]?){0,30}@((?=.{5,254})(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})|([:digit:]{1,3}\.){3}([:digit:]{1,3}))


##### 6. Capturing and non-capturing group

Consider a pattern where you need to check for a variety of things in a single position, e.g a bunch of different two character patterns. Normally you use the | alternation operator:
```
/(ab|cd|ef)/
```
which requires use of () brackets as well. But those brackets also act as a capturing group. Maybe you really don't want to capture those char sequences, just check for their presence, which is where the non-capturing groups come into play:
```
/(?:ab|cd|ef)/
```

A capturing group allow you to reuse part of the regex match. You can reuse it inside the regular expression, or afterwards for example in a replace statement :

consider this text : 1a2b3cdef7g9h and this regex : ([0-9]*)([a-z]*) There's two capturing groups, the first one which capture the sequences of digits, the second one for capturing sequences of letters.

So you can use a replaceAll statement to keep digits using the first capturing group ($1) or to keep letters with the second one ($2).

    // next line outputs : 12379
    System.out.println("1a2b3cdef7g9h".replaceAll("([0-9]*)([a-z]*)", "$1"));

    // next line outputs : abcdefgh
    System.out.println("1a2b3cdef7g9h".replaceAll("([0-9]*)([a-z]*)", "$2"));

But when you use a non capturing group (for example by adding ?: it does not capture, and it's sometimes usefull. So for example :

    // next line outputs : abcdefgh
    //  ([a-z]*) becomes the first capturing group because (?:[0-9]*) is a non-capturing group
    System.out.println("1a2b3cdef7g9h".replaceAll("(?:[0-9]*)([a-z]*)", "$1"));

Try it on http://gskinner.com/RegExr at the bottom of the screen you can see where are your capturing groups

7. ##### Positive and negative lookahead

**?:**  is for non capturing group
**?=**  is for positive look ahead
**?!**  is for negative look ahead
**?<=** is for positive look behind
**?<!** is for negative look behind

>[!Notes]
>1. Generally, the decision about using ?: is not about whether it's necessary, but that capturing whatever you're grouping isn't necessary. The ?: modifier makes parentheses not capture, which is somewhat more efficient and might make the task of counting left parentheses less onerous.

>[!Links]
>1. [Lookahead](https://www.rexegg.com/regex-disambiguation.html#lookarounds)

