if !(has('mac') && has('nvim'))
  finish
endif

augroup parinfer_plugin
  au!

  au FileType clojure
        \ silent! call plug#load('node-host', 'nvim-parinfer.js') |
        \ autocmd! parinfer_plugin
augroup END

