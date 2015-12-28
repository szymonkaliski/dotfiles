if !(has('mac') && has('nvim'))
  finish
endif

let g:parinfer_mode = 'indent' 
let g:parinfer_airline_integration = 0

augroup parinfer_plugin
  au!

  au FileType clojure
        \ silent! call plug#load('node-host', 'nvim-parinfer.js') |
        \ autocmd! parinfer_plugin
augroup END

