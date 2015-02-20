"Make the make file
command! Makemf  call system("makemf " . expand("%:r"))
command! Makemf2 call system("makemf2 " . expand("%"))

command! MakefileCP call system("cp .Makefile_" . expand("%:r") . " makefile")

command! Make  !make --no-print-directory
command! SaveMake write|Make

autocmd FileType c,cpp,ruby Makemf2

autocmd FileType c,cpp,ruby inoremap <F5> <C-O>:SaveMake<CR>
autocmd FileType c,cpp,ruby  noremap <F5> :SaveMake<CR>

autocmd FileType c,cpp,ruby autocmd VimEnter * MakefileCP
autocmd FileType c,cpp,ruby autocmd VimLeavePre * call system("rm makefile")

command! BuildC write|!clang % -o `basename % .c` $CLANG_WALL_OPT -std=c11 -lm
command! BuildCpp write|!clang++ % -o `basename % .cpp` $CLANG_WALL_OPT -std=c++1z

"command! RunCCPP `basename % .c` function
command! RunRuby write|!ruby %
