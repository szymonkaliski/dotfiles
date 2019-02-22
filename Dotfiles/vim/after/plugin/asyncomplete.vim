augroup asyncomplete_plug
  au!

  au User asyncomplete_setup call <sid>asyncomplete_load()
augroup END

function! s:check_back_space() abort
  let col = col('.') - 1

  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

function! s:asyncomplete_load()
  let g:asyncomplete_auto_popup = 0
  let g:asyncomplete_remove_duplicates = 1

  inoremap <silent> <expr> <Tab>
	\ pumvisible() ? "\<C-n>" :
	\ <sid>check_back_space() ? "\<Tab>" : asyncomplete#force_refresh()

  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"

  call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
	\ 'name': 'buffer',
	\ 'whitelist': ['*'],
	\ 'priority': 1,
	\ 'completor': function('asyncomplete#sources#buffer#completor'),
	\ }))

  call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
	\ 'name': 'file',
	\ 'whitelist': ['*'],
	\ 'priority': 2,
	\ 'completor': function('asyncomplete#sources#file#completor')
	\ }))

  call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
	\ 'name': 'omni',
	\ 'whitelist': ['*'],
	\ 'priority': 3,
	\ 'completor': function('asyncomplete#sources#omni#completor')
	\  }))
endfunction

