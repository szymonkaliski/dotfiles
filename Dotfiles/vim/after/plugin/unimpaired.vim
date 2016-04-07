function! s:GoPrevious(prev, last)
  try
    exe a:prev
  catch
    try | exe a:last | catch | endtry
  endtry
endfunction

function! s:GoNext(next, first)
  try
    exe a:next
  catch
    try | exe a:first | catch | endtry
  endtry
endfunction

" lists
nnoremap ]l :call <sid>GoPrevious('lnext', 'lfirst')<cr>zz
nnoremap [l :call <sid>GoNext('lprev', 'llast')<cr>zz
nnoremap ]c :call <sid>GoPrevious('cnext', 'cfirst')<cr>zz
nnoremap [c :call <sid>GoNext('cprev', 'clast')<cr>zz

" tabs, not tags
nnoremap [t :tabn<cr>
nnoremap ]t :tabp<cr>

" not used
unmap [T
unmap ]T
