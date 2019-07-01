#### Bash
---------

1. ##### Check a variable type: user `declare`

[From](https://www.tldp.org/LDP/abs/html/declareref.html):

> The declare or typeset builtins, which are exact synonyms, permit modifying the properties of variables. This is a very weak form of the typing [1] available in certain programming languages. The declare command is specific to version 2 or later of Bash. The typeset command also works in ksh scripts.

1.1 Check if a variable is **array**

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

2.1 Regular variable

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

2.2 Arrays: pass an array by reference

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
