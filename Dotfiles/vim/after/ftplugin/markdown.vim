setlocal conceallevel=2
setlocal spell

" setlocal isfname+=32 " files with spaces - markdown links can't have spaces anyways

setlocal foldexpr=MarkdownFoldexpr(v:lnum)
setlocal foldmethod=expr

" move two characters to the right when breaking indent, useful in lists, but breaks multline text
setlocal breakindent
setlocal breakindentopt=shift:2

let b:coc_additional_keywords = ["-"]

nnoremap <buffer> <leader>td :<c-u>call muninn#toggle_todo()<cr>
nnoremap <buffer> <leader>tm :<c-u>call muninn#toggle_tag('due', '<c-r>=strftime('%Y-%m-%d', localtime() + 86400)<cr>')<cr>
nnoremap <buffer> <leader>tt :<c-u>call muninn#toggle_tag('due', '<c-r>=strftime('%Y-%m-%d')<cr>')<cr>
nnoremap <buffer> <leader>tw :<c-u>call muninn#toggle_tag('waiting', '')<cr>
nnoremap <buffer> <leader>tr :<c-u>call muninn#toggle_tag('review', '')<cr>

function! MarkdownFoldexpr(lnum)
  let l0 = getline(a:lnum - 1)
  let l1 = getline(a:lnum)

  if l1 =~ '````*' || l1 =~ '\~\~\~\~*'
    " toggle the variable that says if we're in a code block
    if b:fenced_block == 0
      let b:fenced_block = 1
    elseif b:fenced_block == 1
      let b:fenced_block = 0
    endif
  elseif g:vim_markdown_frontmatter == 1
    " if we're in front matter and not on line 1
    if b:front_matter == 1 && a:lnum > 2
      if l0 == '---'
        let b:front_matter = 0
      endif
    elseif a:lnum == 1
      if l1 == '---'
        let b:front_matter = 1
      endif
    endif
  endif

  " if we're in a code block or front matter
  if b:fenced_block == 1 || b:front_matter == 1
    if a:lnum == 1
      " fold any 'preamble'
      return '>1'
    else
      " keep previous foldlevel
      return '='
    endif
  endif

  if l1 =~ '^#' && !s:isCode(a:lnum)
    " if we're on a non-code line starting with a pound sign set the fold
    " level to the number of hashes

    return '>' . matchend(l1, '^#\+')
  elseif l1 =~ '^\s*' && !s:isCode(a:lnum)
    " if we're in a list, fold by indent, relatively to previous fold level

    let i1 = indent(a:lnum) / shiftwidth() + 1
    let i2 = indent(a:lnum + 1) / shiftwidth() + 1

    if i2 > i1
      return 'a' . (l:i2 - l:i1)
    elseif i2 == i1
      return '='
    else
      return 's' . (l:i1 - l:i2)
    endif
  elseif a:lnum == 1
    " if we're on line 1 fold any 'preamble'
    return '>1'
  else
    " otherwise keep previous foldlevel
    return '='
  endif
endfunction

function! s:isCode(lnum)
  let name = synIDattr(synID(a:lnum, 1, 0), 'name')
  return name =~ '^mkd\%(Code$\|Snippet\)'
endfunction
