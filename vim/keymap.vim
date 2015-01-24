"C-O is god!

set cpo&vim

"C-O使えば多くのキーマップが不要になるような・・・
"
"Ctrl-MはなぜかReturnとかぶる

"Copy, Cut, Paste
nnoremap <C-C> yy
nnoremap <C-X> dd
nnoremap <C-V> P
inoremap <C-C> <C-O>yy
inoremap <C-X> <C-O>dd
inoremap <C-V> <C-O>P

"Undo and Redo "
inoremap <C-R> <C-O><C-R>
inoremap <C-T> <C-O>u

"replace
inoremap <F3> <C-O>:%s//g<LEFT><LEFT>
nnoremap <F3> :%s//g<LEFT><LEFT>
vnoremap <F3> %s//g<LEFT><LEFT>

"line selectの方が使うこと多いしvisualは短形で同じ事ができる
nnoremap p P
nnoremap P p

"C-Vがredoに取られてる  insertからのvisualはC-Oと組み合わせて使う
nnoremap t <C-V>

"For undo separate
inoremap <CR> <CR><ESC>i

"もっと重要なのにする C-Oがいいかも
"inoremap <C-SPACE> <ESC>

"######Ctrl+@ family######

inoremap <C-@>] <End><CR>

"from { to } 
nnoremap <C-@>@ %
inoremap <C-@>@ <C-O>%


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
nnoremap <C-j> <Down>
nnoremap <C-k> <UP>

inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-u> <C-O><C-u>
inoremap <C-n> <C-O><C-d>

inoremap <C-F> <Home>
inoremap <C-G> <End>

