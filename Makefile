# Filename: Makefile
# Author: Olivier Sirol <czo@free.fr>
# License: GPL-2.0 (http://www.gnu.org/copyleft)
# File Created: 17 September 2025
# Last Modified: Thursday 30 April 2026, 18:03
# Edit Time: 2:00:19
# Description:
#
#       OpenWRT Makefile for Seiscomp
#
# Copyright: (C) 2025, 2026 Olivier Sirol <czo@free.fr>
#
# Original Author: Andres Heinloo <andres@gfz-potsdam.de>
# (C) 2019 Andres Heinloo, Helmholtz-Zentrum Potsdam - Deutsches GeoForschungsZentrum GFZ

include $(TOPDIR)/rules.mk

PKG_NAME:=seiscomp-rutx
# Add _sdk-X.XX.X to PKG_RELEASE only if it's detected in the pwd path
PKG_RELEASE:=1$(shell pwd | grep -oP -- '-sdk-[0-9]+\.[0-9]+\.[0-9]+' | sed 's/-sdk-/_sdk-/')

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/SeisComP/seiscomp.git
PKG_SOURCE_URL_SEEDLINK:=https://github.com/SeisComP/seedlink.git

# PKG_VERSION:=6.4.1
# PKG_SOURCE_VERSION:=a7e4fa268b1d52267aaab56774986091d463bc71
# PKG_SOURCE_VERSION_SEEDLINK:=e6a676e7d60216efd374c4675069c55bb15987ef

PKG_VERSION:=6.8.2
PKG_SOURCE_VERSION:=9adcefab45b8b68ed93ce4798871a9d614ca84dd
PKG_SOURCE_VERSION_SEEDLINK:=e7a165a93dd08560c55974e3ed78ed93459f280e

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=AGPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Olivier SIROL <czo@ipgp.fr>

CMAKE_INSTALL:=1
CMAKE_BINARY_SUBDIR:=build
PKG_USE_NINJA:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/seiscomp-rutx
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Seiscomp acquisition module
  URL:=https://www.seiscomp.de
  DEPENDS:=+libstdcpp +libpthread +librt +libxml2 +libopenssl +python3-light +bash +findutils-find +lua +libuci-lua +luci-lib-nixio +luasocket
endef

define Package/seiscomp-rutx/description
  Seiscomp is a seismological software for data acquisition, processing,
  distribution and interactive analysis. This package contains the acquisition
  module only.
endef

define Package/seiscomp-rutx/conffiles
/etc/config/scgpio
/etc/config/seiscomp
endef

CMAKE_OPTIONS += -DFLEX_INCLUDE_DIR=$(STAGING_DIR)/../host/include -DSC_DOC_GENERATE=OFF -DSC_GLOBAL_UNITTESTS=OFF -DSC_GLOBAL_GUI=OFF

define Build/Patch
	cd $(PKG_BUILD_DIR)/src/base && git clone $(PKG_SOURCE_URL_SEEDLINK) && cd seedlink && git checkout $(PKG_SOURCE_VERSION_SEEDLINK)
	$(CP) $(STAGING_DIR)/../host/include/FlexLexer.h $(PKG_BUILD_DIR)/src/base/seedlink/libs/slutils/
	$(call Build/Patch/Default)
endef

define Package/seiscomp-rutx/install
	$(INSTALL_DIR) $(1)/opt/seiscomp $(1)/etc/init.d $(1)/etc/config
	$(CP) $(PKG_INSTALL_DIR)/usr/* $(1)/opt/seiscomp/
	$(INSTALL_BIN) ./files/scgpiod $(1)/opt/seiscomp/sbin/
	$(INSTALL_BIN) ./files/scwrtd $(1)/opt/seiscomp/sbin/
	$(INSTALL_BIN) ./files/scgpiod.init $(1)/etc/init.d/scgpiod
	$(INSTALL_BIN) ./files/scwrtd.init $(1)/etc/init.d/scwrtd
	$(INSTALL_CONF) ./files/scgpio.config $(1)/etc/config/scgpio
	$(INSTALL_CONF) ./files/seiscomp.config $(1)/etc/config/seiscomp
endef

$(eval $(call BuildPackage,seiscomp-rutx))
