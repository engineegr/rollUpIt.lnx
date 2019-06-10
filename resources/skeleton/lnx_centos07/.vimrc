colorscheme badwolf
set clipboard=unnamedplue

filetype indent on
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

syntax enable

set cursorline
set wildmenu
set showmatch
set number
set hlsearch 
set incsearch 

" map to <\>+<space>
nnoremap <leader><space> :nohlsearch<CR>
nnoremap <CR> G
nnoremap j gj
nnoremap k gk
nnoremap gV `[v`]
nnoremap <leader>k :sh<CR>
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>

set statusline=
" set statusline+=%#LineNr#
set statusline+=\ %f

