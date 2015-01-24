	"-------------------------------------------"
	"When insert mode, change status line's color
	"-------------------------------------------"
let g:hi_insert = 'highlight StatusLine guifg=blue guibg=darkyellow gui=none ctermfg=green ctermbg=blue  cterm=none'

if has('syntax')
	augroup InsertHook
		autocmd!
		autocmd InsertEnter * call s:StatusLine('Enter')
		autocmd InsertLeave * call s:StatusLine('Leave')
	augroup END
endif

let s:slhlcmd = ''
function! s:StatusLine(mode)
	if a:mode == 'Enter'
	      silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
	      silent exec g:hi_insert
	else
	    highlight clear StatusLine
	    silent exec s:slhlcmd
	endif
endfunction

function! s:GetHighlight(hi)
	redir => hl
	exec 'highlight '.a:hi
	redir END
	let hl = substitute(hl, '[\r\n]', '', 'g')
	let hl = substitute(hl, 'xxx', '', '')
	return hl
endfunction
