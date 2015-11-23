map <buffer> <silent> u -
map <buffer> <silent> e <cr>
map <buffer> <silent> <c-f> q

" why G gets bound to <leader>G in dirvish is a mystery, this 'fixes' it (somtimes?)
nnoremap <buffer> <silent> G :call cursor(line("w$"), 0)<cr>
