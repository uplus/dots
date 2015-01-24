"-------------------------------"
"        Select microsoft       "
"Select methods just like ms-win"
"-------------------------------"

" bail out if this isn't wanted (msvim.vim uses this).
if exists("g:skip_loading_mswin") && g:skip_loading_mswin
  finish
endif

set cpo&vim

"Require Set select ways
" set 'selection', 'selectmode', 'mousemodel' and 'keymodel' for MS-Windows
behave mswin

" Pasting blockwise and linewise selections is not possible in Insert and
" VisuaL mode without the virtualedit feature.
" They are pasted as if they were characterwise instead.
" Uses the paste.vim autoload script.
exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']

" set 'selection', 'selectmode', 'mousemodel' and 'keymodel' for MS-Windows

