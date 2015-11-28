augroup airline_plugin
  au!

  au User AirlineAfterInit call <sid>AirlineInit()
augroup END

" theme
let g:airline_theme = 'tomorrow'

" patch function
let g:airline_theme_patch_func = 'AirlineThemePatch'

" default extensions
let g:airline_extensions = ['quickfix', 'tabline']

if has('mac')
  let g:airline_extensions = g:airline_extensions + ['hunks']
  let g:airline#extensions#hunks#non_zero_only = 1
endif

" initial sections
let g:airline_section_b = '%{WindowTitleFilePath()}'
let g:airline_section_c = ''
let g:airline_section_x = ''
let g:airline_section_y = ''

" settings
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_inactive_collapse = 0
let g:airline_exclude_preview = 0
let g:airline_detect_modified = 0
let g:airline_detect_paste = 0

" tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#tab_min_count = 2
let g:airline#extensions#tabline#buffer_min_count = 2
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline#extensions#tabline#close_symbol = '✕'

" truncating
let g:airline#extensions#default#section_truncate_width = {
      \ 'b': 20,
      \ 'x': 60,
      \ 'y': 90,
      \ 'z': 50
      \ }

" extensions
function! s:AirlineInit()
  if has('mac')
    let g:airline_section_y = airline#section#create(['hunks'])

    if has('nvim')
      let g:airline_section_warning = '%{AirlineNeomakeStatus()}'
    else
      let g:airline_extensions = g:airline_extensions + ['syntastic']
      let g:airline_section_warning = '%{airline#extensions#syntastic#get_warnings()}'
    endif
  endif
endfunction

" theme patching
function! AirlineThemePatch(palette)
  if g:airline_theme == 'tomorrow' || g:airline_theme == 'solarized' || g:airline_theme == 'jellybeans'
    let l:palettes = [a:palette.normal, a:palette.insert, a:palette.replace, a:palette.visual, a:palette.accents]

    for l:palette in l:palettes
      for l:colors in values(l:palette)
        if len(l:colors) >= 5
          let l:colors[4] = 'none'
        endif
      endfor
    endfor

    if g:airline_theme == 'tomorrow' && !has('gui')
      for l:colors in values(a:palette.inactive)
        let l:colors[2] = '245'
        let l:colors[3] = '0'
      endfor
    endif

    if g:airline_theme == 'tomorrow' && !has('gui') && g:colors_name == 'hybrid'
      for l:colors in values(a:palette.inactive)
        let l:colors[2] = '243'
        let l:colors[3] = '235'
      endfor
    endif

    if g:airline_theme == 'solarized'
      for l:colors in values(a:palette.inactive)
        if &background == 'dark'
          let l:colors[0] = '#586e75'
          let l:colors[1] = '#073642'
        else
          let l:colors[0] = '#93a1a1'
          let l:colors[1] = '#eee8d5'
        endif
        let l:colors[2] = '10'
        let l:colors[3] = '0'
      endfor
    endif

    if g:airline_theme == 'jellybeans'
      for l:palette in l:palettes
        for l:colors in values(l:palette)
          if len(l:colors) >= 3 && l:colors[3] == '233'
            let l:colors[3] = '234'
          endif
        endfor
      endfor
    endif
  endif
endfunction
