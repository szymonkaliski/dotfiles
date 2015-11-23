if !(has('mac') && has('nvim'))
  finish
endif

augroup neomake_plugin
  au!

  au BufRead,BufWritePost *.js,*.jsx,*.json               Neomake
  au BufRead,BufWritePost *.clj,*.cljs                    Neomake
  au BufRead,BufWritePost *.sh,~/Documents/Code/Scripts/* Neomake
augroup END

function! AirlineNeomakeStatus()
  let l:counts = neomake#statusline#LoclistCounts()
  let l:w = get(l:counts, 'W', 0)
  let l:e = get(l:counts, 'E', 0)
  let l:x = get(l:counts, 'x', 0)

  if l:w || l:e || l:x
    let l:result = ''
    if l:e
      let l:result = l:result . 'Error: ' . e
      if l:w
        let l:result = l:result . ' '
      endif
    endif

    if l:w
      let l:result = l:result . 'Warning: ' . w
    endif

    if l:x
      let l:result = l.result . ' Unknown: ' . x
    endif

    return l:result
  else
    return ''
  endif
endfunction

" favour local eslint instead of global
if executable(getcwd() . '/node_modules/.bin/eslint')
  let g:neomake_javascript_eslint_exe = getcwd() . '/node_modules/.bin/eslint'
endif

let g:neomake_clojure_kibit_maker = {
    \ 'exe':           'lein',
    \ 'args':          [ 'kibit' ],
    \ 'errorformat':   '%IAt %f:%l:,%C%m,%-G%.%#',
    \ 'buffer_output': 1
    \ }
let g:neomake_clojure_enabled_makers = [ 'kibit' ]

let g:neomake_place_signs = 0
let g:neomake_airline = 1
