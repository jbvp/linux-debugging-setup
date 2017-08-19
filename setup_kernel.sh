#!/bin/bash -x

KERNEL=torvalds/linux

BASE_DIR=~/linux
SRC_DIR=$BASE_DIR/src
BUILD_DIR=$BASE_DIR/build

mkdir $SRC_DIR $BUILD_DIR

git clone https://git.kernel.org/pub/scm/linux/kernel/git/$KERNEL.git $SRC_DIR/$KERNEL

cd $SRC_DIR/$KERNEL
make mrproper
make O=$BUILD_DIR/$KERNEL mrproper
make O=$BUILD_DIR/$KERNEL defconfig # or localmodconfig
make O=$BUILD_DIR/$KERNEL kvmconfig

# Enable debugging options
wget -O /tmp/debug.config https://raw.githubusercontent.com/jbvp/linux-debugging-setup/master/debug.config
scripts/kconfig/merge_config.sh -r -O $BUILD_DIR/$KERNEL/ $BUILD_DIR/$KERNEL/.config /tmp/debug.config
rm /tmp/debug.config

make O=$BUILD_DIR/torvalds/linux -j5

# Authorize auto-loading of the kernel gdb scripts
echo "add-auto-load-safe-path $SRC_DIR/$KERNEL/scripts/gdb/vmlinux-gdb.py" >> ~/.gdbinit
