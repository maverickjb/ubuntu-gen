#!/bin/bash -e

on_chroot << EOF
apt-get -y upgrade
EOF