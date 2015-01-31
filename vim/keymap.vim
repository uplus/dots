"C-O is god!
set cpo&vim

"c-o使えば多くのキーマップが不要になるような・・・
"Ctrl-M は<CR>
"Ctrl-[ は<ESC>
"Ctrl-i は<TAB>
"insert-mode でのESCのマッピングは良くない

"提案
"ins)C-a,x inc,dec
"ins)C-d, <BS>
"ins)C-e, <Del>
"from { to }

"replace
"バリエーションを増やす？
inoremap <F3> <C-O>:%s//g<LEFT><LEFT>
nnoremap <F3> :%s//g<LEFT><LEFT>
vnoremap <F3> %s//g<LEFT><LEFT>

"イメージにあうようにする p 前の行, P後の行
nnoremap p P
nnoremap P p

"line selectの方が使うこと多いし、visualは短形で同じ事ができる
nnoremap v V
nnoremap V v
nnoremap t <C-V>

"ins)C-O rでredo
nnoremap r <C-R>
"complite
inoremap <C-U> <C-y>

"apply speed up
nnoremap u u
vnoremap d d
vnoremap y y

"For undo separate
"auto-indent smart-indentが崩れる
"inoremap <silent> <CR> <CR><ESC>i

"標準のだとstatus-line colorが変わらない
inoremap <C-C> <ESC>

"nnoremap <BS> X
"nnoremap <Del> x
vnoremap <BS> d

"もっと重要なのにする C-Oがいいかも
"inoremap <C-SPACE> <ESC>

"from { to } 
nnoremap <C-@> %
inoremap <C-@> <C-O>%

"######Ctrl+@ family######

"######Ctrl+W family######
"NERDTree
nnoremap <C-W>e :NERDTree<CR>
inoremap <C-W>e <ESC>:NERDTree<CR>

"Tab control
nnoremap <C-W>d gt
nnoremap <C-W>n gT
inoremap <C-W>d <C-O>gt
inoremap <C-W>n <C-O>gT

"Window control
nnoremap <C-W>q :bdelete<CR>
inoremap <C-W>q <C-O>:bdelete<CR>

"C-W shortcut
inoremap <C-W> <C-O><C-W>

"######Ctrl+S family######
"Quit vim
nnoremap <C-S>q	:q<CR>
inoremap <C-S>q	 <ESC>:q<CR>

"exit
nnoremap <C-S>e :q!<CR>
inoremap <C-S>e <ESC>:q!<CR>

"save and quit
nnoremap <C-S>z :wq<CR>
inoremap <C-S>z <ESC>:wq<CR>

"Save	need #stty -ixon -ixoff
noremap  <silent> <C-S>s :update<CR>
inoremap <silent> <C-S>s <C-O>:update<CR>

"Save single C-S version
noremap  <silent> <C-S> :update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

"######move######
"結論　ページ単位の移動とかはノーマルモードからする

nnoremap <C-j> <Down>
nnoremap <C-k> <UP>
nnoremap <C-h> <Left>
nnoremap <C-l> <Right>

inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-f> <Home>
inoremap <C-g> <End>

vnoremap <UP> k
vnoremap <DOWN> j
vnoremap <LEFT> h
vnoremap <RIGHT> l
vnoremap <C-j> k
vnoremap <C-k> j
vnoremap <C-h> h
vnoremap <C-l> l
vnoremap <C-f> 0
vnoremap <C-g> $

"######Trash######
"すでに前の行の先頭　にマップされている
" 0 == ^ - == $
"nnoremap - $

