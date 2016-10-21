# path

if [ -d $HOME/Documents/Code/Scripts ]; then
  export PATH="$HOME/Documents/Code/Scripts:$PATH"
elif [ -d $HOME/Documents/Scripts ]; then
  export PATH="$HOME/Documents/Scripts:$PATH"
fi

if [ -d $HOME/Documents/Code/Bin ]; then
  export PATH="$HOME/Documents/Code/Bin:$PATH"
fi

if [ -d /usr/local/bin ]; then
  export PATH="/usr/local/bin:$PATH"
fi

if [ -d /usr/local/sbin ]; then
  export PATH="/usr/local/sbin:$PATH"
fi

if [ -d /sbin ]; then
  export PATH="/sbin:$PATH"
fi

if [ -d /usr/sbin ]; then
  export PATH="/usr/sbin:$PATH"
fi

if [ -d /usr/local/opt/coreutils/libexec/gnubin ]; then
  export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
fi

if [ -d /usr/local/share/npm/bin ]; then
  export PATH="$PATH:/usr/local/share/npm/bin"
fi

# go

if [ -d $HOME/Documents/Code/Go ]; then
  export GOPATH="$HOME/Documents/Code/Go"
elif [ -d $HOME/Documents/Go ]; then
  export GOPATH="$HOME/Documents/Go"
fi
export GOBIN=$GOPATH/bin

# clean paths

typeset -gU path
