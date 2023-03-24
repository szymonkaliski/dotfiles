let g:muninn_path = expand('~/Documents/Dropbox/Wiki/')

function! s:open_today()
  call muninn#journal_today()
  call muninn#tasks_today()
endfunction

" commands
command! Today         call <sid>open_today()

command! WikiBacklinks call muninn#backlinks()
command! WikiInbox     call muninn#open('inbox.md')
command! WikiJournal   call muninn#journal_today()
command! WikiTasks     call muninn#tasks_today()
command! WikiSearch    FZFWiki

command! -nargs=? -complete=custom,muninn#complete_open Wiki call muninn#open(<f-args>)

" maps
nnoremap <leader>wt :WikiTasks<cr>
nnoremap <leader>wj :WikiJournal<cr>
nnoremap <leader>wi :WikiInbox<cr>
nnoremap <leader>ws :WikiSearch<cr>
nnoremap <leader>wb :WikiBacklinks<cr>

" get asset
function! s:muninn_get_asset(url)
  echo "Adding asset: " . a:url

  let l:cmd    = 'muninn-get-asset --file "' . expand('%:p') . '" --url "' . a:url . '"'
  let l:output = system(l:cmd)

  call append(line('.'), split(l:output, '\n'))

  echo "Done!"
endfunction

nnoremap <leader>wg :WikiGetAsset
command! -nargs=1 -complete=file WikiGetAsset call <sid>muninn_get_asset(<f-args>)
