augroup dirvish_plugin
  au!

  au BufEnter dirvish dirvish#sort()
augroup END

function! dirvish#get_current_path()
  let l:path = expand('%:~:h')

  if len(l:path) == 0
    let l:path = getcwd()
  endif

  return l:path . '/'
endfunction

function! dirvish#sort()
  if &filetype == 'dirvish'
    setlocal modifiable
    sort r /[^\/]$/
    " setlocal nomodifiable
  endif
endfunction

command! DirvishCurrentPath call dirvish#open(dirvish#get_current_path()) | call dirvish#sort()
command! DirvishSort        call dirvish#sort()

nnoremap <silent> <c-f> :<c-u>DirvishCurrentPath<cr>
