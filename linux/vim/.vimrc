set nocompatible
set history=700

filetype plugin on
filetype indent on

" Disable audible sound
set vb

call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'                  " color scheme
Plug 'chrisbra/improvedft'              " ft to search multiple lines
Plug 'ntpeters/vim-better-whitespace'   " Display trailing whitespaces

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'terryma/vim-multiple-cursors'     " Multiple cursors using Ctrl + N in normal view
Plug 'tpope/vim-eunuch'                 " Run :Rename or :SudoWrite and other commands directly
Plug 'tpope/vim-commentary'             " gc to comment lines

" editor config
Plug 'editorconfig/editorconfig-vim'    " Editor config plugin

Plug 'powerline/powerline'              " Powerline
Plug 'preservim/nerdtree'               " FileTree View

call plug#end()

set autoread
set smartcase
syntax enable

" reload files changed outside vim
set autoread

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Always show status line
set laststatus=2

" Scroll when cursorline reaches bottom 10 line.
set scrolloff=5

" Be smart when using tabs ;)
set smarttab
highlight ColorColumn ctermbg=gray
set colorcolumn=80

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4
set expandtab

" Set colors
hi CursorLineNr guifg=#050505
highlight LineNr ctermfg=black ctermbg=white

" show the last used command in the bottom right
set showcmd

set number
set cursorline
set lazyredraw

set ai
set si
set wrap
set ignorecase
set background=dark
set listchars=tab:>-,eol:$  " for non-printable characters

" Show tabs correctly when doing 'set list'
set statusline+=%F
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
" When a bracket is inserted, briefly jump to matching one
set showmatch
" Show matches very breifly (tenths of a second)
set matchtime=1

set hlsearch
set incsearch
set clipboard=unnamedplus

" almost no delays in switching modes
set timeoutlen=1000 ttimeoutlen=10

colorscheme gruvbox

cnoreabbrev W w
cnoreabbrev Q q

" use w!! to override sudo
cmap w!! w !sudo tee % >/dev/null

noremap <C-S-up> ddkP
noremap <C-S-down> ddp
nnoremap <Space> i
nnoremap <F6> :! python %
nnoremap <F7> :set paste
nnoremap <F9> :set invnumber<CR>
nnoremap <F10> :%s/\s\+$//e
nnoremap <F11> :set invrelativenumber<CR>
nnoremap <F3> :!

set wildmode=longest,list,full
" visual autocompleting for the command menu
set wildmenu

if has("autocmd")
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab>   :tabnext<CR>
inoremap <C-S-tab> <Esc>:tabprevious<CR>i
inoremap <C-tab>   <Esc>:tabnext<CR>i

" Open Files using FZF
map \ :Files<CR>" nnoremap <c-> :tabnew<CR>
