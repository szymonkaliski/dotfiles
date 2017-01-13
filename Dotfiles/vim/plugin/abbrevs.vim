iabbrev <silent> idate  <c-r>=strftime('%Y-%m-%d')<cr>
iabbrev <silent> itime  <c-r>=strftime('%H:%M')<cr>
iabbrev <silent> ifdate <c-r>=strftime('%Y-%m-%d %H:%M')<cr>

" based on filetype
augroup ft_abbrev
  au!

  au FileType javascript,html call abbrevs#spaceless_iabbrev('clog', 'console.log')
augroup END
