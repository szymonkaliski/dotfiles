if !isdirectory(muninn#wiki_path())
  finish
endif

function! s:open_today()
  call muninn#find_today()
  call muninn#journal_today()
endfunction

" commands
command! Tasks       call muninn#find_today()
command! Today       call <sid>open_today()

command! WikiSearch  FZFWiki
command! WikiJournal call muninn#journal_today()
command! WikiInbox   call muninn#open('inbox')
command! WikiRelated call muninn#show_related()

command! -nargs=? -complete=custom,muninn#complete_open Wiki call muninn#open(<f-args>)

" maps
nnoremap <leader>wt :Tasks<cr>
nnoremap <leader>wj :WikiJournal<cr>
nnoremap <leader>wi :WikiInbox<cr>
nnoremap <leader>ws :WikiSearch<cr>
nnoremap <leader>wr :WikiRelated<cr>

