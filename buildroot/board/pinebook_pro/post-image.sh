#!/bin/sh

BOARD_DIR="$(dirname $0)"

GENIMAGE_CFG_SDCARD="${BOARD_DIR}/genimage-sdcard.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

MKIMAGE="$HOST_DIR"/bin/mkimage
LZMA="$HOST_DIR"/bin/lzma
INSTALL="$HOST_DIR"/bin/install

LOADADDR=0x02080000

# mkimage needs precompressed images
$LZMA -f $BINARIES_DIR/Image

# Create fit image
# Load address and entry point are the same
$MKIMAGE -f auto -A arm64 -O linux -T kernel -C lzma -a $LOADADDR -e $LOADADDR \
	 -n linux -d $BINARIES_DIR/Image.lzma -b $BINARIES_DIR/rk3399-pinebook-pro.dtb \
	 $BINARIES_DIR/Image.fit

# Build boot scripts
$MKIMAGE -C none -A arm64 -T script -d $BOARD_DIR/boot-sdcard.txt $BINARIES_DIR/boot-sdcard.scr

# Generate images
trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG_SDCARD}"
