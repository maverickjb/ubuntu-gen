#!/bin/bash -e

install -D -m 644 files/HiFi.conf "${ROOTFS_DIR}/usr/share/alsa/ucm2/Xiaomi/nabu/HiFi.conf"
install -D -m 644 files/sm8150.conf "${ROOTFS_DIR}/usr/share/alsa/ucm2/conf.d/sm8150/sm8150.conf"
