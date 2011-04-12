set nocompatible

" init pathogen
filetype off 
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

syntax on
filetype plugin indent on
set encoding=utf-8
" set mouse=a
set ruler
set number
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoread
" set paste

let mapleader = ","
let g:mapleader = ","

" Normal behaviour of backspace key
set backspace=indent,eol,start

" Textmate scheme colors clone
" colorscheme vividchalk
  colorscheme vibrantink
" colorscheme herald
" colorscheme jellybeans

" don't keep backup after close
set nobackup

" do keep a backup while working
set writebackup
" Store temporary files in a central spot
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp


" Set tag files
set tags=tags,./tags,tmp/tags,./tmp/tags


" Default browser
command -bar -nargs=1 OpenURL :!firefox <args> 2>&1 >/dev/null &


" Set minium window size
set wmh=0
" Mapeamos las teclas + y - para que nos maximice o minimice la ventana actual
if bufwinnr(1)
	map + <C-W>_
	map - <C-W>=
endif


" Move between tabs
" Note: tabnext = gt AND tabprevious = gT
" nnoremap <c-n> <esc>:tabnext<CR>
" nnoremap <c-p> <esc>:tabprevious<CR>
" nnoremap <silent> <C-t> :tabnew<CR>
" tip 199 (comments) - Open actual buffer in a tab and then close
nmap t% :tabedit %<CR>
nmap td :tabclose<CR>
nmap tn :tabnew<CR>


" Paste from X clipboard to vim
" Commented to use Visual blocks
vnoremap <C-C> "+y
"noremap <C-V> <ESC>"+gP
inoremap <C-V> <ESC>"+gPi


"  move text and rehighlight -- vim tip_id=224
"vnoremap > ><CR>gv
"vnoremap < <<CR>gv
" Enable TAB indent and SHIFT-TAB unindent
vnoremap <silent> <TAB> >gv
vnoremap <silent> <S-TAB> <gv


"statusline setup
set statusline=%f "tail of the filename

"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h "help file flag
set statusline+=%y "filetype
set statusline+=%r "read only flag
set statusline+=%m "modified flag

"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=%{StatuslineTrailingSpaceWarning()}

set statusline+=%{StatuslineLongLineWarning()}

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%= "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%c, "cursor column
set statusline+=%l/%L "cursor line/total lines
set statusline+=\ %P "percent through file
set laststatus=2

"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction


"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning = '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction


"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction

"syntastic settings
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2




" Toggle paste mode
nmap <silent> <F2> :set invpaste<CR>:set paste?<CR>
" Toggle Highlight search - deprecated now I use :nohl
"nmap <silent> <F3> :set invhls<CR>:set hls?<CR>
" Toggle List 
" set listchars=tab:>-,trail:·,eol:$
set listchars=tab:▸\ ,eol:¬
nmap <silent> <F3> :set invlist<CR>:set list?<CR>
" set text wrapping toggles
nmap <silent> <F4> :set invwrap<CR>:set wrap?<CR>
" search highlight
set hlsearch



" ACK integration
set grepprg=ack-grep 
set grepformat=%f:%l:%m

" Find searched_string in directories(...)
function RailsGrep(searched_string,...)
	let s:dir_list = ''
	for dir in a:000
		let s:dir_list = s:dir_list . dir
	endfor
	execute "silent! grep --ruby " . a:searched_string . " " . s:dir_list
	botright cw
	redraw!
endfunction
" Find searched_string in all project(app and lib directories)
:command -nargs=+ Rgrep call RailsGrep('<q-args>',"app/ lib/ config/initializers vendor/plugins")
" Find  definition in the project(models,controllers,helpers and lib)
:command -nargs=1 Rgrepdef call RailsGrep("'def .*" . <q-args> . "'","app/models app/controllers app/helpers lib/ config/initializers vendor/plugins")



