if hash nvim 2> /dev/null; then
  export EDITOR="nvim"
else
  export EDITOR="vim"
fi

export HOMEBREW_NO_EMOJI=1
export MOSH_TITLE_NOPREFIX=1

# if [ -d /usr/local/include/ni2 ]; then
#   export OPENNI2_INCLUDE=/usr/local/include/ni2
#   export OPENNI2_REDIST=/usr/local/lib/ni2
# fi

# if [ -d $HOME/Documents/Code/Frameworks/NiTE-MacOSX-x64-2.2/ ]; then
#   export NITE2_INCLUDE=$HOME/Documents/Code/Frameworks/NiTE-MacOSX-x64-2.2/Include
#   export NITE2_REDIST64=$HOME/Documents/Code/Frameworks/NiTE-MacOSX-x64-2.2/Redist
# fi

