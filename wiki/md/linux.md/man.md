#### Man
--------

1. ##### Colorized man
    
    Add to *.bashrc*:

            # colored man pages
            # http://askubuntu.com/a/439411/260920
            man() {
            case "$(type -t -- "$1")" in
            builtin|keyword)
            help -m "$1" | `which less`
            ;;
            *)
            env LESS_TERMCAP_mb=$'\E[01;31m' \
            LESS_TERMCAP_md=$'\E[01;38;5;74m' \
            LESS_TERMCAP_me=$'\E[0m' \
            LESS_TERMCAP_se=$'\E[0m' \
            LESS_TERMCAP_so=$'\E[38;5;246m' \
            LESS_TERMCAP_ue=$'\E[0m' \
            LESS_TERMCAP_us=$'\E[04;38;5;146m' \
            man "$@"
            ;;
            esac
        }
    
    To change search highlighting it needs to opt `export LESS_TERMCAP_so=$'\E[30;43m'` where where 30 means black foreground, and 43 yellow background. 

    >[!Links]
    > 1.http://askubuntu.com/a/439411/260920
    > 
    > 2. https://unix.stackexchange.com/questions/169952/man-page-highlight-color 