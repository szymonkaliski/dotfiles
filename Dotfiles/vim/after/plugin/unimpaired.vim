function! s:go_previous(prev, last)
  try
    exe a:prev
  catch
    try | exe a:last | catch | endtry
  endtry
endfunction

function! s:go_next(next, first)
  try
    exe a:next
  catch
    try | exe a:first | catch | endtry
  endtry
endfunction

" lists
nnoremap ]l :call <sid>go_previous('lnext', 'lfirst')<cr>zz
nnoremap [l :call <sid>go_next('lprev', 'llast')<cr>zz
nnoremap ]c :call <sid>go_previous('cnext', 'cfirst')<cr>zz
nnoremap [c :call <sid>go_next('cprev', 'clast')<cr>zz

" tabs, not tags
nnoremap ]t :tabn<cr>
nnoremap [t :tabp<cr>

" not used
unmap ]T
unmap [T

" center on cursor using scrollof
nnoremap <silent> coz :let &scrolloff=999-&scrolloff<cr>
