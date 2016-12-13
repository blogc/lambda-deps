#!/bin/bash

set -ex

source config.sh

P_MAKE="make-${PV_MAKE}"
A_MAKE="${P_MAKE}.tar.bz2"
SRC_MAKE="http://ftp.gnu.org/gnu/make/${P_MAKE}.tar.bz2"

P_BUSYBOX="busybox-${PV_BUSYBOX}"
A_BUSYBOX="${P_BUSYBOX}.tar.bz2"
SRC_BUSYBOX="https://busybox.net/downloads/${P_BUSYBOX}.tar.bz2"

rm -rf build root
mkdir -p build root/{bin,licenses} src

wget -c -P src/ "${SRC_MAKE}" "${SRC_BUSYBOX}"


#### MAKE

tar -xvf "src/${A_MAKE}" -C build/

pushd "build/${P_MAKE}" > /dev/null

patch -p1 < ../../patches/make_do-not-call-getpwnam.patch

rm -rf build
mkdir -p build

pushd build > /dev/null
../configure \
    CFLAGS="-Wall -Os" \
    LDFLAGS="-static" \
    --disable-load \
    --without-guile \
    --disable-nls
popd > /dev/null
popd > /dev/null

make -C "build/${P_MAKE}/build" make

install -m 755 "build/${P_MAKE}/build/make" root/bin/make
install -m 644 "build/${P_MAKE}/COPYING" root/licenses/make
strip root/bin/make


#### BUSYBOX

tar -xvf "src/${A_BUSYBOX}" -C build/

cp configs/busybox "build/${P_BUSYBOX}/.config"

make -C "build/${P_BUSYBOX}" V=1 busybox

install -m 755 "build/${P_BUSYBOX}/busybox" root/bin/busybox
install -m 644 "build/${P_BUSYBOX}/LICENSE" root/licenses/busybox

for bin in $(root/bin/busybox --list); do
    ln -s busybox "root/bin/${bin}"
done


#### OUTPUT TARBALL

install -m 644 "README.deps" root/README.deps

tar -cvJf "blogc-lambda-deps-${PV}.tar.xz" -C root/ .
