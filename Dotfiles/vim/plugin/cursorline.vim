augroup active_cursorline
  au!
  au FocusGained,VimEnter,WinEnter,BufWinEnter * setlocal cursorline

  " this triggers window_activity_flag in tmux statusbar (understandably) when switching to new pane with vim active
  au FocusLost,WinLeave * silent! setlocal nocursorline

  " this does not, but leaves the cursorline in inactive windows/panes
  " au WinLeave * setlocal nocursorline
augroup END
