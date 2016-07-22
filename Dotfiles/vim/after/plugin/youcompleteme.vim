" augroup ycm_plugin
"   au!
"   au InsertEnter * call plug#load('YouCompleteMe') | call youcompleteme#Enable() | autocmd! ycm_plugin
" augroup END

let g:ycm_allow_changing_updatetime     = 0
let g:ycm_register_as_syntastic_checker = 0
let g:ycm_filetype_blacklist            = { 'taskpaper': 1, 'markdown': 1 }
let g:ycm_enable_diagnostic_signs       = 0
let g:ycm_global_ycm_extra_conf         = '~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'

