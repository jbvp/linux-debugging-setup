#!/bin/bash -x

PASSWORD="$1"
DEBIAN_VERSION="stretch"
IMG_NAME="DebianStretch"
FORMAT="qcow2"
SIZE="10G"

BASE_DIR=~/linux
IMG_DIR=$BASE_DIR/img

NBD_DEVICE=/dev/nbd0
MNT_POINT=/mnt

if [ -z "$PASSWORD" ]; then
	echo "Usage: $0 <password>"
	exit 1
fi

mkdir -p $IMG_DIR

qemu-img create -f $FORMAT ${IMG_DIR}/"${IMG_NAME}".${FORMAT} $SIZE

sudo modprobe nbd
sudo qemu-nbd -f $FORMAT -c $NBD_DEVICE ${IMG_DIR}/"${IMG_NAME}".${FORMAT}
sudo mkfs.ext4 $NBD_DEVICE
sudo mount $NBD_DEVICE $MNT_POINT

sudo debootstrap --arch amd64 --include openssh-server,gcc,make,git $DEBIAN_VERSION $MNT_POINT

sudo chroot $MNT_POINT <<EOF
echo "/dev/sda / ext4 errors=remount-ro 0 1" > /etc/fstab
echo -n box > /etc/hostname
echo "root:$PASSWORD" | chpasswd
exit
EOF

sudo umount $MNT_POINT
sudo qemu-nbd -d $NBD_DEVICE
sudo rmmod nbd
