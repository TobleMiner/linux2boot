buildroot external tree
=======================

This directory contains a buildroot external tree for linux2boot.
Clone this repo next to your buildroot tree.

Use this tree by specifying it in the buildroot build command:

`make BR2_EXTERNAL=../linux2boot/buildroot/ menuconfig`
