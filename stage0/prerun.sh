#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
	bootstrap ${TARGET_UBUNTU_VERSION} "${ROOTFS_DIR}" ${TARGET_UBUNTU_MIRROR}
fi

if [ "$(uname -m)" != "aarch64" ]; then
    if ! command -v qemu-aarch64-static >/dev/null; then
        echo "You need qemu-aarch64-static for cross-building on x86_64"
        exit 1
    fi
    cp /usr/bin/qemu-aarch64-static "${ROOTFS_DIR}/usr/bin/"
fi