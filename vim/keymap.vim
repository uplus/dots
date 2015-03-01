"C-O is god!
set cpo&vim

"ESCが重いのはカーソルキーのせいかもしれない それとDelete
"commandモードでのマップは文字入力に影響がある
"Ctrl-M は<CR>
"Ctrl-[ は<ESC>
"Ctrl-i は<TAB>
"insert-mode でのESCのマッピングは良くない
"Normal modeは <Space>
":Errors :nohのマップ
" inoremap <C-Space>を　状況によって <C-Y>に割り当てる
"nnoremap <Space>h.. をundo履歴とかyank履歴とかにわりあてる



"line selectの方が使うこと多いし、visualは短形で同じ事ができる
nnoremap v V
nnoremap V v

" ex mode はいらない
nnoremap Q <Nop>
command WriteSudo w !sudo tee % > /dev/null
vnoremap <BS> d

"ins)C-O rでredo
nnoremap r <C-R>
nnoremap <C-R> r
"complite
"inoremap <C-U> <C-Y>

"Spaceとつなげれば平気 
"@@@###buffer###@@@
"nnoremap bb :b#<CR>
"nnoremap bp :bp<CR>
"nnoremap bn :bn<CR>
"nnoremap bd :bd<CR>

" これをマップすると:bのときの動作が重く感じる(感じるだけ)
"cnoremap bb b#


"@@@###apply speed up###@@@
"いらないかも
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

"######<Space> family######
" 現在の位置に空行を挿入
nnoremap <silent> <Space><CR> <S-O><ESC>
nnoremap <silent> <Space>n :noh<CR>

"gシリーズはいらないかも cもgも自分でつければ平気
nnoremap <Space>ss :OverCommandLine<CR>%s/
nnoremap <Space>sg :OverCommandLine<CR>%s//g<LEFT><LEFT>
nnoremap <Space>ws :OverCommandLine<CR>%s/<C-r><C-w>/
nnoremap <Space>wg :OverCommandLine<CR>%s/<C-r><C-w>//g<LEFT><LEFT>

vnoremap <Space>ss :OverCommandLine<CR>s/\%V
vnoremap <Space>sg :OverCommandLine<CR>s/\%V/g<LEFT><LEFT>
vnoremap <Space>ws :OverCommandLine<CR>s/\%V<C-r><C-w>/
vnoremap <Space>wg :OverCommandLine<CR>s/\%V<C-r><C-w>//g<LEFT><LEFT>

nnoremap <Space>j <C-D>
nnoremap <Space>k <C-U>
nnoremap <Space>h 0
nnoremap <Space>l $

vnoremap <Space>j <C-D>
vnoremap <Space>k <C-U>
vnoremap <Space>h 0
vnoremap <Space>l $

nnoremap <silent> <Space> <Nop>
vnoremap <silent> <Space> <Nop>


"######Ctrl+W family######
"NERDTree
nnoremap <silent> <C-W>e :NERDTree<CR>
inoremap <silent> <C-W>e <ESC>:NERDTree<CR>

"Window control
nnoremap <C-W>q :bdelete<CR>
inoremap <C-W>q <C-O>:bdelete<CR>

"Tab control
nnoremap <C-W>p gt
nnoremap <C-W>n gT
inoremap <C-W>p <C-O>gt
inoremap <C-W>n <C-O>gT

"file open
nnoremap <C-W>gs :vertical wincmd f<CR>
nnoremap gs :vertical wincmd f<CR>

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
nnoremap <C-S>aq	:qa<CR>
inoremap <C-S>q	<ESC>:q<CR>
inoremap <C-S>aq	<ESC>:qa<CR>

" buffer delete
nnoremap <C-S>d	:bd<CR>
inoremap <C-S>d	<ESC>:bd<CR>

" exit
nnoremap <C-S>e :q!<CR>
nnoremap <C-S>ae :qa!<CR>
inoremap <C-S>e <ESC>:q!<CR>
inoremap <C-S>ae <ESC>:qa!<CR>


" save and quit
nnoremap <C-S>z :wq<CR>
nnoremap <C-S>az :wqa<CR>
inoremap <C-S>z <ESC>:wq<CR>
inoremap <C-S>az <ESC>:wqa<CR>


" Save need #stty -ixon -ixoff
noremap  <silent> <C-S>s :update<CR>
inoremap <silent> <C-S>s <C-O>:update<CR>

" Save single C-S version
noremap  <silent> <C-S> :update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

"######Move######
nnoremap <UP> gk
nnoremap <DOWN> gj
nnoremap <C-j> gj
nnoremap <C-k> gk
nnoremap <C-h> h
nnoremap <C-l> l
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

inoremap <UP> <C-O>gk
inoremap <DOWN> <C-O>gj
inoremap <C-j> <C-O>gj
inoremap <C-k> <C-O>gk
inoremap <C-h> <C-O>h
inoremap <C-l> <C-O>l
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
vnoremap k gk
vnoremap j gj
vnoremap gk k
vnoremap gj j

"######Trash######
"すでに前の行の先頭　にマップされている
" 0 == ^ - == $
"nnoremap - $

"なんかいろいろすごいけど・・・
"cnoreabb <silent><expr>s getcmdtype()==':' && getcmdline()=~'^s' ? 'OverCommandLine<CR><C-u>%s/<C-r>=get([], getchar(0), '')<CR>' : 's'
