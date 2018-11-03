augroup lsp_plug
  au!

  au User lsp_setup call <sid>lsp_load()
augroup END

function! s:lsp_load()
  let g:lsp_async_completion = 1

  if executable('javascript-typescript-stdio')
    call lsp#register_server({
	  \ 'name': 'javascript-typescript-stdio',
	  \ 'cmd': { server_info->[ 'javascript-typescript-stdio' ] },
	  \ 'whitelist': [ 'javascript', 'typescript', 'javascript.jsx', 'typescript.tsx' ],
	  \ })
  endif

  if executable('css-languageserver')
    call lsp#register_server({
	  \ 'name': 'css-languageserver',
	  \ 'cmd': { server_info->[ &shell, &shellcmdflag, 'css-languageserver --stdio' ] },
	  \ 'whitelist': [ 'css', 'less', 'sass' ],
	  \ })
  endif

  if executable('go-langserver')
    call lsp#register_server({
	  \ 'name': 'go-langserver',
	  \ 'cmd': { server_info->[ 'go-langserver', '-mode', 'stdio' ] },
	  \ 'whitelist': [ 'go' ],
	  \ })
  endif

  let s:langserver_swift = $HOME . '/Documents/Code/Utils/langserver-swift/.build/x86_64-apple-macosx10.10/release/langserver-swift'
  if executable(s:langserver_swift)
    call lsp#register_server({
	  \ 'name': 'langserver-swift',
	  \ 'cmd': { server_info->[ s:langserver_swift ] },
	  \ 'whitelist': [ 'swift' ],
	  \ })
  endif

  if executable('rls')
    call lsp#register_server({
	  \ 'name': 'rls',
	  \ 'cmd': { server_info->[ 'rustup', 'run', 'nightly', 'rls' ] },
	  \ 'whitelist': [ 'rust' ],
	  \ })
  endif

  if executable('clojure-lsp')
    call lsp#register_server({
	  \ 'name': 'clojure-lsp',
	  \ 'cmd': { server_info->[ 'clojure-lsp' ] },
	  \ 'whitelist': [ 'clojure' ],
	  \ })
  endif

  nnoremap <silent> gd  :LspDefinition<cr>
  nnoremap <silent> gh  :LspHover<cr>
  nnoremap <silent> glr :LspRename<cr>
endfunction
