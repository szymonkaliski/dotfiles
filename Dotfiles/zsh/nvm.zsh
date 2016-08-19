export NVM_DIR=~/.nvm

# append latest nvm node to PATH
local LATEST_NODE="$(ls ~/.nvm/versions/node/ | tail -1)"
export PATH="$HOME/.nvm/versions/node/$LATEST_NODE/bin:$PATH"

if [ ! -d $NVM_DIR ]; then
  mkdir ~/.nvm/ > /dev/null 2>&1
  cp -f /usr/local/opt/nvm/nvm-exec ~/.nvm/ > /dev/null 2>&1
fi

# lazy load nvm
nvm() { source /usr/local/opt/nvm/nvm.sh; nvm $@ }
