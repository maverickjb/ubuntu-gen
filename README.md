## About This Repository

This is another repository that provides scripts for automatically building `rootfs.img` for the Xiaomi Pad 5 running Ubuntu.

Since map220v has already created a similar project, I use his `.deb` packages for testing.

This repository is based on **pi-gen**, the Raspberry Pi image building scripts.

## How to Use

### (Optional) Create a `config` File

If you want to change the Ubuntu mirror or build a version other than **noble (24.04)**, create a file named `config` like this:

```
#!/bin/bash

# The version of Ubuntu to generate.  Successfully tested LTS: bionic, focal, jammy, noble
# See https://wiki.ubuntu.com/DevelopmentCodeNames for details
TARGET_UBUNTU_VERSION="noble"

# The Ubuntu Mirror URL. It's better to change for faster download.
TARGET_UBUNTU_MIRROR="http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports"
```

### Build the Image

```
sudo ./build.sh
```

After the build finishes, the image file will be located in:

```
work/ubuntu-noble-arm64/export-image/
```



## References

- [map220v/ubuntu-xiaomi-nabu](https://github.com/map220v/ubuntu-xiaomi-nabu)
- [RPi-Distro/pi-gen: Tool used to create the official Raspberry Pi OS images](https://github.com/RPi-Distro/pi-gen)
- [mvallim/live-custom-ubuntu-from-scratch: (Yes, the project is still alive 😃) This procedure shows how to create a bootable and installable Ubuntu Live (along with the automatic hardware detection and configuration) from scratch. A Linux to call your own.](https://github.com/mvallim/live-custom-ubuntu-from-scratch)