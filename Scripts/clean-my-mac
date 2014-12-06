#!/usr/bin/env bash
# simple interactive mac cleanup script

read -p "$(tput setaf 3)Run periodic scripts?$(tput sgr0) (y/n) " RESP
if [ "$RESP" = "y" ]; then
  sudo periodic daily weekly monthly
fi

read -p "$(tput setaf 3)Clean .DS_Store files?$(tput sgr0) (y/n) " RESP
if [ "$RESP" = "y" ]; then
  sudo find / -name ".DS_Store" -exec rm {} \;
fi

read -p "$(tput setaf 3)Clean caches?$(tput sgr0) (y/n) " RESP
if [ "$RESP" = "y" ]; then
  # sudo rm -rf /private/var/folders/*
  # sudo rm -rf /System/Library/Caches/*
  sudo rm -rf /Library/Caches/*
  rm -rf ~/Library/Caches/*
fi

read -p "$(tput setaf 3)Clean logs?$(tput sgr0) (y/n) " RESP
if [ "$RESP" = "y" ]; then
  sudo rm -rf /private/var/log/*
  sudo rm -rf /Library/Logs/*
  rm -rf ~/Library/Logs/*
fi

read -p "$(tput setaf 3)Clean temporary files?$(tput sgr0) (y/n) " RESP
if [ "$RESP" = "y" ]; then
  rm -rf /private/var/tmp/Processing/
  rm -rf /private/var/tmp/Xcode/
  rm -rf /private/var/tmp/tmp*
fi

read -p "$(tput setaf 3)Clean saved application states?$(tput sgr0) (y/n) " RESP
if [ "$RESP" = "y" ]; then
  rm -rf ~/Library/Saved\ Application\ State/*
fi

read -p "$(tput setaf 3)Clean LaunchServices?$(tput sgr0) (y/n) " RESP
if [ "$RESP" = "y" ]; then
  /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister \
  -kill -r -domain local -domain system -domain user
fi

read -p "$(tput setaf 3)Rebuild Spotlight?$(tput sgr0) (y/n) " RESP
if [ "$RESP" = "y" ]; then
  sudo mdutil -E /
fi

read -p "$(tput setaf 3)Repair disk permissions?$(tput sgr0) (y/n) " RESP
if [ "$RESP" = "y" ]; then
  diskutil repairPermissions /
fi

echo -e "\n$(tput setaf 1)Clean done, restart your computer!$(tput sgr0)"
