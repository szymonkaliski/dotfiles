function! goyo#before()
  if !has('gui')
    set showtabline=0
  endif

  if ($TMUX != '')
    silent !tmux set status off > /dev/null
    silent !tmux resize-pane -Z > /dev/null
  endif

  " set scrolloff=999
endfunction

function! goyo#after()
  if !has('gui')
    set showtabline=1
  endif

  if ($TMUX != '')
    silent !tmux set status on > /dev/null
    silent !tmux resize-pane -Z > /dev/null
  endif

  " set scrolloff=3
endfunction

let g:goyo_callbacks = [ function('goyo#before'), function('goyo#after') ]
let g:goyo_width = 80

command! Zen :Goyo

nnoremap <silent> <leader>Z :Zen<cr>
