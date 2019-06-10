### less
-------

1. ##### How to make less open files in colors?
    1. Install *pygments*
    2. Add *.lessfilter* to *~/*:

            #!/bin/sh
            case "$1" in
                *.awk|*.groff|*.java|*.js|*.m4|*.php|*.pl|*.pm|*.pod|*.sh|\
                *.ad[asb]|*.asm|*.inc|*.[ch]|*.[ch]pp|*.[ch]xx|*.cc|*.hh|\
                *.lsp|*.l|*.pas|*.p|*.xml|*.xps|*.xsl|*.axp|*.ppd|*.pov|\
                *.diff|*.patch|*.py|*.rb|*.sql|*.ebuild|*.eclass)
                    pygmentize -f 256 "$1";;

                .bashrc|.bash_aliases|.bash_environment)
                    pygmentize -f 256 -l sh "$1";;

                *)
                    if grep -q "#\!/bin/bash" "$1" 2> /dev/null; then
                        pygmentize -f 256 -l sh "$1"
                    else
                        exit 1
                    fi
            esac

            exit 0

    3. Export the following envirenment vars:
                
                LESS='-R'
                LESSOPEN='|~/.lessfilter %s'
        
        > [!Note]
        > ##### LESS
        > Options are also taken from the environment variable "LESS".  For 
        > example, to avoid typing "less -options ..." each time less is 
        > invoked, you might tell csh:
        > 
        >       setenv LESS "-options"
        > 
        > or if you use sh:
        > 
        >       LESS="-options"; export LESS
        >       
        > ##### LESSOPEN
        >  -L or --no-lessopen - Ignore  the  LESSOPEN  environment  
        > variable (see the INPUT PREPROCESSOR section below).  
        > This option can be set from within less, but it will 
        > apply only to files opened subsequently, not to the file which is 
        > currently open.      
        > 
        > 
        > It  is  also possible to set up an input preprocessor to pipe the file data directly to less, rather than putting the data into a replacement file.  This avoids the need
        > to decompress the entire file before starting to view it.  An input preprocessor that works this way is called an input pipe.  An input pipe, instead of writing the name
        > of a replacement file on its standard output, writes the entire contents of the replacement file on its standard output.  If the input pipe does not write any characters
        > on its standard output, then there is no replacement file and less uses the original file, as normal.  To use an input pipe, make the first  character  in  the  LESSOPEN
        > environment variable a vertical bar (|) to signify that the input preprocessor is an input pipe.
        > 
        > For example, on many Unix systems, this script will work like the previous example scripts:
        > 
                lesspipe.sh:
                #! /bin/sh
                case "$1" in
                *.Z) uncompress -c $1  2>/dev/null
                *)   exit 1
                ;;
                esac
                exit $?
        > 
        > To use this script, put it where it can be executed and set LESSOPEN="|lesspipe.sh %s".

2. ##### How to open in color the result of *grep*, *ls*:

        egrep --color=always -r -e *VIMRUNTIME* . | less -R
        ls --color=always | less

