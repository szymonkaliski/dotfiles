" automatically resize splits when resizing window
augroup split_resize
  au!

  au VimResized * wincmd =
augroup END
