nnoremap <buffer> <silent> u :<c-u>Dirvish %:h:h<cr>:<c-u>DirvishSort<cr>
nnoremap <buffer> <silent> e :<c-u>call dirvish#open('edit', 0)<cr>:<c-u>DirvishSort<cr>
nnoremap <buffer> <silent> <c-f> q
nnoremap <buffer> <silent> <c-r> :<c-u>DirvishSort<cr>
