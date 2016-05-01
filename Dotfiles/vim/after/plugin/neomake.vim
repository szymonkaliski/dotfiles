if !(has('mac') && has('nvim'))
  finish
endif

augroup neomake_plugin
  au!

  au BufRead,BufWritePost *.js,*.jsx,*.json               Neomake | redraw
  au BufRead,BufWritePost *.c,*.h,*.cpp,*.hpp             Neomake | redraw
  au BufRead,BufWritePost *.py                            Neomake | redraw
  au BufRead,BufWritePost *.clj,*.cljs                    Neomake | redraw
  au BufRead,BufWritePost *.sh,~/Documents/Code/Scripts/* Neomake | redraw
augroup END

" nice airline integration

function! AirlineNeomakeStatus()
  let total = 0

  for v in values(neomake#statusline#LoclistCounts())
    let total += v
  endfor

  for v in items(neomake#statusline#QflistCounts())
    let total += v
  endfor

  if total > 0
    return 'Errors: ' . total
  else
    return ''
  end
endfunction

" favour local installed versions of js checkers

if executable(getcwd() . '/node_modules/.bin/eslint')
  let g:neomake_javascript_enabled_makers = [ 'eslint' ]
  let g:neomake_javascript_eslint_exe = getcwd() . '/node_modules/.bin/eslint'
endif

if executable(getcwd() . '/node_modules/.bin/standard')
  let g:neomake_javascript_enabled_makers = [ 'standard' ]
  let g:neomake_javascript_semistandard_exe = getcwd() . '/node_modules/.bin/standard'
endif

if executable(getcwd() . '/node_modules/.bin/semistandard')
  let g:neomake_javascript_enabled_makers = [ 'semistandard' ]
  let g:neomake_javascript_semistandard_exe = getcwd() . '/node_modules/.bin/semistandard'
endif

" kibit maker

function! SetWarningType(entry)
  let a:entry.type = 'W'
endfunction

let g:neomake_clojure_enabled_makers = [ 'kibit' ]

let g:neomake_clojure_kibit_maker = {
    \ 'exe':           'lein',
    \ 'args':          [ 'kibit' ],
    \ 'errorformat':   '%IAt %f:%l:,%C%m,%-G%.%#',
    \ 'buffer_output': 1,
    \ 'postprocess':   function('SetWarningType')
    \ }

" settings

let g:neomake_place_signs = 0

