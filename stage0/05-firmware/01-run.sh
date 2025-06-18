#!/bin/bash -e

cp files/*-xiaomi-nabu.deb ${ROOTFS_DIR}/tmp/

on_chroot << EOF
dpkg -i /tmp/*-xiaomi-nabu.deb
EOF