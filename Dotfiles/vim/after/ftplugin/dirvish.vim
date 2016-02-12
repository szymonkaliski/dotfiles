nnoremap <buffer> <silent> u :Dirvish %:h:h<cr>:DirvishSort<cr>
nnoremap <buffer> <silent> e :<c-u>call dirvish#open('edit', 0)<cr>:DirvishSort<cr>
nnoremap <buffer> <silent> <c-f> q
nnoremap <buffer> <silent> <c-r> :Dirvish %<cr>:DirvishSort<cr>
