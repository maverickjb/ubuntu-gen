#!/bin/bash -e

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"

install -m 644 files/sources.list "${ROOTFS_DIR}/etc/apt/"
sed -i "s/RELEASE/${TARGET_UBUNTU_VERSION}/g" "${ROOTFS_DIR}/etc/apt/sources.list"
sed -i "s|URL|${TARGET_UBUNTU_MIRROR}|g" "${ROOTFS_DIR}/etc/apt/sources.list"

on_chroot <<- \EOF
	apt-get update
EOF
