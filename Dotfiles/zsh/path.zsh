export PATH="/usr/local/bin:/usr/bin:/bin/:/usr/local/sbin:/usr/sbin:/sbin"

if [ -d $HOME/Documents/Code/Scripts ]; then
  export PATH="$HOME/Documents/Code/Scripts:$PATH"
fi

if [ -d $HOME/Documents/Scripts ]; then
  export PATH="$HOME/Documents/Scripts:$PATH"
fi

if [ -d $HOME/Documents/Code/Bin ]; then
  export PATH="$HOME/Documents/Code/Bin:$PATH"
fi

if [ -d $HOME/Documents/Bin ]; then
  export PATH="$HOME/Documents/Bin:$PATH"
fi

# brew coreutils
if [ -d /usr/local/opt/coreutils/libexec/gnubin ]; then
  export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
  export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
fi

# go
if [ -d $HOME/Documents/Code/Go ]; then
  export GOPATH="$HOME/Documents/Code/Go"
  export GOBIN="$GOPATH/bin"
  export PATH="$GOBIN:$PATH"
fi

# lua
if [ -d $HOME/.luarocks/bin ]; then
  export PATH="$HOME/.luarocks/bin:$PATH"
fi

# haskell
if [ -d $HOME/.cabal/bin ]; then
  export PATH="$HOME/.cabal/bin:$PATH"
fi

# node
if [ -d $HOME/.nvm ]; then
  local LATEST_NODE=$(ls ~/.nvm/versions/node/ | sort -V | tail -1)
  export PATH="$HOME/.nvm/versions/node/$LATEST_NODE/bin:$PATH"
fi

# rust
if [ -d $HOME/.cargo ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# android
if [ -d $HOME/Library/Android ]; then
  export ANDROID_HOME=$HOME/Library/Android/sdk
  export PATH=$PATH:$ANDROID_HOME/tools
  export PATH=$PATH:$ANDROID_HOME/tools/bin
  export PATH=$PATH:$ANDROID_HOME/platform-tools
fi

# nix
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
  . $HOME/.nix-profile/etc/profile.d/nix.sh
fi

# java
if [ -d /usr/local/opt/openjdk@11/bin ]; then
  export PATH="/usr/local/opt/openjdk@11/bin:$PATH"
fi

# clean paths
typeset -gU path

