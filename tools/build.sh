#!/bin/bash

CMD=`realpath $0`
TOOLS_DIR=`dirname $CMD`
TOP_DIR=$(realpath $TOOLS_DIR/../..)

IMAGE_TYPE=core-image-bsp
IMAGE_PATH=$TOP_DIR/build/tmp/deploy/images/rzfive-tinker-v
TARGET_PRODUCT=tinker-v
IMAGE_FOLDER=$TOP_DIR/Image-${TARGET_PRODUCT}

if [ -e $IMAGE_FOLDER ]; then
    rm -rf $IMAGE_FOLDER
fi
mkdir -p $IMAGE_FOLDER

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
cp ../meta-asus-renesas/docs/template/conf/tinker-v/*.conf ./conf

echo IMAGE_VERSION ?= \"$IMAGE_VERSION\" >> conf/local.conf

if [ ! -e $TOP_DIR/build/downloads ]; then
    echo Extra prebuilt packages, please wait...
    7z x $TOOLS_DIR/oss_pkg_rzfive_v3.0.2.7z -o$TOP_DIR/build
fi

bitbake -c cleansstate asus-overlay
bitbake -c cleansstate core-image-bsp
bitbake -c cleansstate u-boot-asus-renesas
bitbake -c cleansstate linux-asus-renesas

time bitbake $IMAGE_TYPE | tee build.log

if [ $? -eq 0 ]; then
    echo "==== Build yocto ok! ===="
else
    echo "==== Build yocto failed! ===="
    exit 1
fi

echo "Create image..."
cp $IMAGE_PATH/Flash_Writer_SCIF_TINKER_V.mot $IMAGE_FOLDER
cp $IMAGE_PATH/spl-rzfive-tinker-v.srec $IMAGE_FOLDER
cp $IMAGE_PATH/fit-rzfive-tinker-v.srec $IMAGE_FOLDER
cp $IMAGE_PATH/Image-rzfive-tinker-v.bin $IMAGE_FOLDER
cp $IMAGE_PATH/Image-r9a07g043f01-tinker-v.dtb $IMAGE_FOLDER
cp $IMAGE_PATH/core-image-bsp-rzfive-tinker-v.tar.bz2 $IMAGE_FOLDER
echo "done."
