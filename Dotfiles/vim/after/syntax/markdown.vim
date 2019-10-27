" - list item @any(tag with comments)
" - list item @tag-without-comments

syntax match markdownTag /\ @\S*/     containedin=mkdListItemLine
syntax match markdownTag /\ @\S*(.*)/ containedin=mkdListItemLine

" - list item @due(today-date)

" syntax match markdownTodoDue /@due(\d\d\d\d-\d\d-\d\d)/ containedin=mkdListItemLine
execute "syntax match markdownTodoToday '\ @due(" . strftime('%Y-%m-%d') . ")' containedin=mkdListItemLine"

" - [ ] checkboxes

syntax match markdownListItemDone /^\s*-\ \[x\]\ .*$/
syntax match markdownUnchecked    "\[ \]" containedin=mkdListItemLine,markdownListItemDone
syntax match markdownChecked      "\[x\]" containedin=mkdListItemLine,markdownListItemDone

" ~~strikethrough~~

syntax region markdownStrikethrough start="\S\@<=\~\~\|\~\~\S\@=" end="\S\@<=\~\~\|\~\~\S\@=" keepend containedin=ALL
syntax match markdownStrikethroughLines "\~\~" conceal containedin=markdownStrikethrough

highlight def link markdownStrikethroughLines Comment
highlight def link markdownStrikethrough Comment

