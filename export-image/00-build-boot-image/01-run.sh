#!/bin/bash -e

BOOTIMG_FILE="${STAGE_WORK_DIR}/boot.img"
DTB_FILE=$(find "${ROOTFS_DIR}/boot" -type f -name "*dtb*" | head -n 1)
VMLINUZ_FILE=$(find "${ROOTFS_DIR}/boot" -type f -name "*vmlinuz*" | head -n 1)

if [[ -n "$DTB_FILE" && -n "$VMLINUZ_FILE" ]]; then
    echo "Found dtb file: $DTB_FILE"
    echo "Found vmlinuz file: $VMLINUZ_FILE"
    if command -v mkbootimg &> /dev/null; then
        echo "Running mkbootimg..."
        cat $VMLINUZ_FILE $DTB_FILE > "${STAGE_WORK_DIR}/zImage"
        mkbootimg --kernel "${STAGE_WORK_DIR}/zImage" \
            --cmdline "console=tty0 root=/dev/sda33 rw rootwait quiet splash" \
            --base 0x00000000 \
            --kernel_offset 0x00008000 \
            --tags_offset 0x00000100 \
            --pagesize 4096 --id \
            -o $BOOTIMG_FILE
		rm -rf "${STAGE_WORK_DIR}/zImage"
	else
		echo "mkbootimg command not found, skipping boot image creation."
    fi
fi
