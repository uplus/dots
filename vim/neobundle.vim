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

"NeoBundle 'kana/vim-submode'


NeoBundle 'Shougo/unite.vim'
NeoBundle 'tomtom/tcomment_vim'

"NeoBundle 'thinca/vim-quickrun'
"The hard to read than I though
"NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'Shougo/vimproc'

NeoBundle 'Shougo/neosnippet.vim'
"NeoBundle 'Shougo/neocomplcache'
"NeoBundle 'Shougo/neocomplcache-rsense'

"NeoBundle 'sudo.vim'
"	:w !sudo tee % > /dev/null でOK


"NeoBundle 'VimClojure'
"NeoBundle 'Shougo/vimshell'
"NeoBundle 'jpalardy/vim-slime'

call neobundle#end()

"syntastic
let g:syntastic_cpp_compiler = 'clang++-3.5'
let g:syntastic_cpp_compiler_options = $CLANG_WALL_OPT . ' -std=c++1z '

"他のバッファをすべて閉じた時にNERDTreeが開いていたらNERDTreeも一緒に閉じる。
""How can I close vim if the only window left open is a NERDTree?
"autocmd bufenter * if (winnr("$") == 1 && exists('b:NERDTreeType') && b:NERDTreeType == 'primary') | q | endif
"
"0ならそのまま開いとく, 1なら閉じる
"let g:NERDTreeQuitOnOpen=0	//defo 0
"let g:NERDTreeShowHidden=0	//defo 0
"let g:NERDTreeWinSize=31	//defo 31
""
let g:quickrun_config = {
			\'_' : { "outputter/buffer/split" : ":botright" }
			\}



"when vim startup, auto enable vim-indent-guides
"let g:indent_guides_enable_on_vim_startup = 1

"Reauired
filetype plugin indent on
if !exists('loaded_matchit')
	runtime macros/matchit.vim
endif
