#!/bin/bash -x

KERNEL=torvalds/linux

BASE_DIR=~/linux
SRC_DIR=$BASE_DIR/src
BUILD_DIR=$BASE_DIR/build

# gdb must be started from the built kernel directory, because that's what
# the Python scripts expect. For example, the lx-symbols command executes
# "symbol-file vmlinux".
cd $BUILD_DIR/$KERNEL

gdb --eval 'target remote localhost:1234' vmlinux
