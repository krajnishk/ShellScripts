"
"	================================================================
"	===========		.vimrc		========================
"	================================================================
"
"	Plugins using Vim-Plug
call plug#begin('~/.vim/plugged')
	
	"	NerdTree File Explorer
	Plug 'preservim/nerdtree'

	"	Statusline
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'

	"	Git Plugins
	Plug 'tpope/vim-fugitive'
	Plug 'airblade/vim-gitgutter'

	"	colorscheme
	Plug 'crusoexia/vim-monokai'

call plug#end()
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail'
"
"	================================================================
"	================	VIM SETTINGS		================
"	================================================================

"   =================   SH TEMPLATE     ====================
autocmd bufnewfile *.sh so ~/.vim/sh_header.temp
autocmd bufnewfile *.sh exe "1," . 30 . "g/ScriptName    :    .*/s//ScriptName    :    " .expand("%")
autocmd bufnewfile *.sh exe "1," . 30 . "g/Created Date  :    .*/s//Created Date  :    " .strftime("%c")
autocmd bufnewfile *.sh exe "15," . 40 . "g/DATE_HERE/s/DATE_HERE/" .strftime("%F")
autocmd Bufwritepre,filewritepre *.sh execute "normal ma"
autocmd Bufwritepre,filewritepre *.sh exe "1," . 20 . "g/Last Modified :    .*/s/Last Modified :    .*/Last Modified :    " .strftime("%c")
autocmd bufwritepost,filewritepost *.sh execute "normal `a"

"   Terminal Colorsettings
set t_Co=256

"   Map Leader
let mapleader = ","

"   Keybindings
map <C-n> :NERDTreeToggle<CR>

"   TogglePasteMode
set pastetoggle=<F2>

"	Set Clipboard
set clipboard=unnamed

"	Show Numbers and Relative Number
set number
set relativenumber

"	Show History and not compatible with legacy vi
set history=1000
set nocompatible

"	Enable Syntax Highlight
syntax enable
syntax on

"	Highlight current Line & Column
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline cursorcolumn

"	Colorscheme & Background
set background=dark
colorscheme monokai

"	Searching
set incsearch
set ignorecase
set smartcase

"	Auto scroll with 10 line above & below
set scrolloff=10

"	Default indentation
set autoindent
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
set expandtab

"	Line width
set textwidth=120

"	Disable Folding
set nofoldenable
set foldmethod=indent

"	Show Tabline at the top
"set showtabline=2

"	file encoding
set fileencodings=utf-8
filetype plugin indent on

"	Prompt before existing for an unsaved file
set confirm

"	use mouse in all mode
"set mouse=a

"	report number of lines changed
set report=1

"	Wrap text
set nowrap

"	show typed command in status bar
set showcmd

"	show file in titlebar
set title

"	statusline 
set laststatus=2

"	show matching bracket
set showmatch

"	splitscreen
set splitbelow
set splitright

"	Python Filetype
autocmd	FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 textwidth=120

