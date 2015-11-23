" proper indentation on i/a/A
function! s:SmartInsert(c)
  return len(getline('.')) == 0 ? 'cc' : a:c
endfunction

nnoremap <expr> i <sid>SmartInsert('i')
nnoremap <expr> a <sid>SmartInsert('a')
nnoremap <expr> A <sid>SmartInsert('A')
