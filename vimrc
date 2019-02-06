highlight Pmenu ctermbg=blue
highlight goTodo ctermbg=red

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

" ignore case on file autocomplete
set wildignorecase

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
autocmd BufNewFile,BufRead *.go set noexpandtab
autocmd BufNewFile,BufRead *.go set shiftwidth=4
autocmd BufNewFile,BufRead *.go set softtabstop=4
autocmd BufNewFile,BufRead *.go set tabstop=4


" linebreak at 500 chars
set lbr
set tw=80

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

" F3 lists buffers and selects one
nnoremap <F3> :ls<CR>:bu<Space>

" godef opens in new tab
let g:godef_split = 2

" session saving and loading
map <F2> :Sq<CR>
set ssop+=folds  " save folds
command Sq call SaveAndQuit()
command S call Save()
function! Save()
  :mksession! .session.vim
  :wa
endfun
function! SaveAndQuit()
  :mksession! .session.vim
  :wqa
endfun

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

" Rename tabs to show tab number.
" (Based on http://stackoverflow.com/questions/5927952/whats-implementation-of-vims-default-tabline-function)
if exists("+showtabline")
    function! MyTabLine()
        let s = ''
        let wn = ''
        let t = tabpagenr()
        let i = 1
        while i <= tabpagenr('$')
            let buflist = tabpagebuflist(i)
            let winnr = tabpagewinnr(i)
            let s .= '%' . i . 'T'
            let s .= (i == t ? '%1*' : '%2*')
            let s .= ' '
            let wn = tabpagewinnr(i,'$')

            let s .= '%#TabNum#'
            let s .= i
            " let s .= '%*'
            let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
            let bufnr = buflist[winnr - 1]
            let file = bufname(bufnr)
            let buftype = getbufvar(bufnr, 'buftype')
            if buftype == 'nofile'
                if file =~ '\/.'
                    let file = substitute(file, '.*\/\ze.', '', '')
                endif
            else
                let file = fnamemodify(file, ':p:t')
            endif
            if file == ''
                let file = '[No Name]'
            endif
            let s .= ' ' . file . ' '
            let i = i + 1
        endwhile
        let s .= '%T%#TabLineFill#%='
        let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
        return s
    endfunction
    set stal=2
    set tabline=%!MyTabLine()
    set showtabline=1
    highlight link TabNum Special
endif

" Use english for spellchecking, but don't spellcheck by default
if version >= 700
  set spl=en spell
  set nospell
endif




