#!/bin/bash -e

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"

install -m 644 files/sources.list "${ROOTFS_DIR}/etc/apt/"
install -m 644 files/xiaomi-nabu.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"
sed -i "s/RELEASE/${TARGET_UBUNTU_VERSION}/g" "${ROOTFS_DIR}/etc/apt/sources.list"
sed -i "s|URL|${TARGET_UBUNTU_MIRROR}|g" "${ROOTFS_DIR}/etc/apt/sources.list"
sed -i "s/RELEASE/${TARGET_UBUNTU_VERSION}/g" "${ROOTFS_DIR}/etc/apt/sources.list.d/xiaomi-nabu.list"

cat files/xiaomi-nabu.gpg.key | gpg --dearmor > "${STAGE_WORK_DIR}/xiaomi-nabu.gpg"
install -m 644 "${STAGE_WORK_DIR}/xiaomi-nabu.gpg" "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/"
on_chroot <<- \EOF
	apt-get update
EOF
