#!/bin/env sh

set -e

ROOT_DIR="$1"
BOARD_DIR="$(dirname $0)"

install -D -m755 "$BOARD_DIR"/preinit.sh "$ROOT_DIR"/sbin/preinit
