	"------------------" 
	"Neobundle Settings"
	"------------------"
filetype plugin indent off

if has('vim_starting')
	"Set the directory to be managed by the bundle
	set runtimepath+=~/.vim/bundle/neobundle.vim
	call neobundle#begin(expand('~/.vim/bundle'))
endif

NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'kana/vim-submode'			" vimに独自のモードを作成できる

NeoBundle 'Shougo/unite.vim'
NeoBundle 'tomtom/tcomment_vim'

NeoBundle 'kana/vim-smartchr'
NeoBundle 'kana/vim-smartinput'

NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/vimshell'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'Rip-Rip/clang_complete'

NeoBundle 'Shougo/neocomplete'
"NeoBundle 'Shougo/neosnippet.vim'
"NeoBundle 'Shougo/neocomplcache-rsense'


call neobundle#end()

" NERDTree
"他のバッファをすべて閉じた時にNERDTreeが開いていたらNERDTreeも一緒に閉じる。
""How can I close vim if the only window left open is a NERDTree?
"autocmd bufenter * if (winnr("$") == 1 && exists('b:NERDTreeType') && b:NERDTreeType == 'primary') | q | endif
"
"0ならそのまま開いとく, 1なら閉じる
"let g:NERDTreeQuitOnOpen=0	"//defo 0
"let g:NERDTreeShowHidden=0	"//defo 0
let g:NERDTreeWinSize=26	"//defo 31

"let g:quickrun_config = { '_' : { "outputter/buffer/split" : ":botright" } }

" syntastic
let g:syntastic_cpp_compiler = 'clang++-3.5'
let g:syntastic_cpp_compiler_options = $CLANG_WALL_OPT . ' -std=c++1z '

" Complete
	" menu		候補が2つ以上あるときメニューを表示する
	" longest	候補が共通部分だけを挿入する
	" preview	付加的な情報を表示
set completeopt=menu,longest,preview

hi Pmenu	ctermbg=0
hi Pmenu	ctermbg=242
hi PmenuSel ctermbg=6	ctermfg=40
"hi PmenuSel ctermbg=70 ctermfg=129

set path+=/usr/include/c++/4.9.1

" neocomplete
let g:neocomplete#enable_at_startup	= 1
let g:neocomplete#enable_smart_case = 1
if !exists('g:neocomplete#keyword_patterns')
	let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns._ = '\h\w*'

if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif

let g:neocomplete#force_omni_input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|::' 

inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" clang_complete
let g:clang_complete_auto		= 0
"let g:clang_auto_select			= 0
let g:clang_periodic_quickfix	= 0
let g:clang_complete_copen		= 1
let g:clang_use_library			= 1


" this need to be updated on llvm update
let g:clang_library_path  =  '/usr/lib/llvm-3.5/lib'
" specify compiler options
let g:clang_user_options  =  '-std=c++1z -stdlib=libc++'

" UP DOWNで保管しないようにする
" C-Hが上書きされるのを何とかする

"Reauired
filetype plugin indent on
if !exists('loaded_matchit')
	runtime macros/matchit.vim
endif
