#!/bin/bash -x

KERNEL=torvalds/linux

BASE_DIR=~/linux
BUILD_DIR=$BASE_DIR/build

gdb --eval 'target remote localhost:1234' $BUILD_DIR/$KERNEL/vmlinux
