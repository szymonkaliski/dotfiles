" proper indentation on i/I/a/A
function! s:smart_insert(c)
  return len(getline('.')) == 0 ? 'cc' : a:c
endfunction

nnoremap <expr> i <sid>smart_insert('i')
nnoremap <expr> a <sid>smart_insert('a')
nnoremap <expr> A <sid>smart_insert('A')
