" set title on start as simple 'vim'
set title
exe 'set titlestring=' . (has('nvim') ? 'nvim' : 'vim')

" update titlestring with proper title
augroup title_titlestring
  au!

  au BufEnter * let &titlestring=utils#window_name()
augroup END

" only needed in screen
if &term == 'screen-256color'
  " screen caption is set by iconstring
  set t_IS=k
  set t_IE=\
  set icon

  augroup title_iconstring
    au!

    au BufEnter * let &iconstring=utils#window_name()
  augroup END

  " screen window title is set by titlestring
  set t_ts=]2;
  set t_fs=\
endif
