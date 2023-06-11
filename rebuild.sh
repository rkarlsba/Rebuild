#!/bin/bash


VERSION=$1

case $VERSION in
    barebone|mainsail|fluidd|octoprint)
        echo "Building $VERSION"
        ;;
    *)
        echo "Wrong argument '$1'"
        echo "Usage: $0 <barebone|mainsail|fluidd|octoprint>"
        exit 1
    ;; 
esac

BUILD_DIR=build-${VERSION}

if ! test -d $BUILD_DIR ; then
    echo "$BUILD_DIR missing"
    git clone https://github.com/armbian/build $BUILD_DIR
fi

cd $BUILD_DIR
git checkout v23.05.2
git pull
cd ..
rm -rf ${BUILD_DIR}/userpatches
cp -r userpatches build-${VERSION}
cp armbian/customize-image-${VERSION}.sh ${BUILD_DIR}/userpatches/customize-image.sh
cp armbian/recore.csc ${BUILD_DIR}/config/boards
cp armbian/watermark.png ${BUILD_DIR}/packages/plymouth-theme-armbian

TAG=`git describe`
NAME="rebuild-${VERSION}-${TAG}"

echo "${NAME}" > ${BUILD_DIR}/userpatches/overlay/rebuild/rebuild-version
cd ${BUILD_DIR}
DOCKER_EXTRA_ARGS="--cpus=20" ./compile.sh rebuild
IMG=`ls -1 output/images/ | grep "img.xz$"`
echo "mv output/images/$IMG ../images/${NAME}.img.xz"
mv "output/images/$IMG" "../images/${NAME}.img.xz"
echo "🍰 Finished building ${NAME}"
