# make completion /Applications aware
compctl -f \
  -x 'p[2]' \
  -s "$(/bin/ls -d1 /Applications/*/*.app /Applications/*.app | sed 's|^.*/\([^/]*\)\.app.*|\\1|;s/ /\\\\ /g')" \
  -- open
alias run="open -a"
alias qopen="qlmanage -p "$@" >& /dev/null"

alias clear-logs="sudo rm -rfv /private/var/log/asl/*.asl"
alias clear-tmp="sudo rm -rfv /private/var/tmp/Xcode/ /private/var/tmp/Processing/"
alias clear-dsstore="sudo find . -name '.DS_Store' -depth -exec rm {} \;"

alias flush="dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias purge="sudo purge"

alias localip="ipconfig getifaddr en1"
alias opened-ports="sudo lsof -i -P | grep -i 'listen'"
alias stroke="/System/Library/CoreServices/Applications/Network\ Utility.app/Contents/Resources/stroke"
alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"

alias chrome-kill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

alias clout="fc -e - | pbcopy"
alias cpwd='echo -n \"$(pwd | tr -d "\n")\" | pbcopy'

# nice markdown files in cli using markdown-pdf from npm
if hash markdown-pdf 2> /dev/null; then
  alias markdown-pdf-nice="markdown-pdf --css-path ~/Documents/Code/Markdown/Byword.css --render-delay 50 --paper-border 2cm"
fi

# taskpaper related
if [ -d ~/Documents/Dropbox/Tasks/ ]; then
  alias tasks="node ~/Documents/Projects/Archive/TaskPaperNext/app.js --path ~/Documents/Dropbox/Tasks/Todo.taskpaper"
fi

# man in preview
pman() {
  man -t $1 | open -f -a Preview;
}
compdef _man pman=man

# cd to currently open dir in finder
cdf() {
  local finder_dir="$(osascript -e 'try' \
    -e 'tell application "Finder" to get POSIX path of (target of front Finder window as text)' \
    -e 'end try')"
  cd "$finder_dir"
}

# shorter open
o() {
  if [ "$#" -ne 0 ]; then
    ARG="${1:+"$@"}"
  else
    ARG="."
  fi

  open $ARG
}

# dash
dash() {
  open "dash://$*"
}
