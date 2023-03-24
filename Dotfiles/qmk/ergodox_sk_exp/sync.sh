#!/usr/bin/env bash

QMK_FOLDER=~/Documents/Code/Repos/QMK\ Firmware
KEYMAP_FOLDER=$QMK_FOLDER/keyboards/ergodox_ez/keymaps/ergodox_sk_exp/
DOT_FOLDER=~/Documents/Code/Dotfiles/qmk/ergodox_sk_exp/

unison "$KEYMAP_FOLDER" "$DOT_FOLDER"
