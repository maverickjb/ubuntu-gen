#!/bin/bash -e

on_chroot << EOF
truncate -s 0 /etc/machine-id

rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
EOF

rm -rf /tmp/* ~/.bash_history

mv "${ROOTFS_DIR}/etc/resolv.conf" "${ROOTFS_DIR}/etc/.resolv.conf.systemd-resolved.bak"
mv "${ROOTFS_DIR}/etc/resolv.conf.bak" "${ROOTFS_DIR}/etc/resolv.conf"

rm -f "${ROOTFS_DIR}/usr/bin/qemu-aarch64-static"

unmount "${ROOTFS_DIR}"

unmount_image "${IMG_FILE}"