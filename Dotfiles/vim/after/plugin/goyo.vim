function! GoyoBefore()
  if !has('gui')
    set showtabline=0
  endif

  if ($TMUX != '')
    silent !tmux set status off > /dev/null
    silent !tmux resize-pane -Z > /dev/null
  endif

  set scrolloff=999
  Limelight
endfunction

function! GoyoAfter()
  if !has('gui')
    set showtabline=2
  endif

  if ($TMUX != '')
    silent !tmux set status on > /dev/null
    silent !tmux resize-pane -Z > /dev/null
  endif

  set scrolloff=3
  Limelight!
endfunction

let g:goyo_callbacks = [ function('GoyoBefore'), function('GoyoAfter') ]
let g:goyo_width = 120

command! Zen :Goyo

nnoremap <silent> <leader>Z :Zen<cr>
