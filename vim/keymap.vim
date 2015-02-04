"C-O is god!
set cpo&vim

"c-o使えば多くのキーマップが不要になるような・・・
"ESCが重いのはカーソルキーのせいかもしれない それとDelete
"noremal のsシリーズは使わないから開いている
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
inoremap <F3> <C-O>:%s//<LEFT>
nnoremap <F3> :%s//<LEFT>
vnoremap <F3> :s/\%V/<LEFT>
inoremap <F4> <C-O>:%s//g<LEFT><LEFT>
nnoremap <F4> :%s//g<LEFT><LEFT>
vnoremap <F4> :s/\%V/g<LEFT><LEFT>


"イメージにあうようにする p 前の行, P後の行
nnoremap p P
nnoremap P p

"line selectの方が使うこと多いし、visualは短形で同じ事ができる
"短形選択はShiftよりもCtrlの方がやりやすい
nnoremap v V
nnoremap V v
vnoremap <BS> d

cnoremap Q q!
cnoremap W! w !sudo tee % > /dev/null

"ins)C-O rでredo
nnoremap r <C-R>
"complite
inoremap <C-U> <C-Y>

"@@@###buffer###@@@
nnoremap bb :b#<CR>
nnoremap bp :bp<CR>
nnoremap bn :bn<CR>
nnoremap bd :bd<CR>
cnoremap bb b#

"@@@###apply speed up###@@@
nnoremap u u
inoremap <C-C> <ESC>
vnoremap d d
vnoremap y y
vnoremap > >
vnoremap < <
vnoremap = =


"######Ctrl+@ family######
"from { to } 
"nnoremap <C-@> %
"inoremap <C-@> <C-O>%


"######Ctrl+W family######
"NERDTree
"nnoremap <silent> <C-W>e :NERDTree<CR>
"inoremap <silent> <C-W>e <ESC>:NERDTree<CR>
nnoremap <silent> <C-W>e :NERDTreeToggle<CR>
inoremap <silent> <C-W>e <ESC>:NERDTreeToggle<CR>

"Window control
nnoremap <C-W>q :bdelete<CR>
inoremap <C-W>q <C-O>:bdelete<CR>

"Tab control
nnoremap <C-W>p gt
nnoremap <C-W>n gT
inoremap <C-W>p <C-O>gt
inoremap <C-W>n <C-O>gT

"C-W shortcut
inoremap <C-W> <C-O><C-W>

call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>+')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>-')
call submode#map('winsize', 'n', '', '>', '<C-w>>')
call submode#map('winsize', 'n', '', '<', '<C-w><')
call submode#map('winsize', 'n', '', '+', '<C-w>+')
call submode#map('winsize', 'n', '', '-', '<C-w>-')

call submode#enter_with('winsize', 'i', '', '<C-w>>', '<C-O><C-w>>')
call submode#enter_with('winsize', 'i', '', '<C-w><', '<C-O><C-w><')
call submode#enter_with('winsize', 'i', '', '<C-w>+', '<C-O><C-w>+')
call submode#enter_with('winsize', 'i', '', '<C-w>-', '<C-O><C-w>-')
call submode#map('winsize', 'i', '', '>', '<C-O><C-w>>')
call submode#map('winsize', 'i', '', '<', '<C-O><C-w><')
call submode#map('winsize', 'i', '', '+', '<C-O><C-w>+')
call submode#map('winsize', 'i', '', '-', '<C-O><C-w>-')

"######Ctrl+S family######
" quit vim
nnoremap <C-S>q	:q<CR>
inoremap <C-S>q	<ESC>:q<CR>

" buffer delete
nnoremap <C-S>d	:bd<CR>
inoremap <C-S>d	<ESC>:bd<CR>

" exit
nnoremap <C-S>e :q!<CR>
inoremap <C-S>e <ESC>:q!<CR>

" save and quit
nnoremap <C-S>z :wq<CR>
inoremap <C-S>z <ESC>:wq<CR>

" Save need #stty -ixon -ixoff
noremap  <silent> <C-S>s :update<CR>
inoremap <silent> <C-S>s <C-O>:update<CR>

" Save single C-S version
noremap  <silent> <C-S> :update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

"######Move######
"結論　ページ単位の移動とかはノーマルモードからする

nnoremap <UP> gk
nnoremap <DOWN> gj
nnoremap <C-j> gj
nnoremap <C-k> gk
nnoremap <C-h> <Left>
nnoremap <C-l> <Right>

inoremap <UP> <C-O>gk
inoremap <DOWN> <C-O>gj
inoremap <C-j> <C-O>gj
inoremap <C-k> <C-O>gk
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-f> <Home>
inoremap <C-g> <End>

vnoremap <UP> gk
vnoremap <DOWN> gj
vnoremap <LEFT> h
vnoremap <RIGHT> l
vnoremap <C-j> gj
vnoremap <C-k> gk
vnoremap <C-h> h
vnoremap <C-l> l
vnoremap <C-f> 0
vnoremap <C-g> $


"######Trash######
"すでに前の行の先頭　にマップされている
" 0 == ^ - == $
"nnoremap - $

