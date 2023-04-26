#!/bin/bash

CMD=`realpath $0`
TOOLS_DIR=`dirname $CMD`
TOP_DIR=$(realpath $TOOLS_DIR/../..)

IMAGE_TYPE=core-image-bsp

if [ ! $VERSION ]; then
    VERSION="DEBUG"
fi

if [ ! $VERSION_NUMBER ]; then
    VERSION_NUMBER="eng_by"_"$USER"
fi

VERSION=${VERSION^^}
VERSION_NUMBER="$VERSION_NUMBER"_"$(date -u +%Y%m%d%H%M_%Z)"_"$VERSION"
IMAGE_VERSION=$VERSION_NUMBER

rm -rf $TOP_DIR/build/conf
source poky/oe-init-build-env
cp ../meta-renesas/docs/template/conf/tinker-v/*.conf ./conf

echo IMAGE_VERSION ?= \"$IMAGE_VERSION\" >> conf/local.conf

if [ ! -e $TOP_DIR/build/downloads ]; then
    echo Extra prebuilt packages, please wait...
    7z x $TOOLS_DIR/oss_pkg_rzfive_v3.0.2.7z -o$TOP_DIR/build
fi

bitbake -c cleansstate u-boot-asus-renesas
bitbake -c cleansstate linux-asus-renesas

time bitbake $IMAGE_TYPE | tee build.log

if [ $? -eq 0 ]; then
    echo "==== Build yocto ok! ===="
else
    echo "==== Build yocto failed! ===="
    exit 1
fi
