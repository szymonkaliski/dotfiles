iabbrev <silent> idate  <c-r>=strftime('%Y-%m-%d')<cr>
iabbrev <silent> itime  <c-r>=strftime('%H:%M')<cr>
iabbrev <silent> ifdate <c-r>=strftime('%Y-%m-%d %H:%M')<cr>

function! s:EatChar(pat)
  let l:c = nr2char(getchar(0))
  return (l:c =~ a:pat) ? '' : l:c
endfunction

function! s:SpacelessIabbrev(from, to)
  exe 'iabbrev <silent> <buffer> ' . a:from . ' ' . a:to . '<c-r>=<sid>EatChar("\\s")<cr>'
endfunction

" based on filetype
augroup ft_abbrev
  au!

  au FileType javascript,html
        \ call <sid>SpacelessIabbrev('clog', 'console.log') |
        \ call <sid>SpacelessIabbrev('rfac', 'React.createFactory(') |
        \ call <sid>SpacelessIabbrev('rcla', 'React.createClass(')
augroup END
