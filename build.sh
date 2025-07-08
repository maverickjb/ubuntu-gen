#!/bin/bash -e

run_sub_stage()
{
	log "Begin ${SUB_STAGE_DIR}"
	pushd "${SUB_STAGE_DIR}" > /dev/null

	for i in {00..99}; do
		if [ -f "${i}-debconf" ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-debconf"
			on_chroot << EOF
debconf-set-selections <<SELEOF
$(cat "${i}-debconf")
SELEOF
EOF
			log "End ${SUB_STAGE_DIR}/${i}-debconf"
		fi

		if [ -f "${i}-packages" ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-packages"
			PACKAGES="$(sed -f "${SCRIPT_DIR}/remove-comments.sed" < "${i}-packages")"
			if [ -n "$PACKAGES" ]; then
				on_chroot << EOF
apt-get -o Acquire::Retries=3 install -y $PACKAGES
EOF
			fi
			log "End ${SUB_STAGE_DIR}/${i}-packages"
		fi

		if [ -x ${i}-run.sh ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-run.sh"
			./${i}-run.sh
			log "End ${SUB_STAGE_DIR}/${i}-run.sh"
		fi
	done

	popd > /dev/null
	log "End ${SUB_STAGE_DIR}"
}

run_stage(){
	log "Begin ${STAGE_DIR}"
	STAGE="$(basename "${STAGE_DIR}")"

	pushd "${STAGE_DIR}" > /dev/null

	STAGE_WORK_DIR="${WORK_DIR}/${STAGE}"
	ROOTFS_DIR="${STAGE_WORK_DIR}"/rootfs

	unmount "${WORK_DIR}/${STAGE}"

	if [ -f "${STAGE_DIR}/EXPORT_IMAGE" ]; then
		EXPORT_DIRS="${EXPORT_DIRS} ${STAGE_DIR}"
	fi

	if [ ! -f SKIP ]; then
		if [ "${CLEAN}" = "1" ]; then
			if [ -d "${ROOTFS_DIR}" ]; then
				rm -rf "${ROOTFS_DIR}"
			fi
		fi
		if [ -x prerun.sh ]; then
			log "Begin ${STAGE_DIR}/prerun.sh"
			./prerun.sh
			log "End ${STAGE_DIR}/prerun.sh"
		fi
		for SUB_STAGE_DIR in "${STAGE_DIR}"/*; do
			if [ -d "${SUB_STAGE_DIR}" ] && [ ! -f "${SUB_STAGE_DIR}/SKIP" ]; then
				run_sub_stage
			fi
		done
	fi

	unmount "${WORK_DIR}/${STAGE}"

	PREV_ROOTFS_DIR="${ROOTFS_DIR}"

	popd > /dev/null
	log "End ${STAGE_DIR}"
}

term() {
	if [ "$?" -ne 0 ]; then
		log "Build failed"
	else
		log "Build finished"
	fi
	unmount "${STAGE_WORK_DIR}"
	if [ "$STAGE" = "export-image" ]; then
		for img in "${STAGE_WORK_DIR}/"*.img; do
			unmount_image "$img"
		done
	fi
}

if [ "$(id -u)" != "0" ]; then
	echo "Please run as root" 1>&2
	exit 1
fi

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $BASE_DIR = *" "* ]]; then
	echo "There is a space in the base path of pi-gen"
	echo "This is not a valid setup supported by debootstrap."
	echo "Please remove the spaces, or move pi-gen directory to a base path without spaces" 1>&2
	exit 1
fi

export BASE_DIR

if [ -f config ]; then
	# shellcheck disable=SC1091
	source config
fi

export ARCH=arm64
export TARGET_UBUNTU_VERSION=${TARGET_UBUNTU_VERSION:-noble} # Don't forget to update stage0/prerun.sh
export TARGET_UBUNTU_MIRROR=${TARGET_UBUNTU_MIRROR:-"http://ports.ubuntu.com/ubuntu-ports"}
export IMG_FILENAME="ubuntu-$TARGET_UBUNTU_VERSION-nabu"

export SCRIPT_DIR="${BASE_DIR}/scripts"
export WORK_DIR="${WORK_DIR:-"${BASE_DIR}/work"}"

export LOG_FILE="${WORK_DIR}/build.log"

export TARGET_HOSTNAME=${TARGET_HOSTNAME:-ubuntu-nabu}

export LOCALE_DEFAULT="${LOCALE_DEFAULT:-en_GB.UTF-8}"

export CLEAN

export STAGE
export STAGE_DIR
export STAGE_WORK_DIR
export ROOTFS_DIR
export PREV_ROOTFS_DIR
export IMG_SUFFIX
export EXPORT_ROOTFS_DIR

# shellcheck source=scripts/common
source "${SCRIPT_DIR}/common"

mkdir -p "${WORK_DIR}"
trap term EXIT INT TERM

echo "Checking native $ARCH executable support..."
if ! arch-test -n "$ARCH"; then
	echo "WARNING: Only a native build environment is supported. Checking emulated support..."
	if ! arch-test "$ARCH"; then
		echo "No fallback mechanism found. Ensure your OS has binfmt_misc support enabled and configured."
		exit 1
	fi
fi

log "Begin ${BASE_DIR}"

STAGE_LIST=${STAGE_LIST:-${BASE_DIR}/stage*}
export STAGE_LIST

EXPORT_CONFIG_DIR=$(realpath "${EXPORT_CONFIG_DIR:-"${BASE_DIR}/export-image"}")
if [ ! -d "${EXPORT_CONFIG_DIR}" ]; then
	echo "EXPORT_CONFIG_DIR invalid: ${EXPORT_CONFIG_DIR} does not exist"
	exit 1
fi
export EXPORT_CONFIG_DIR

for STAGE_DIR in $STAGE_LIST; do
	STAGE_DIR=$(realpath "${STAGE_DIR}")
	run_stage
done

CLEAN=1
for EXPORT_DIR in ${EXPORT_DIRS}; do
	STAGE_DIR=${EXPORT_CONFIG_DIR}
	# shellcheck source=/dev/null
	source "${EXPORT_DIR}/EXPORT_IMAGE"
	EXPORT_ROOTFS_DIR=${WORK_DIR}/$(basename "${EXPORT_DIR}")/rootfs
	run_stage
done

log "End ${BASE_DIR}"