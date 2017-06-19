#!/bin/bash

set -e

ZFS_VERSION="0.6.5.10"
export ZFS_VERSION1=$ZFS_VERSION
ZFS_DIR="zfs-${ZFS_VERSION}"
SPL_DIR="spl-${ZFS_VERSION}"
ZFS_TAR="${ZFS_DIR}.tar.gz"
SPL_TAR="${SPL_DIR}.tar.gz"
ZFS_DOWNLOAD_URL="https://github.com/zfsonlinux/zfs/releases/download/zfs-${ZFS_VERSION}"
OS_DIST="el7"
ARCH="x86_64"
KERN_VERSION=`uname -r`
#KERN_VERSION=3.10.0-327.13.1.el7.x86_64

#if ! rpm -q --quiet kernel-devel-${KERN_VERSION}; then
#       echo "Package kernel-devel-${KERN_VERSION} not found. Exitting.."
#       exit 1
#fi

yum groupinstall -y "Development Tools"
#yum install -y kernel-devel zlib-devel libuuid-devel libblkid-devel libselinux-devel parted lsscsi wget redhat-lsb ksh libattr-devel libudev-devel
yum install -y kernel-headers zlib-devel libuuid-devel libblkid-devel libselinux-devel parted lsscsi wget redhat-lsb ksh libattr-devel libudev-devel
#yum install -y kernel-devel-${KERN_VERSION} kerner-headers-${KERN_VERSION}

if [ $(lsb_release -si) == "CentOS" ]
then
        OS_DIST="el7.centos"
fi

wget ${ZFS_DOWNLOAD_URL}/spl-${ZFS_VERSION}.tar.gz
wget ${ZFS_DOWNLOAD_URL}/zfs-${ZFS_VERSION}.tar.gz

tar -xzf ${ZFS_TAR}
tar -xzf ${SPL_TAR}

cd ${SPL_DIR}
./configure
make pkg-utils pkg-kmod
yum localinstall -y     *.${ARCH}.rpm

cd ../${ZFS_DIR}
./configure
make pkg-utils pkg-kmod

cd ..
mkdir -p zfs-dist
cp  ${SPL_DIR}/spl-${ZFS_VERSION}-?.${OS_DIST}.${ARCH}.rpm \
        ${SPL_DIR}/kmod-spl-${KERN_VERSION}-${ZFS_VERSION}-?.${OS_DIST}.${ARCH}.rpm \
        ${ZFS_DIR}/libnvpair1-${ZFS_VERSION}-?.${OS_DIST}.${ARCH}.rpm \
        ${ZFS_DIR}/libuutil1-${ZFS_VERSION}-?.${OS_DIST}.${ARCH}.rpm \
        ${ZFS_DIR}/libzfs2-${ZFS_VERSION}-?.${OS_DIST}.${ARCH}.rpm \
        ${ZFS_DIR}/libzfs2-devel-${ZFS_VERSION}-?.${OS_DIST}.${ARCH}.rpm \
        ${ZFS_DIR}/libzpool2-${ZFS_VERSION}-?.${OS_DIST}.${ARCH}.rpm \
        ${ZFS_DIR}/zfs-${ZFS_VERSION}-?.${OS_DIST}.${ARCH}.rpm \
        ${ZFS_DIR}/kmod-zfs-${KERN_VERSION}-${ZFS_VERSION}-?.${OS_DIST}.${ARCH}.rpm \
        ${ZFS_DIR}/zfs-dracut-${ZFS_VERSION}-?.${OS_DIST}.${ARCH}.rpm \
        zfs-dist

echo "ZFS built successfully on ${OS_DIST} for kernel ${KERN_VERSION}"
