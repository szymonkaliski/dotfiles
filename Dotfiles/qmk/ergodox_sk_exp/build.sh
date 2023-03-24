#!/usr/bin/env bash

QMK_FOLDER=~/Documents/Code/Repos/QMK\ Firmware

pushd "$QMK_FOLDER" || exit

./util/docker_build.sh ergodox_ez:ergodox_sk_exp
printf "\n\nUpload 'ergodox_ez_ergodox_sk_exp.hex' with Teensy uploader\n"

popd || exit
