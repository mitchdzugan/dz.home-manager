" TODO look into these more
set nu rnu
set nocompatible
set showtabline=2
set scl=yes
set hlsearch
set number
set cursorline
set hidden
set visualbell
set t_vb=
if has('mouse')
  set mouse=a
endif

" tab default stuff
set expandtab
set tabstop=2
set shiftwidth=2
set nowrap

" escape tmux thing  I think
set t_ZH=␛[3m
set t_ZR=␛[23m

" set leaders
let mapleader = ";"
let maplocalleader = "\\"

" turn on colors when can
syntax on
if has('termguicolors')
    set termguicolors
endif

" save position on file exit
""" autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" bg textures
set list lcs=trail:·,tab:🮙🮙,lead:🮙

" copy/paste
set clipboard+=unnamedplus

" make status bar less annoying. not sure if good
set noshowcmd

" set inital colorscheme
" colorscheme delek
" set background=dark

" ensure folds start collapsed
set foldlevelstart=99

set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175
