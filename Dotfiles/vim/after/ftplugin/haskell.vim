let s:spaces = repeat(" ", 4)
let s:tab = "	"

function! SlimuxEscape_haskell(text)
  let l:text = substitute(a:text, s:tab, s:spaces, "g")
  return ":{\n" . l:text . ":}\n"
endfunction
