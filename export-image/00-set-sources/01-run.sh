#!/bin/bash -e

find "${ROOTFS_DIR}/var/lib/apt/lists/" -type f -delete
on_chroot << EOF
apt-get update
apt-get -y dist-upgrade --auto-remove --purge
apt-get clean
EOF
