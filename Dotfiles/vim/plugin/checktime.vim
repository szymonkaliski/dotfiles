augroup checktime_update
  au!

  au FocusGained,BufEnter,CursorHold * if expand('%') !=# '[Command Line]' | silent! checktime | endif
augroup END
