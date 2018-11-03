" this sadly screws up some other highlights
finish

" augroup prettytemplate_plugin
"   au!

"   au FileType javascript,javascript.jsx call <sid>prettytemplate_load()
" augroup END

" function! s:prettytemplate_load()
"   " hacking around pretty template to have no default highlight,
"   " but still match tagged templates

"   " HTML breaks jsx...
"   " let s:rules = { 'css': 'css', 'html': 'html', 'glsl': 'glsl' }
"   let s:rules = { 'css': 'css', 'glsl': 'glsl' }

"   for key in keys(s:rules)
"     call jspretmpl#register_tag(key, s:rules[key])
"     call jspretmpl#loadOtherSyntax(key)
"     call jspretmpl#applySyntax(key, s:rules[key] . '`')
"   endfor
" endfunction

