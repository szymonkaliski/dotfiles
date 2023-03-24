let s:p = g:lightline#colorscheme#base16#palette

let s:p.inactive.left   = [[ '#' . g:base16_gui04, '#' . g:base16_gui01, g:base16_cterm04, g:base16_cterm01 ]]
let s:p.inactive.middle = copy(s:p.inactive.left)
let s:p.inactive.right  = copy(s:p.inactive.left)

let s:p.normal.left     = [
      \   [ '#' . g:base16_gui00, '#' . g:base16_gui03, g:base16_cterm00, g:base16_cterm03 ],
      \   [ '#' . g:base16_gui05, '#' . g:base16_gui02, g:base16_cterm05, g:base16_cterm02 ]
      \ ]

let s:p.normal.middle   = copy(s:p.inactive.left)

let s:p.normal.right    = [
      \   [ '#' . g:base16_gui00, '#' . g:base16_gui03, g:base16_cterm00, g:base16_cterm03 ],
      \   [ '#' . g:base16_gui03, '#' . g:base16_gui02, g:base16_cterm03, g:base16_cterm02 ]
      \ ]

let s:p.normal.error    = [[ '#' . g:base16_gui01, '#' . g:base16_gui08, g:base16_cterm01, g:base16_cterm08 ]]
let s:p.normal.warning  = [[ '#' . g:base16_gui01, '#' . g:base16_gui08, g:base16_cterm01, g:base16_cterm08 ]]

let s:p.insert.left     = [
      \   [ '#' . g:base16_gui00, '#' . g:base16_gui0D, g:base16_cterm00, g:base16_cterm0D ],
      \   [ '#' . g:base16_gui05, '#' . g:base16_gui02, g:base16_cterm05, g:base16_cterm02 ]
      \ ]
let s:p.insert.middle   = copy(s:p.normal.middle)
let s:p.insert.right    = copy(s:p.insert.left)

let s:p.visual.left     = [
      \   [ '#' . g:base16_gui00, '#' . g:base16_gui09, g:base16_cterm00, g:base16_cterm09 ],
      \   [ '#' . g:base16_gui05, '#' . g:base16_gui02, g:base16_cterm05, g:base16_cterm02 ]
      \ ]
let s:p.visual.middle   = copy(s:p.normal.middle)
let s:p.visual.right    = copy(s:p.visual.left)

let s:p.tabline.left    = [[ '#' . g:base16_gui05, '#' . g:base16_gui02, g:base16_cterm05, g:base16_cterm02 ]]
let s:p.tabline.middle  = copy(s:p.inactive.left)
let s:p.tabline.right   = copy(s:p.inactive.left)
let s:p.tabline.tabsel  = [[ '#' . g:base16_gui00, '#' . g:base16_gui03, g:base16_cterm00, g:base16_cterm03 ]]

" config
let g:lightline = {}
let g:lightline.colorscheme = 'base16'

let g:lightline.active = {
      \ 'left':  [ [ 'custom_mode' ], [ 'utils_buffer_name' ] ],
      \ 'right': [ [ 'utils_statusline_right', 'error_status' ], [], [] ]
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

let g:lightline.tab_component_function = {
      \ 'filename': 'LightlineTabFilename'
      \ }

" for ALE use: 'utils#statusline_ale'
let g:lightline.component_expand = {
      \ 'error_status': 'utils#statusline_coc'
      \ }

let g:lightline.component_type = {
      \ 'error_status': 'error'
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

" better tabs
function! LightlineTabFilename(n)
  let buflist = tabpagebuflist(a:n)
  let winnr   = tabpagewinnr(a:n)
  let bufnum  = buflist[winnr - 1]

  return utils#format_buffer_nr(bufnum)
endfunction
