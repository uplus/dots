set cpo&vim

"Copy, Cut, Paste
vnoremap <C-C> y
vnoremap <C-X> x
nnoremap <C-C> yy
nnoremap <C-X> dd
nnoremap <C-V> P
inoremap <C-C> <C-O>yy
inoremap <C-X> <C-O>dd
inoremap <C-V> <C-O>P

"Undo and Redo "なくすか
inoremap <C-R> <C-O><C-R>
inoremap <C-T> <C-O>u

" backspace in Visual mode deletes selection
vnoremap <BS> d
inoremap <C-Z>z	<C-O><C-Z>

nnoremap <F2> /
inoremap <F2> <C-O>/

"replace
inoremap <F3> <C-O>:%s//g<LEFT><LEFT>
nnoremap <F3> :%s//g<LEFT><LEFT>
vnoremap <F3> %s//g<LEFT><LEFT>

"visual mode;Mac only?
nnoremap <C-@>v <S-V>
inoremap <C-@>v <C-O><S-V>

"move from{ to} #recursion call "}はタグジャンプ
imap <silent> <F4> <C-O>%
map <silent> <F4> %

"Escape  もっと重要なのにする
"inoremap <C-SPACE> <ESC>

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

"Save	need #stty -ixon -ixoff
noremap  <silent> <C-S> :update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

"move
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

nnoremap <C-j> <Down>
nnoremap <C-k> <UP>
