function! s:go_wrap(next, first)
  try
    exe a:next
  catch
    try | exe a:first | catch | endtry
  endtry
endfunction

" lists
nnoremap ]l :call <sid>go_wrap('lnext', 'lfirst')<cr>zz
nnoremap [l :call <sid>go_wrap('lprev', 'llast')<cr>zz
nnoremap ]c :call <sid>go_wrap('cnext', 'cfirst')<cr>zz
nnoremap [c :call <sid>go_wrap('cprev', 'clast')<cr>zz

" tags, not tabs
nnoremap ]T :call <sid>go_wrap('tnext', 'tfirst')<cr>zz
nnoremap [T :call <sid>go_wrap('tprev', 'tlast')<cr>zz

" tabs, not tags
nnoremap ]t :tabn<cr>
nnoremap [t :tabp<cr>

" center on cursor using scrollof
nnoremap <silent> coz :let &scrolloff=999-&scrolloff<cr>
