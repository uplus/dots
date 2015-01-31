	"------------------" 
	"Neobundle Settings"
	"------------------"
filetype plugin indent off

if has('vim_starting')
	"Set the directory to be managed by the bundle
	set runtimepath+=~/.vim/bundle/neobundle.vim
	call neobundle#begin(expand('~/.vim/bundle'))
endif

"Manage neobundle itself neobundle
"NeoBundleFetch 'Shougo/neobundle.vim'
"NeoBundle 'thinca/vim-quickrun'
NeoBundle 'scrooloose/nerdtree'

NeoBundle 'Shougo/unite.vim'
NeoBundle 'tomtom/tcomment_vim'

"The hard to read than I though
"NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'scrooloose/syntastic'
let g:syntastic_cpp_compiler = 'clang++-3.5'
let g:syntastic_cpp_compiler_options = $CLANG_WALL_OPT . ' -std=c++1z '
"-Wall -Wextra -Wno-unused-parameter -Wno-unused-variable'


NeoBundle 'Shougo/neosnippet.vim'
"NeoBundle 'Shougo/neocomplcache'
"NeoBundle 'Shougo/neocomplcache-rsense'

NeoBundle 'sudo.vim'
NeoBundle 'Shougo/vimproc'

"NeoBundle 'VimClojure'
"NeoBundle 'Shougo/vimshell'
"NeoBundle 'jpalardy/vim-slime'

call neobundle#end()
let g:quickrun_config = {
			\'_' : { "outputter/buffer/split" : ":botright" }
			\}

"Reauired
filetype plugin indent on

"when vim startup, auto enable vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1

if !exists('loaded_matchit')
	runtime macros/matchit.vim
endif
