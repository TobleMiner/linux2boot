#!/bin/sh
# This script setups an overlayfs before init
# Run as init=<this script>
# Cofiguration is done via kernel cmdline parameters:
# Required parameters:
#  overlayro: read-only base
#  overlayrw: read/write overlay
# Optional parameters:
#  overlayrofstype: filesystem type of read-only base
#  overlayroflags: mount flags for read-only base
#  overlayrwfstype: filesystem type of read/write overlay
#  overlayrwflags: mount flags for read/write overlay
#  overlaydebug: set to 1 to enable debugging

if [ -n "$overlaydebug" ]; then
	set -x
fi

export PATH="/bin:/sbin:/usr/bin:/usr/sbin"

info() {
	echo ":: $@"
}

err() {
	echo "!! $@"
}

info "Running overlayfs handler"

bail_out() {
	exec /sbin/init
}

ensure_mountpoint() {
	if ! [ -e "$1" ]; then
		info "Mountpoint '$1' does not exist, creating"
		mkdir "$1" || bail_out
	fi
}

if [ -z "$overlayro" ]; then
	err "ro base not configured, skipping handler"
	bail_out
fi

if [ -z "$overlayrw" ]; then
	err "rw overlay not configured, skipping handler"
	bail_out
fi

# Preparation: Ensure procfs is mounted
mount -t proc none /proc

# Assume / is ro, mount tmpfs on /mnt
ensure_mountpoint /mnt
mount -t tmpfs -o size=32M none /mnt

# Ensure base and overlay mounts exist
ensure_mountpoint /mnt/rom
ensure_mountpoint /mnt/flash

if ! mount ${overlayrofstype:+-t $overlayrofstype}\
           -o ro${overlayroflags:+,$overlayroflags}\
           "$overlayro" /mnt/rom; then
	err "Failed to mount read only base, bailing out"
	bail_out
fi

if ! mount ${overlayrwfstype:+-t $overlayrwfstype}\
           -o rw${overlayrwflags:+,$overlayrwflags}\
           "$overlayrw" /mnt/flash; then
	err "Failed to mount rw overlay, bailing out"
	bail_out
fi

# Create mountpoints for overlayfs
ensure_mountpoint /mnt/flash/upper
ensure_mountpoint /mnt/flash/work
ensure_mountpoint /mnt/overlay

if ! mount -t overlay\
           -o lowerdir=/mnt/rom,upperdir=/mnt/flash/upper,workdir=/mnt/flash/work${overlayflags:+,$overlayflags}\
           overlay /mnt/overlay; then
	err "Failed to overlay ro and rw fs, bailing out"
	bail_out
fi

# Create mountpoint for old root
ensure_mountpoint /mnt/overlay/rom

cd /mnt/overlay
if ! pivot_root . rom; then
	err "Failed to switch to overlay root, bailing out"
	bail_out
fi

# Move system mounts
for m in dev proc run sys; do
	if ! mount -o move rom/$m $m; then
		info "Failed to move mount rom/$m, unmounting"
		umount rom/$m
	fi
done

# Run init
exec usr/sbin/chroot . /sbin/init
