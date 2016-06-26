augroup checktime_update
  au!

  au FocusGained,BufEnter,CursorHold * if expand('%') !=# '[Command Line]' | checktime | endif
augroup END
