# linux2boot
linux2boot is a kexec based boot manager written in POSIX compatible
shell.

# Usage
linux2boot is an interactive shell script. It does automatically locate
linux2boot config files on mountable block devices attached to a system.

For best experience run linux2boot as login through getty in your inittab,
enable respawn.

## Config files
linux2boot uses simple config files comprised of shell code. Config files
must be placed inside `boot/linux2boot/` and must have the file extension
`.conf`. An example config file could look like this:

```sh
kernel=boot/Image
dtb=boot/dtbs/rockchip/rk3399-pinebook-pro.dtb
cmdline='root=/dev/mmcblk2p1 rw rootwait'
```

Valid options for a linux2boot config are:

* `kernel`: The kernel to load (mandatory)
* `dtb`: The device tree to load (optional)
* `cmdline`: The kernel cmdline (optional)
* `initrd`: The initramfs to load (optional)

All config options specify paths to a file. All paths specified within
the config are either absolute or relative.
Relative paths are relative to the root of the filesystem the config
file is stored on. Absolute paths are considered to be absolute to the
environment linux2boot is executed in. It is highly advised to use
relative paths only.

# Why
linux2boot is mostly intended as a minimal PoC for a kexec based boot
manager. There are already more complete solutions like petitboot out
there. The main advantage of linux2boot is its simplicity. There are
no additional dependencies apart from a Linux kernel with kexec
support and a posix shell. Thus getting a quick PoC up and running with
linux2boot is super easy.
If you are looking for advanced features like network booting linux2boot
is not for you.
