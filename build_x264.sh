#!/bin/sh

# This script is originally based off of the one by Gabriel Handford
# Original scripts can be found here: https://github.com/gabriel/ffmpeg-iphone-build
# Modified by Roderick Buenviaje
# Yet another modification by Radek Skokan
# Builds versions of the VideoLAN x264 for armv6 and armv7
# Combines the two libraries into a single one
#
# To use the script, make sure you have GCC/LLVM-GCC installed: Xcode/Preferences/Downloads/Components/Command Line Tools

trap exit ERR

export DIR=./x264
export DEST6=armv6/
export DEST7=armv7/
#specify the version of iOS you want to build against
export VERSION="5.1"

export ISYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${VERSION}.sdk"

mkdir -p ./x264

git clone git://git.videolan.org/x264.git x264

cd $DIR

echo "Building armv6..."

#export CC=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/llvm-gcc
./configure --host=arm-apple-darwin \
--sysroot=$ISYSROOT \
--prefix=$DEST6 \
--extra-cflags='-arch armv6'\
 --extra-ldflags="-L${ISYSROOT}/usr/lib/system -arch armv6" \
--enable-pic --enable-static \
--disable-asm

make && make install

echo "Installed: $DEST6"


echo "Building armv7..."

#export CC=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/llvm-gcc
./configure --host=arm-apple-darwin \
--sysroot=$ISYSROOT \
--prefix=$DEST7 \
--extra-cflags='-arch armv7' \
--extra-ldflags="-L${ISYSROOT}/usr/lib/system -arch armv7" \
--enable-pic --enable-static

make && make install

echo "Installed: $DEST7"


echo "Combining Libraries"
ARCHS="armv6 armv7"

BUILD_LIBS="libx264.a"

OUTPUT_DIR="x264-uarch"
mkdir $OUTPUT_DIR
mkdir $OUTPUT_DIR/lib
mkdir $OUTPUT_DIR/include

for LIB in $BUILD_LIBS; do
  LIPO_CREATE=""
  for ARCH in $ARCHS; do
    LIPO_CREATE="$LIPO_CREATE-arch $ARCH $ARCH/lib/$LIB "
  done
  OUTPUT="$OUTPUT_DIR/lib/$LIB"
  echo "Creating: $OUTPUT"
  lipo -create $LIPO_CREATE -output $OUTPUT
  lipo -info $OUTPUT
done

cp -f $ARCH/include/*.* $OUTPUT_DIR/include/

