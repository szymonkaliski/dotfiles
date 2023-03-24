finish

augroup ale_load
  au!

  au User ale call <sid>ale_load()
augroup END

function! s:cwd()
  return fnameescape(getcwd())
endfunction

" this should be automatic in ALE, but well, doesn't work for me...
function! s:set_ale_prettier_options()
  let l:has_prettier = executable(s:cwd() . '/node_modules/.bin/prettier') || executable('prettier')
  let l:has_prettierrc = filereadable(s:cwd() . '/.prettierrc')

  if l:has_prettier && l:has_prettierrc
    let g:ale_javascript_prettier_options = '--config ' . s:cwd() . '/.prettierrc'
  endif
endfunction

function! s:set_ale_eslint_options()
  let l:has_eslint = executable(s:cwd() . '/node_modules/.bin/eslint')
  let l:has_eslintrc = filereadable(s:cwd() . '/.eslintrc')
  let l:has_eslintrcjs = filereadable(s:cwd() . '/.eslintrc.js')

  if l:has_eslint
    if l:has_eslintrc
      let g:ale_javascript_eslint_options = '--config ' . s:cwd() . '/.eslintrc'
    elseif l:has_eslintrcjs
      let g:ale_javascript_eslint_options = '--config ' . s:cwd() . '/.eslintrc.js'
    endif
  endif
endfunction

function! s:ale_update_lightline()
  " update lightline only if we have statusline visible
  if &laststatus > 0
    call lightline#update()
  endif
endfunction

function! s:ale_load()
  augroup ale_plugin
    au!

    au FileType javascript,typescript,typescriptreact                         call <sid>set_ale_eslint_options()
    au FileType html,css,scss,less,javascript,typescript,typescriptreact,json call <sid>set_ale_prettier_options()

    au User ALELintPost call <sid>ale_update_lightline()
    au User ALEFixPost  call <sid>ale_update_lightline()
  augroup END

  nmap <silent> [a <Plug>(ale_previous_wrap)
  nmap <silent> ]a <Plug>(ale_next_wrap)

  nnoremap <leader>p :ALEFix<cr>
  " nnoremap coa :ALEToggle<cr>:echom g:ale_enabled ? 'ALE: Enabled' : 'ALE: Disabled'<cr>
  nnoremap yoa :ALEToggle<cr>:echom g:ale_enabled ? 'ALE: Enabled' : 'ALE: Disabled'<cr>

  let g:ale_disable_lsp = 1 " https://github.com/dense-analysis/ale#5iii-how-can-i-use-ale-and-cocnvim-together
  let g:ale_completion_enabled = 0

  let g:ale_set_signs = 0
  let g:ale_max_signs = 0

  let g:ale_echo_msg_format = '%linter%: %s'

  let g:ale_linters.rust = [ 'rls', 'cargo' ]
  " let g:ale_linters.typescript = [ 'tslint', 'tsserver', 'typecheck' ]

  " use clippy if we have it
  if executable('cargo-clippy')
    let g:ale_rust_cargo_use_clippy = 1
    let g:ale_rust_rls_config = { 'rust': { 'clippy_preference': 'on' } }
  endif

  let g:ale_writegood_options = '--no-adverb --no-weasel --no-tooWordy --no-passive' " --yes-eprime
  let g:ale_languagetool_options = '--disable DASH_RULE,EN_QUOTES,WHITESPACE_RULE,TO_DO_HYPHEN,DOUBLE_PUNCTUATION,UPPERCASE_SENTENCE_START,ARROWS,PUNCTUATION_PARAGRAPH_END,UNIT_SPACE,DATE_NEW_YEAR'

  let g:ale_linter_aliases = {
        \ 'reason': 'ocaml',
        \ 'zsh':    'sh'
        \ }

  let g:ale_fixers = {
        \ '*':               [ 'remove_trailing_lines', 'trim_whitespace' ],
        \ 'arduino':         [ 'clang-format' ],
        \ 'cpp':             [ 'clang-format' ],
        \ 'css':             [ 'prettier' ],
        \ 'go':              [ 'goimports', 'gofmt' ],
        \ 'html':            [ { buffer, lines -> { 'command': 'prettier --html-whitespace-sensitivity ignore --parser html --print-width 120' } } ],
        \ 'json':            [ 'prettier' ],
        \ 'javascript':      [ 'prettier' ],
        \ 'less':            [ 'prettier' ],
        \ 'markdown':        [ 'prettier' ],
        \ 'processing':      [ { buffer, lines -> { 'command': 'astyle --style=java --mode=java -s2 -p -H -U -j -v -n -N' } } ],
        \ 'python':          [ 'add_blank_lines_for_python_control_statements', 'black' ],
        \ 'rust':            [ 'rustfmt' ],
        \ 'scss':            [ 'prettier' ],
        \ 'swift':           [ { buffer, lines -> { 'command': 'swiftformat --indent 2' } } ],
        \ 'typescript':      [ 'prettier' ],
        \ 'typescriptreact': [ 'prettier' ],
        \ 'xml':             [ 'xmllint' ],
        \ }
endfunction

