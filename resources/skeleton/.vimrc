colorscheme desert
set clipboard=unnamedplue
set tabstop=4
syntax on
nnoremap <CR> G
set number
set statusline="%f%m%r%h%w [%Y] [0x%02.2B]%< %F%=%4v,%4l %3p%% of %L"

filetype indent on
set tabstop=4
set shiftwidth=4
set expandtab
:highlight Constant term=underline ctermfg=2 gui=bold guifg=darkkhaki 

nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>

set statusline+=%F
