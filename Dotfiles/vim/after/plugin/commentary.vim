map  gc  <Plug>Commentary
nmap gcc <Plug>CommentaryLine

let g:context#commentstring#table = {}

let g:context#commentstring#table['javascript.jsx'] = {
      \ 'jsComment': '//%s',
      \ 'jsImport': '//%s',
      \ 'jsxStatment': '//%s',
      \ 'jsxRegion': '{/*%s*/}',
      \ 'jsxTag' :'{/*%s*/}',
      \}

let g:context#commentstring#table['typescript.tsx'] = {
      \ 'tsComment': '//%s',
      \ 'tsImport': '//%s',
      \ 'tsxStatment': '//%s',
      \ 'tsxRegion': '{/*%s*/}',
      \ 'tsxTag': '{/*%s*/}',
      \}

let g:context#commentstring#table['javascript'] = g:context#commentstring#table['javascript.jsx']
let g:context#commentstring#table['javascriptreact'] = g:context#commentstring#table['javascript.jsx']

let g:context#commentstring#table['typescript'] = g:context#commentstring#table['typescript.tsx']
let g:context#commentstring#table['typescriptreact'] = g:context#commentstring#table['typescript.tsx']

