#### Powerline

1. ##### Setup powerline in vim (MacOS)
    - prepare Term2:

    ```
    brew tap homebrew/fonts
    brew cask install font-hack-nerd-font
    ```

    Set non-ASCII Fonts as **Hack Nerd Font** (Preferences -> Profiles -> Text)

    - vim plugins:
    ```
    Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
    Plugin 'ryanoasis/vim-devicons'
    Plugin 'vim-airline/vim-airline'
    Plugin 'vim-airline/vim-airline-themes'
    Plugin 'enricobacis/vim-airline-clock'
    ```

    - vim options:
    ```
    set encoding=utf-8
    set fileencoding=utf-8
    set termencoding=utf-8
    set laststatus=2
    set t_Co=256
    ```

    - Powerline setup:
    ```
    " Powerline
    " Setup airline
    let g:airline#extensions#tabline#enabled = 1
    " Display time (use vim-airline-clock plugin)
    " let g:airline#extensions#clock#format = '%H:%M:%S'
    let g:airline#extensions#clock#format = '%Y %b %d %X'   
    ```
