" Theme setup
hi clear
syntax reset
let g:colors_name = "lowkey"
set background=light

" Grayscale
let s:black =           "1d1f21" " 00
let s:light_black =     "282a2e" " 01
let s:very_dark_gray =  "373b41" " 02
let s:dark_gray =       "969896" " 03
let s:gray =            "b4b7b4" " 04
let s:light_gray =      "c5c8c6" " 05
let s:very_light_gray = "e0e0e0" " 06
let s:white =           "ffffff" " 07

" Colors
let s:red =             "cc6666" " 08
let s:orange =          "de935f" " 09
let s:light_orange =    "f0c674" " 0A
let s:green =           "b5bd68" " 0B
let s:cyan =            "8abeb7" " 0C
let s:blue =            "81a2be" " 0D
let s:purple =          "b294bb" " 0E
let s:dark_red =        "a3685a" " 0F

" Low Key
let s:invisible =       "7f7f7f"
let s:selection =       "cfd5d1"
let s:light_blue =      "476a97"
let s:dark_blue =       "262c6a"
let s:string =          "702c51"
let s:comment =         "435138"
let s:url =             "12139f"
let s:keyword =         s:dark_blue
let s:class =           s:light_blue
let s:function =        s:light_blue
let s:constant =        s:light_blue

" Highlighting function
fun <sid>hi(group, guifg, guibg, ctermfg, ctermbg, attr)
  if a:guifg != ""
    exec "hi " . a:group . " guifg=#" . a:guifg
  endif
  if a:guibg != ""
    exec "hi " . a:group . " guibg=#" . a:guibg
  endif
  if a:ctermfg != ""
    exec "hi " . a:group . " ctermfg=" . a:ctermfg
  endif
  if a:ctermbg != ""
    exec "hi " . a:group . " ctermbg=" . a:ctermbg
  endif
  if a:attr != ""
    exec "hi " . a:group . " gui=" . a:attr . " cterm=" . a:attr
  endif
endfun

" Vim editor colors
call <sid>hi("Directory",     s:dark_blue, "", "", "", "")
call <sid>hi("ErrorMsg",      s:white, s:red, "", "", "")
call <sid>hi("MatchParen",    s:selection, s:black, "", "",  "reverse")
call <sid>hi("Underlined",    s:light_blue, "", "", "", "none")
call <sid>hi("Visual",        "", s:selection, "", "", "")
call <sid>hi("WarningMsg",    s:red, "", "", "", "")
call <sid>hi("Title",         s:dark_blue, "", "", "", "none")
call <sid>hi("NonText",       s:white, s:white, "", "", "")
call <sid>hi("Normal",        s:black, "", "", "", "")
call <sid>hi("LineNr",        s:very_light_gray, s:white, "", "", "")
call <sid>hi("StatusLine",    "080808", "eeeeee", "", "", "bold")
call <sid>hi("StatusLineNC",  "b2b2b2", "eeeeee", "", "", "none")
call <sid>hi("VertSplit",     s:white, s:white, "", "", "")
call <sid>hi("CursorLine",    "", s:white, "", "", "none")
call <sid>hi("CursorLineNr",  s:gray, s:very_light_gray, "", "", "")
call <sid>hi("PMenu",         s:black, s:very_light_gray, "", "", "none")
call <sid>hi("PMenuSbar",     s:black, s:light_gray, "", "", "none")
call <sid>hi("PMenuSel",      s:black, s:light_gray, "", "", "none")
call <sid>hi("PMenuThumb",    s:black, s:dark_gray, "", "", "none")

" Standard syntax highlighting
call <sid>hi("Comment",      s:comment, "", "", "", "")
call <sid>hi("Constant",     s:constant, "", "", "", "")
call <sid>hi("Error",        s:white, s:red, "", "", "")
call <sid>hi("Function",     s:function, "", "", "", "")
call <sid>hi("Identifier",   s:class, "", "", "", "none")
call <sid>hi("Keyword",      s:dark_blue, "", "", "", "")
call <sid>hi("PreProc",      s:dark_blue, "", "", "", "")
call <sid>hi("Special",      s:black, "", "", "", "")
call <sid>hi("Statement",    s:keyword, "", "", "", "none")
call <sid>hi("String",       s:string, "", "", "", "")
call <sid>hi("Todo",         s:comment, s:white, "", "", "bold")
call <sid>hi("Type",         s:class, "", "", "", "none")
call <sid>hi("Typedef",      s:class, "", "", "", "")

" CSS highlighting
call <sid>hi("cssBraces",       s:black, "", "", "", "")
call <sid>hi("cssClassName",    s:black, "", "", "", "")
call <sid>hi("cssClassNameDot", s:black, "", "", "", "")

" SASS highlighting
call <sid>hi("sassClassChar", s:black, "", "", "", "")
call <sid>hi("sassClass",     s:black, "", "", "", "")

" Markdown highlighting
call <sid>hi("markdownUrl",              s:url, "", "", "", "")
call <sid>hi("markdownHeadingDelimiter", s:dark_blue, "", "", "", "")

" Directory highlighting
call <sid>hi("NERDTreeDirSlash",  s:dark_blue, "", "", "", "")
call <sid>hi("NERDTreeExecFile",  s:light_blue, "", "", "", "")

" Remove functions
delf <sid>hi
