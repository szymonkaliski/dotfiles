#!/usr/bin/env bash

QMK_FOLDER=~/Documents/Code/Utils/QMK\ Firmware/

pushd "$QMK_FOLDER" > /dev/null

docker run -e keymap=sk -e keyboard=ergodox -v "$QMK_FOLDER":/qmk --rm edasque/qmk_firmware

popd > /dev/null



