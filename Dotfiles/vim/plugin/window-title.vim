" set title on start as simple 'vim'
set title
exe 'set titlestring=' . (has('nvim') ? 'nvim' : 'vim')

" update titlestring with proper title
augroup title_titlestring
  au!

  au BufEnter,BufWritePost,TextChanged,TextChangedI * let &titlestring=utils#window_name()
augroup END

" only needed in screen/tmux
if &term == 'screen-256color' || &term == 'screen-256color-italic' || &term == 'tmux-256color' || &term == 'tmux-256color-italic'
  " screen caption is set by iconstring
  set t_IS=k
  set t_IE=\
  set icon

  augroup title_iconstring
    au!

    au BufEnter,BufWritePost,TextChanged,TextChangedI * let &iconstring=utils#window_name()
  augroup END

  " screen window title is set by titlestring
  set t_ts=]2;
  set t_fs=\
endif
