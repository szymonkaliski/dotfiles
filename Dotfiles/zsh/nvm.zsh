export NVM_DIR=~/.nvm

if [ ! -d $NVM_DIR ]; then
  mkdir ~/.nvm/ > /dev/null 2>&1
  cp -f /usr/local/opt/nvm/nvm-exec ~/.nvm/ > /dev/null 2>&1
fi

# lazy load nvm
nvm() { source /usr/local/opt/nvm/nvm.sh; nvm $@ }