let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_include_object = 1
autocmd FileType ruby,eruby let g:rubycomplete_include_objectspace = 1
map <leader>mr <ESC>:rubyf %<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Recommendations from http://items.sjbach.com/319/configuring-vim-right "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 
" Jump to mark line and column
nnoremap ' `
" Jump to mark line
nnoremap ` '

" Keep a longer history
set history=1000

" Use case-smart searching
set ignorecase 
set smartcase

" Set terminal title
set title

" Maintain more context around the cursor
set scrolloff=3
set sidescrolloff=5

" When a bracket is insert, briefly jump to the matching one.
set showmatch
" Show command in the last line of the screen
set showcmd

" Make file/command completion useful
" Show a wildmenu when try to find a command or file
set wildmenu
set wildmode=longest,full

" Read on comments:
set diffopt+=iwhite             " ignore whitespace in diff mode


"""""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree
"""""""""""""""""""""""""""""""""""""""""""""""""
let NERDChristmasTree = 1
let NERDTreeHighlightCursorline = 1
let NERDTreeShowBookmarks = 1
let NERDTreeShowHidden = 1
let NERDTreeIgnore = ['.vim$', '\~$', '.svn$', '\.git$', '.DS_Store', '.sass-cache']
nmap <leader>w :NERDTreeToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""
" FuzzyFinder                                   "
" Provides convenient ways to quickly reach the "
" buffer/file/command/bookmark/tag you want.    "
"""""""""""""""""""""""""""""""""""""""""""""""""
let g:fuzzy_ignore = "*.log,*.jpg,*.png,*.gif,*.swp"
let g:fuzzy_matching_limit = 70
map <leader>ft :FuzzyFinderTextMate<CR>
map <leader>ff :FuzzyFinderFile<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""
" Matchit                                         "
" Load matchit (% to bounce from do to end, etc.) "
"""""""""""""""""""""""""""""""""""""""""""""""""""
runtime! plugin/matchit.vim
runtime! macros/matchit.vim


""""""""""""""""""""""""""""""""""""""""""""""""""
" allml                                          "
" Provide maps for editing tags                  "
""""""""""""""""""""""""""""""""""""""""""""""""""
let g:allml_global_maps = 1 


""""""""""""""""""""""""""""""""""""""""""""""""""
" gist                                           "
""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gist_open_browser_after_post = 1
let g:gist_detect_filetype = 1
let g:gist_browser_command = 'firefox %URL% &'

""""""""""""""""""""""""""""""""""""""""""""""""""
" Snipmate with AutoComplPop(acp)                "
""""""""""""""""""""""""""""""""""""""""""""""""""
"let g:acp_behaviorSnipmateLength = 1
"let g:acp_ignorecaseOption = 0


""""""""""""""""""""""""""""""""""""""""""""""""""
" VCScommand                                     "
" VIM 7 plugin useful for manipulating files     "
" controlled by CVS, SVN, SVK, git, bzr, and hg. "
""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove detault mappings
" let VCSCommandDisableMappings=1

""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimwiki                                        "
""""""""""""""""""""""""""""""""""""""""""""""""""

"let g:vimwiki_list = [{'path': '~/Documents/vimwiki/',
"			\ 'path_html': '~/Documents/vimwiki_html/'}]


""""""""""""""""""""""""""""""""""""""""""""""""""
" Ruby Debugger                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:ruby_debugger_fast_sender = 1

" Edit the README_FOR_APP (makes :R commands work)
" map <Leader>R :e doc/README_FOR_APP<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
" Rails 																				 "
""""""""""""""""""""""""""""""""""""""""""""""""""
map <Leader>m :Rmodel
map <Leader>c :Rcontroller
map <Leader>v :Rview
"map <Leader>u :Runittest
"map <Leader>tm :RTmodel
"map <Leader>tc :RTcontroller
"map <Leader>tv :RTview
"map <Leader>tu :RTunittest
"map <Leader>tf :RTfunctionaltest
"map <Leader>sm :RSmodel
"map <Leader>sc :RScontroller
"map <Leader>sv :RSview
"map <Leader>su :RSunittest
"map <Leader>sf :RSfunctionaltest 
" Hard to type ******
imap uu _
imap hh =>
imap aa @

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

"map Q to something useful
noremap Q gq

map <Leader>n :set nopaste
map <Leader>p :set paste<CR>i





