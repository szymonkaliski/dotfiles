setlocal foldmethod=syntax
setlocal suffixesadd=.js,.jsx
setlocal makeprg=node\ %

function! s:log(name)
  call append(".", "console.log(\"" . a:name . ":\", " . a:name . ");")
endfunction

nnoremap <buffer> <leader>l :call <sid>log(expand("<cword>"))<cr>
