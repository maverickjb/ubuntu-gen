#!/bin/bash -e

sed -i 's/^#\?HandlePowerKey=.*/HandlePowerKey=poweroff/' "${ROOTFS_DIR}/etc/systemd/logind.conf"
