#!/usr/bin/env bash

rm -rf build*

sudo mkosi --debug --distribution=fedora
mv build build-old
sudo mkosi --debug --distribution=fedora

sudo systemd-dissect --mtree build/image.raw > build/mtree
sudo systemd-dissect --mtree build-old/image.raw > build-old/mtree

diff build*/mtree
