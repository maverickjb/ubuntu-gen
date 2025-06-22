#!/bin/bash -e

find "${ROOTFS_DIR}/var/lib/apt/lists/" -type f -delete
on_chroot << EOF
apt-get autoremove -y
apt-get clean
EOF
