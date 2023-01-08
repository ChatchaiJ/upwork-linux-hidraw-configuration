#!/bin/sh

SOURCEDIR="${SOURCEDIR:-linux-5.10.158}"
CONFIG="${CONFIG:-/boot/config-5.10.0-18-amd64}"

# Default of HIDRAW_MAX_DEVICES is 64
MAX_DEVICES=256

## System preparation
apt-get update

# get packages necessary for building debian package from sources
apt-get -y install build-essential fakeroot

# get dependency packages that necessary for building linux kernel package
apt-get -y build-dep linux

# get linux kernel sources from debian repository
apt-get source linux

if [ ! -d "$SOURCEDIR" ]; then
	cat <<EOT
ERROR:
Expect $SOURCEDIR directory for kernel source, but can not find it
Please check the directory below, and modify SOURCEDIR var at
the top of this script.
EOT
	ls -l
	exit
fi

cd $SOURCEDIR

# prepare for building, we will build kernel for amd64 only
fakeroot make -f debian/rules.gen setup_amd64_none_amd64

### HERE we change HIDRAW_MAX_DEVICES from 64 to 256 ###
sed -i -e "s/HIDRAW_MAX_DEVICES 64/HIDRAW_MAX_DEVICES $MAX_DEVICES/" include/uapi/linux/hidraw.h

### Using existing kernel config as template ###
cat $CONFIG | \
sed	-e '/CONFIG_INTEGRITY_PLATFORM_KEYRING/d' \
	-e '/CONFIG_LOAD_UEFI_KEYS/d' \
	-e '/CONFIG_SECONDARY_TRUSTED_KEYRING/d' \
	-e '/CONFIG_SYSTEM_BLACKLIST_KEYRING/d' \
	-e 's/CONFIG_SYSTEM_TRUSTED_KEYS=.\+/CONFIG_SYSTEM_TRUSTED_KEYS=""/' \
> .config

### This is ugly, but should work for now! ###
printf "\n\n\n\n\n" | make oldconfig

make clean

### now do the real build ###
make -j `getconf _NPROCESSORS_ONLN` bindeb-pkg LOCALVERSION=-custom
