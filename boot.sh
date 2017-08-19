#!/bin/bash -x

KERNEL=torvalds/linux
DISK_NAME="DebianStretch"
FORMAT="qcow2"

BASE_DIR=~/linux
BUILD_DIR=$BASE_DIR/build
IMG_DIR=$BASE_DIR/img

kvm -s -kernel $BUILD_DIR/$KERNEL/arch/x86_64/boot/bzImage -nographic -m 512 -drive file=${IMG_DIR}/"${DISK_NAME}".${FORMAT},index=0,media=disk -append "root=/dev/sda earlyprintk=serial,ttyS0,9600 console=ttyS0,9600n8"
