################################################################################
#
# linux2boot
#
################################################################################

LINUX2BOOT_VERSION = v0.1
LINUX2BOOT_SITE = $(call github,TobleMiner,linux2boot,$(LINUX2BOOT_VERSION))
LINUX2BOOT_LICENSE = MIT
LINUX2BOOT_LICENSE_FILES = LICENSE

define LINUX2BOOT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/linux2boot $(TARGET_DIR)/usr/sbin/
endef

define LINUX2BOOT_POST_INSTALL_INITTAB
	$(INSTALL) -D -m 0755 $(LINUX2BOOT_PKGDIR)/fs-overlay/etc/inittab\
	                      $(TARGET_DIR)/etc/inittab
endef

LINUX2BOOT_POST_INSTALL_TARGET_HOOKS += LINUX2BOOT_POST_INSTALL_INITTAB

$(eval $(generic-package))
