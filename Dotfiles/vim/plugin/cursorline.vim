augroup active_cursorline
  au!
  au FocusGained,VimEnter,WinEnter,BufWinEnter * setlocal cursorline

  " au FocusLost,WinLeave * silent! setlocal nocursorline " this one is nicer, but triggers activity bell in tmux statusbar
  au WinLeave * setlocal nocursorline
augroup END
