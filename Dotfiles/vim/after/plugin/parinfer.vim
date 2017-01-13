if !(has('mac') && has('nvim'))
  finish
endif

let g:parinfer_mode_default = 'indent'
let g:parinfer_mode = g:parinfer_mode_default
let g:parinfer_airline_integration = 0
let g:parinfer_preview_cursor_scope = 1

function! parinfer#toggle()
  if g:parinfer_mode == g:parinfer_mode_default
    let g:parinfer_mode = 'off'
  else
    let g:parinfer_mode = g:parinfer_mode_default
  end

  echo 'Parinfer mode: ' . g:parinfer_mode
endfunction

command! ToggleParinfer call parinfer#toggle()

nnoremap <buffer> [op :let g:parinfer_mode = 'off'<cr>
nnoremap <buffer> ]op :let g:parinfer_mode = g:parinfer_mode_default<cr>
nnoremap <buffer> cop :ToggleParinfer<cr>

" not sure if this is the best way to do it, but I know to little vim to find
" other way - basically add those mappings after nvim-parinfer.js is loaded
" manually by vim-plug
function parinfer#map()
  au FileType clojure :vmap <buffer> > <Plug>ParinferShiftVisRightgv
  au FileType clojure :vmap <buffer> < <Plug>ParinferShiftVisLeftgv
endfunction

augroup parinfer_plugin
  au!

  au FileType clojure
        \ silent! call plug#load('node-host', 'nvim-parinfer.js') |
        \ call parinfer#map() |
        \ autocmd! parinfer_plugin
augroup END


