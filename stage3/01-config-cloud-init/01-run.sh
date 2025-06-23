#!/bin/bash -e

install -m 644 files/99-no-user.cfg "${ROOTFS_DIR}/etc/cloud/cloud.cfg.d/"

on_chroot << EOF
cloud-init clean
EOF