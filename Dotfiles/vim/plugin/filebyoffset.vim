" next / previous file (stolen from unimpaired)

function! s:Entries(path)
  let path = substitute(a:path,'[\\/]$','','')
  let files = split(glob(path."/.*"),"\n")
  let files += split(glob(path."/*"),"\n")
  call map(files,'substitute(v:val,"[\\/]$","","")')
  call filter(files,'v:val !~# "[\\\\/]\\.\\.\\=$"')

  let filter_suffixes = substitute(escape(&suffixes, '~.*$^'), ',', '$\\|', 'g') .'$'
  call filter(files, 'v:val !~# filter_suffixes')

  return files
endfunction

function! s:FileByOffset(num)
  let file = expand('%:p')
  let num = a:num
  while num
    let files = <sid>Entries(fnamemodify(file,':h'))
    if a:num < 0
      call reverse(sort(filter(files,'v:val <# file')))
    else
      call sort(filter(files,'v:val ># file'))
    endif
    let temp = get(files,0,'')
    if temp == ''
      let file = fnamemodify(file,':h')
    else
      let file = temp
      while isdirectory(file)
        let files = <sid>Entries(file)
        if files == []
          break
        endif
        let file = files[num > 0 ? 0 : -1]
      endwhile
      let num += num > 0 ? -1 : 1
    endif
  endwhile
  return file
endfunction

nnoremap ]f :<c-u>edit <c-r>=fnamemodify(fnameescape(<sid>FileByOffset(v:count1)), ':.')<cr><cr>
nnoremap [f :<c-u>edit <c-r>=fnamemodify(fnameescape(<sid>FileByOffset(-v:count1)), ':.')<cr><cr>
