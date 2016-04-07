if !(has('mac') && has('nvim'))
  finish
endif

let g:parinfer_mode_default = 'indent'
let g:parinfer_mode = g:parinfer_mode_default
let g:parinfer_airline_integration = 0

function! s:ToggleParinfer()
  if g:parinfer_mode == g:parinfer_mode_default
    let g:parinfer_mode = 'off'
  else
    let g:parinfer_mode = g:parinfer_mode_default
  end

  echo 'Parinfer mode: ' . g:parinfer_mode
endfunction

command! ToggleParinfer call <sid>ToggleParinfer()

nnoremap <buffer> [op :let g:parinfer_mode = 'off'<cr>
nnoremap <buffer> ]op :let g:parinfer_mode = g:parinfer_mode_default<cr>
nnoremap <buffer> cop :ToggleParinfer<cr>

augroup parinfer_plugin
  au!

  au FileType clojure
        \ silent! call plug#load('node-host', 'nvim-parinfer.js') |
        \ autocmd! parinfer_plugin
augroup END

