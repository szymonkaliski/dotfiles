setlocal nolist

call taskpaper#fold_projects()

nnoremap <buffer> <leader>to zM:g/\v^(.*\@today)&(.*\@done)@!/foldopen!<cr>:nohlsearch<cr>gg
nnoremap <buffer> <leader>tw :<c-u>call taskpaper#toggle_tag('waiting', '')<cr>
nnoremap <buffer> <leader>tm :<c-u>call taskpaper#toggle_tag('due', '<c-r>=strftime('%Y-%m-%d', localtime() + 86400)<cr>')<cr>

nnoremap <buffer> <leader>cd vip:CountWorkedDays<cr>
xnoremap <buffer> <leader>cd :CountWorkedDays<cr>
