if !has('mac')
  finish
end

augroup tern_plugin
  au!

  au FileType javascript
        \ silent! call plug#load('tern_for_vim') |
        \ autocmd! tern_plugin
augroup END

let g:tern_show_signature_in_pum=1
