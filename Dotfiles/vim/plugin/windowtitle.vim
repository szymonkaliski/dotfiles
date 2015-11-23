let s:app_name = has('nvim') ? 'nvim' : 'vim'

function! WindowTitleFilePath()
  let l:splited = split(expand('%:p'), '/')
  let l:cut = 3

  if len(l:splited) < l:cut
    let cut = len(l:splited)
  endif

  let l:cut = -l:cut

  if len(l:splited) == 0
    return '[No Name]'
  else
    return join(l:splited[l:cut : -1], '/')
  endif
endfunction

function! WindowTitle()
  return s:app_name . ': ' . WindowTitleFilePath()
endfunction

" set title on start as simple 'vim'
set title
exe 'set titlestring=' . s:app_name

" update titlestring with proper title
augroup title_titlestring
  au!

  au BufEnter * let &titlestring=WindowTitle()
augroup END

" only needed in screen
if &term == 'screen-256color'
  " screen caption is set by iconstring
  set t_IS=k
  set t_IE=\
  set icon

  augroup title_iconstring
    au!

    au BufEnter * let &iconstring=WindowTitle()
  augroup END

  " screen window title is set by titlestring
  set t_ts=]2;
  set t_fs=\
endif
