augroup dirvish_plugin
  au!

  au BufEnter dirvish <sid>DirvishSort()
augroup END

function! s:DirvishCurrentPath()
  let l:path = expand('%:~:h')

  if len(l:path) == 0
    let l:path = getcwd()
  endif

  return l:path . '/'
endfunction

function! s:DirvishSort()
  if &filetype == 'dirvish'
    setlocal modifiable
    sort r /[^\/]$/
    " setlocal nomodifiable
  endif
endfunction

command! DirvishCurrentPath call dirvish#open(<sid>DirvishCurrentPath()) | call <sid>DirvishSort()
command! DirvishSort        call <sid>DirvishSort()

nnoremap <silent> <c-f> :<c-u>DirvishCurrentPath<cr>
