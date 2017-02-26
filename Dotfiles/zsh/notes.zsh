# search for notes and display
ns() {
  if [ "$#" -eq 0 ]; then
    (cd ~/Documents/Dropbox/Notes/ && ls -1 | grep txt | sed 's/.txt$//')
  else
    if [ -n "$(find ~/Documents/Dropbox/Notes -iname "*$@*")" ]; then
      if [ -t 1 ]; then
        find ~/Documents/Dropbox/Notes -iname "*$@*" \
          -exec echo -e "$(tput setaf 5)\n$(basename {} .txt)\n$(tput sgr0)" \; \
          -exec cat {} \; \
          -exec echo \;
      else
        find ~/Documents/Dropbox/Notes -iname "*$@*" -exec cat {} \;
      fi
    else
      echo "No note matches your search"
    fi
  fi
}

# search for note and edit
ne() {
  if [ "$#" -eq 0 ]; then
    echo "You must give note name"
  else
    find ~/Documents/Dropbox/Notes -iname "*$@*" -exec $EDITOR "{}" +
  fi
}
compctl -g "~/Documents/Dropbox/Notes/*.txt(:t)" ne
