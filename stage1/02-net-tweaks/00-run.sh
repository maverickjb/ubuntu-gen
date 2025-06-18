#!/bin/bash -e

echo "127.0.1.1		${TARGET_HOSTNAME}" >> "${ROOTFS_DIR}/etc/hosts"

mv "${ROOTFS_DIR}/etc/resolv.conf" "${ROOTFS_DIR}/etc/resolv.conf.bak"

install -m 644 files/resolv.conf "${ROOTFS_DIR}/etc/"
