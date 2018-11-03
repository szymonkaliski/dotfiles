let g:dirvish_mode = ':sort ,^.*[\/],'

function! dirvish#get_current_path()
  let l:path = expand('%:~:h')

  if len(l:path) == 0
    let l:path = getcwd()
  endif

  return l:path . '/'
endfunction

command! DirvishCurrentPath call dirvish#open(dirvish#get_current_path())
nnoremap <silent> <c-f> :<c-u>DirvishCurrentPath<cr>

silent! nunmap -
