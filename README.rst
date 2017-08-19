Kernel Debugging Setup
======================

This repository contains personal notes on how to bootstrap a Debian image and
use it with KVM for kernel debugging.

Directory structure
-------------------

~/linux/src
  Linux sources
~/linux/build
  Where the kernels will be built (avoid mixing sources and built objects)
~/linux/img
  Where the disk images are stored

Automated
---------

The scripts included in this respository reproduce the steps decribed below in
the manual section.

Manual
------

Create the directory structure::

  mkdir -p ~/linux/{src,build,img}

Create a raw image::

  qemu-img create -f raw ~/linux/img/DebianStretch.img 10G
  mkfs.ext4 ~/linux/img/DebianDebianStretch.img
  mount -o loop ~/linux/img/DebianDebianStretch.img /mnt

Or a generic method working for all image formats, for example qcow2::

  qemu-img create -f qcow2 ~/linux/img/DebianStretch.img 10G
  modprobe nbd
  qemu-nbd -f qcow2 -c /dev/nbd0 ~/linux/img/DebianDebianStretch.img
  mkfs.ext4 /dev/nbd0
  mount /dev/nbd0 /mnt

Debootsrap Debian Stretch::

  debootstrap --arch amd64 --include openssh-server,gcc,make,git stretch /mnt
  chroot /mnt
  echo "/dev/sda / ext4 errors=remount-ro 0 1" > /etc/fstab
  echo -n box > /etc/hostname
  passwd
  umount /mnt

Clone a Linux repository::

  git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/ ~/linux/src/torvalds/linux

Config::

  cd ~/linux/src/torvalds/linux
  make mrproper
  make O=$BUILD_DIR/$KERNEL mrproper
  make O=~/linux/build/torvalds/linux defconfig # or localmodconfig
  make O=~/linux/build/torvalds/linux kvmconfig

Enable debugging options::

  wget -O /tmp/debug.config https://raw.githubusercontent.com/jbvp/linux-debugging-setup/master/debug.config
  scripts/kconfig/merge_config.sh -r -O ~/linux/build/torvalds/linux/ ~/linux/build/torvalds/linux/.config /tmp/debug.config
  rm /tmp/debug.config

Build::

  make O=~/linux/build/torvalds/linux -j5

Boot::

  kvm -s -kernel ~/linux/build/torvalds/linux/arch/x86_64/boot/bzImage -nographic -m 512 -drive file=~/linux/img/DebianStretch.img,index=0,media=disk -append "root=/dev/sda earlyprintk=serial,ttyS0,9600 console=ttyS0,9600n8"

Authorize auto-loading of the kernel gdb scripts::

  echo "add-auto-load-safe-path ~/linux/build/torvalds/linux/scripts/gdb/vmlinux-gdb.py" >> ~/.gdbinit

Debug::

  cd ~/linux/build/torvalds/linux
  gdb --eval 'target remote localhost:1234' vmlinux

Note: gdb must be started from the built kernel directory, because that's what
the Python scripts expect. For example, the lx-symbols command executes
"symbol-file vmlinux".
