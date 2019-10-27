setlocal conceallevel=2

nnoremap <buffer> <leader>td :<c-u>call muninn#toggle_todo()<cr>
nnoremap <buffer> <leader>tm :<c-u>call muninn#toggle_tag('due', '<c-r>=strftime('%Y-%m-%d', localtime() + 86400)<cr>')<cr>
nnoremap <buffer> <leader>tt :<c-u>call muninn#toggle_tag('due', '<c-r>=strftime('%Y-%m-%d')<cr>')<cr>
nnoremap <buffer> <leader>tw :<c-u>call muninn#toggle_tag('waiting', '')<cr>
