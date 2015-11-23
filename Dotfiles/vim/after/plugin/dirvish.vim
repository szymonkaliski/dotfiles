function! DirvishCurrentPath()
  let l:path = expand('%:~:h')

  if len(l:path) == 0
    let l:path = getcwd()
  endif

  return fnameescape(l:path)
endfunction

nnoremap <silent> <c-f> :e <c-r>=DirvishCurrentPath()<cr>/<cr>
