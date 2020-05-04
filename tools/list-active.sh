#!/bin/sh

# slight hacky, but a good overview, skipping git, and (Chisel's) home-bin/
(
    cd ~/.shellrc.d ||exit
    find . -type f -perm +111 -mindepth 2 \
        |grep -v '.git/' \
        |grep -v 'bin/' \
        |sed 's/^\.\///' \
        |sort
)
