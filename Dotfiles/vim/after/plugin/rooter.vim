let g:rooter_use_lcd = 1
let g:rooter_disable_map = 1
let g:rooter_silent_chdir = 1

" when not in project, use current file path (autochdir)
" let g:rooter_change_directory_for_non_project_files = 'current'

let g:rooter_patterns = [ '.git', '.git/', 'node_modules/', 'package.json', 'Wiki/' ]
