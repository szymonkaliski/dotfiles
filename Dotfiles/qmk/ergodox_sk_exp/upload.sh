#!/usr/bin/env bash

QMK_FOLDER=~/Documents/Code/Utils/QMK\ Firmware/

pushd "$QMK_FOLDER" > /dev/null

teensy_loader_cli -mmcu=atmega32u4 -w -v ergodox_ez_sk_exp.hex

popd > /dev/null
