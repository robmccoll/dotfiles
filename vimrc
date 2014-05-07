
" normal backspace
set backspace=2

" syntax highlighting
syntax on

" indenting
filetype indent on
set autoindent
set smartindent

" enable filetype plugins
filetype plugin on

" line ruler and ruler at bottom
set number
set ruler

" show auto complete menu
set wildmenu

" bash completion
set wildmode=list:longest

" highlight matching brackets
set showmatch

" search options
set ignorecase
set smartcase
set hlsearch " highlight results
set incsearch
set lazyredraw

" space and tabs
set expandtab
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=4

" linebreak at 500 chars
set lbr
set tw=500

set nowrap

" jump lines when wrapped
map j gj
map k gk

" write anywhere
set virtualedit=all

" keep selection after operation
vnoremap > ><CR>gv 
vnoremap < <<CR>gv 

" enable mouse support
set mouse=a

" Restore cursor position to where it was before
augroup JumpCursorOnEdit
   au!
   autocmd BufReadPost *
            \ if expand("<afile>:p:h") !=? $TEMP |
            \   if line("'\"") > 1 && line("'\"") <= line("$") |
            \     let JumpCursorOnEdit_foo = line("'\"") |
            \     let b:doopenfold = 1 |
            \     if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
            \        let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
            \        let b:doopenfold = 2 |
            \     endif |
            \     exe JumpCursorOnEdit_foo |
            \   endif |
            \ endif
   " Need to postpone using "zv" until after reading the modelines.
   autocmd BufWinEnter *
            \ if exists("b:doopenfold") |
            \   exe "normal zv" |
            \   if(b:doopenfold > 1) |
            \       exe  "+".1 |
            \   endif |
            \   unlet b:doopenfold |
            \ endif
augroup END

" Use english for spellchecking, but don't spellcheck by default
if version >= 700
  set spl=en spell
  set nospell
endif


