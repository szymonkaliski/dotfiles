if !(has('mac') && has('nvim'))
  finish
endif

augroup neomake_plugin
  au!

  au BufRead,BufWritePost *.js,*.jsx,*.json               Neomake | redraw
  au BufRead,BufWritePost *.clj,*.cljs                    Neomake | redraw
  au BufRead,BufWritePost *.sh,~/Documents/Code/Scripts/* Neomake | redraw
augroup END

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

" favour local eslint instead of global
if executable(getcwd() . '/node_modules/.bin/eslint')
  let g:neomake_javascript_enabled_makers = [ 'eslint' ]

  let g:neomake_javascript_eslint_exe = getcwd() . '/node_modules/.bin/eslint'
endif

if executable(getcwd() . '/node_modules/.bin/semistandard')
  let g:neomake_javascript_enabled_makers = [ 'semistandard' ]

  let g:neomake_javascript_semistandard_maker = {
        \ 'exe':         getcwd() . '/node_modules/.bin/semistandard',
        \ 'errorformat': '  %f:%l:%c: %m'
        \ }
endif

let g:neomake_clojure_enabled_makers = [ 'kibit' ]

let g:neomake_clojure_kibit_maker = {
    \ 'exe':           'lein',
    \ 'args':          [ 'kibit' ],
    \ 'errorformat':   '%IAt %f:%l:,%C%m,%-G%.%#',
    \ 'buffer_output': 1
    \ }

let g:neomake_place_signs = 1
" let g:neomake_airline = 1
" let g:neomake_open_list = 1

let g:neomake_error_sign = {
      \ 'text':   '✕',
      \ 'texthl': 'ErrorMsg'
      \ }

let g:neomake_warning_sign = {
      \ 'text':   '✕',
      \ 'texthl': 'ErrorMsg'
      \ }

let g:neomake_informational_sign = {
      \ 'text':   '⚬',
      \ 'texthl': 'WarningMsg'
      \ }
