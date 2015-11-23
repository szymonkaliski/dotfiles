" return to same line after reopenning file
augroup line_return
  au!

  au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") && !&diff |
        \   exe 'normal! g`"zvzz' |
        \ endif
augroup END
