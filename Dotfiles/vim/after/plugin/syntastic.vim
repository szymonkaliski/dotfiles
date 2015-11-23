if !(has('mac') && !has('nvim'))
  finish
endif

augroup syntastic_plugin
  au!

  au FileType javascript
        \ if filereadable(getcwd() . '/.jscsrc') |
        \   let g:syntastic_javascript_checkers = g:syntastic_javascript_checkers + ['jscs'] |
        \ endif |
        \ if executable(getcwd() . '/node_modules/.bin/eslint') |
        \   let g:syntastic_javascript_eslint_exe = getcwd() . '/node_modules/.bin/eslint'
        \ endif
augroup END

let g:syntastic_aggregating_errors = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_cursor_column = 0
let g:syntastic_enable_highlighting = 1
let g:syntastic_enable_signs = 0
let g:syntastic_error_symbol = '!'
let g:syntastic_stl_format = '%E{Error: %e}%B{ }%W{Warning: %w}'
let g:syntastic_style_error_symbol = '!'
let g:syntastic_style_warning_symbol = '?'
let g:syntastic_warning_symbol = '?'

let g:syntastic_objc_check_header = 1
let g:syntastic_javascript_checkers = [ 'eslint' ]
