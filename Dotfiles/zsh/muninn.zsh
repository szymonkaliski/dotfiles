export WIKI_PATH=$HOME/Documents/Dropbox/Wiki

if [ -d $WIKI_PATH ]; then
  alias muninn="muninn --root $WIKI_PATH"
  alias tasks="muninn tasks"

  today() {
    pushd $WIKI_PATH > /dev/null

    v +Today

    popd > /dev/null
  }

  wiki() {
    pushd $HOME/Documents/Dropbox/Wiki > /dev/null

    if [ "$#" -eq 0 ]; then
      v +"Wiki"
    else
      v +"Wiki $1"
    fi

    popd > /dev/null
  }
  compdef '_files -W $WIKI_PATH' wiki

  # even quicker inbox access
  inbox() {
    local file=$HOME/Documents/Dropbox/Wiki/inbox.md

    if [ "$#" -eq 0 ]; then
      cat $file
    else
      echo "\n$@\n" >> $file
    fi
  }
fi
