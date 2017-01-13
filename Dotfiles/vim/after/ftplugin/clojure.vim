if has('nvim')
  " no delimitmate when I have parinfer
  let b:loaded_delimitMate = 1
end

nnoremap <buffer> <leader>= :let align_view=winsaveview()<cr>=ip<cr>:call winrestview(align_view)<cr>

