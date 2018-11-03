let s:p = g:lightline#colorscheme#base16#palette

let s:p.inactive.left   = [[ '#' . g:base16_gui04, '#' . g:base16_gui01, g:base16_cterm04, g:base16_cterm01 ]]
let s:p.inactive.middle = copy(s:p.inactive.left)
let s:p.inactive.right  = copy(s:p.inactive.left)

let s:p.tabline.left    = [[ '#' . g:base16_gui00, '#' . g:base16_gui02, g:base16_cterm05, g:base16_cterm02 ]]
let s:p.tabline.middle  = copy(s:p.inactive.left)
let s:p.tabline.right   = copy(s:p.inactive.left)
let s:p.tabline.tabsel  = [[ '#' . g:base16_gui00, '#' . g:base16_gui03, g:base16_cterm00, g:base16_cterm03 ]]

let s:p.normal.left     = [
      \   [ '#' . g:base16_gui00, '#' . g:base16_gui03, g:base16_cterm00, g:base16_cterm03 ],
      \   [ '#' . g:base16_gui00, '#' . g:base16_gui02, g:base16_cterm05, g:base16_cterm02 ]
      \ ]

let s:p.normal.right    = [
      \   [ '#' . g:base16_gui00, '#' . g:base16_gui03, g:base16_cterm00, g:base16_cterm03 ],
      \   [ '#' . g:base16_gui03, '#' . g:base16_gui02, g:base16_cterm03, g:base16_cterm02 ]
      \ ]

let s:p.normal.error    = [[ '#' . g:base16_gui01, '#' . g:base16_gui08, g:base16_cterm01, g:base16_cterm08 ]]
let s:p.normal.warning  = [[ '#' . g:base16_gui01, '#' . g:base16_gui08, g:base16_cterm01, g:base16_cterm08 ]]

let s:p.normal.right    = copy(s:p.normal.left)
let s:p.insert.right    = copy(s:p.insert.left)
let s:p.visual.right    = copy(s:p.visual.left)

" config
let g:lightline = {}
let g:lightline.colorscheme = 'base16'

let g:lightline.active = {
      \ 'left':  [ [ 'custom_mode' ], [ 'utils_buffer_name' ] ],
      \ 'right': [ [ 'utils_statusline_right', 'ale_status' ], [], [] ]
      \ }

let g:lightline.inactive = {
      \ 'left':  [ [ 'inactive_mode' ], [ 'utils_buffer_name' ] ],
      \ 'right': [ [ 'utils_statusline_right' ], [], [] ]
      \ }

let g:lightline.tabline = { 'left': [ [ 'tabs' ] ], 'right': [ [] ] }
let g:lightline.tab     = { 'active': [ 'filename' ], 'inactive': [ 'filename' ] }

let g:lightline.component_function = {
      \ 'custom_mode':            'LightlineCustomMode',
      \ 'inactive_mode':          'LightlineInactiveMode',
      \ 'utils_buffer_name':      'utils#buffer_name',
      \ 'utils_statusline_right': 'utils#statusline_right',
      \ }

let g:lightline.component_expand = {
      \ 'ale_status': 'utils#statusline_ale'
      \ }

let g:lightline.component_type = {
      \ 'ale_status': 'error'
      \ }

let g:lightline.mode_map = {
      \ 'n':      'N',
      \ 'i':      'I',
      \ 'R':      'R',
      \ 'v':      'V',
      \ 'V':      'V',
      \ "\<C-v>": 'V',
      \ 'c':      'C',
      \ 's':      'S',
      \ 'S':      'S',
      \ "\<C-s>": 'S',
      \ 't':      'T',
      \ }

" separators
let g:lightline.separator    = { 'left': '', 'right': '' }
let g:lightline.subseparator = { 'left': '', 'right': '' }

" hacky mode functions
function! LightlineCustomMode()
  return &filetype == 'qf' ? 'Q' : lightline#mode()
endfunction

function! LightlineInactiveMode()
  return '-'
endfunction
