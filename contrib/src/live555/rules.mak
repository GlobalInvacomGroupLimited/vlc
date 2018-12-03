# live555

LIVE555_VERSION := 2018.11.26
LIVE555_FILE := live.$(LIVE555_VERSION).tar.gz
LIVEDOTCOM_URL := http://live555.com/liveMedia/public/$(LIVE555_FILE)
LIVEGI_URL     := https://github.com/GlobalInvacomGroupLimited/live555.git

ifndef CHECKOUT_TAG
LIVE555_HASH := 4ecf545e303fe0e996f464f1e7febb5df0661044
else
LIVE555_HASH := $(CHECKOUT_TAG)
endif



ifdef BUILD_NETWORK
ifdef GNUV3
PKGS += live555
endif
endif

#ifeq ($(call need_pkg,"live555"),)
#PKGS_FOUND += live555
#endif

$(TARBALLS)/live555-$(LIVE555_HASH).tar.xz:
	$(call download_git,$(LIVEGI_URL),master,$(LIVE555_HASH))
#	$(call download,$(LIVEDOTCOM_URL))

.sum-live555: live555-$(LIVE555_HASH).tar.xz
	$(call check_githash,$(LIVE555_HASH))
	touch $@

LIVE_TARGET = $(error live555 target not defined!)
ifdef HAVE_LINUX
LIVE_TARGET := linux
endif
ifdef HAVE_WIN32
LIVE_TARGET := mingw
endif
ifdef HAVE_DARWIN_OS
LIVE_TARGET := macosx
else
ifdef HAVE_BSD
LIVE_TARGET := freebsd
endif
endif
ifdef HAVE_SOLARIS
ifeq ($(ARCH),x86_64)
LIVE_TARGET := solaris-64bit
else
LIVE_TARGET := solaris-32bit
endif
endif

LIVE_EXTRA_CFLAGS := $(EXTRA_CFLAGS) -fexceptions $(CFLAGS)

live555: live555-$(LIVE555_HASH).tar.xz .sum-live555
	rm -Rf live555 && $(UNPACK)
	
	mv live555-$(LIVE555_HASH) live

	# Change permissions to patch and sed the source
	chmod -R u+w live
	# Remove hardcoded cc, c++, ar variables
	cd live && sed -e 's%cc%$(CC)%' -e 's%c++%$(CXX)%' -e 's%LIBRARY_LINK =.*ar%LIBRARY_LINK = $(AR)%' -i.orig config.$(LIVE_TARGET)
	# Replace libtool -s by ar cr for macOS only
	cd live && sed -i.orig -e s/"libtool -s -o"/"ar cr"/g config.macosx*
	# Add Extra LDFLAGS for macOS
	cd live && sed -i.orig -e 's%$(CXX)%$(CXX)\ $(EXTRA_LDFLAGS)%' config.macosx
	# Add the Extra_CFLAGS to all config files
	cd live && sed -i.orig \
		-e 's%^\(COMPILE_OPTS.*\)$$%\1 '"$(LIVE_EXTRA_CFLAGS)%" config.*
	# We want 64bits offsets and PIC on Linux
	cd live && sed -e 's%-D_FILE_OFFSET_BITS=64%-D_FILE_OFFSET_BITS=64\ -fPIC\ -DPIC%' -i.orig config.linux
	# Disable Locale for Solaris
	cd live && sed -e 's%-DSOLARIS%-DSOLARIS -DXLOCALE_NOT_USED%' -i.orig config.solaris-*bit
ifdef HAVE_ANDROID
	# Disable locale on Android too
	cd live && sed -e 's%-DPIC%-DPIC -DNO_SSTREAM=1 -DLOCALE_NOT_USED -I$(ANDROID_NDK)/platforms/$(ANDROID_API)/arch-$(PLATFORM_SHORT_ARCH)/usr/include%' -i.orig config.linux-with-shared-libraries
endif
	mv live live555-$(LIVE555_HASH)
	# Patch for MSG_NOSIGNAL
	$(APPLY) $(SRC)/live555/live555-nosignal.patch
	# Don't use FormatMessageA on WinRT
	#$(APPLY) $(SRC)/live555/winstore.patch
	# Don't rely on undefined behaviors
	#$(APPLY) $(SRC)/live555/no-null-reference.patch
	# Add a pkg-config file
	$(APPLY) $(SRC)/live555/add-pkgconfig-file.patch
	# Expose Server:
	#$(APPLY) $(SRC)/live555/expose_server_string.patch
ifdef HAVE_ANDROID
ifneq ($(LEGACY_NDK), 1)
	# Always access in_addr.s_addr field
	$(APPLY) $(SRC)/live555/in_addr-s_addr-field.patch
	# Don't use unavailable off64_t functions
	$(APPLY) $(SRC)/live555/file-offset-bits-64.patch
endif
endif

	mv live555-$(LIVE555_HASH) $@ && touch $@

SUBDIRS=groupsock liveMedia UsageEnvironment BasicUsageEnvironment

.live555: live555
	$(REQUIRE_GNUV3)
	cd $< && for subdir in $(SUBDIRS); do \
		echo "PREFIX = $(PREFIX)" >> $$subdir/Makefile.head && \
		echo "LIBDIR = $(PREFIX)/lib" >> $$subdir/Makefile.head ; done
	cd $< && echo "LIBDIR = $(PREFIX)/lib" >> Makefile.head && \
		echo "PREFIX = $(PREFIX)" >> Makefile.head
	cd $< && ./genMakefiles $(LIVE_TARGET)
	cd $< && for subdir in $(SUBDIRS); do $(MAKE) $(HOSTVARS) -C $$subdir; done
	cd $< && for subdir in $(SUBDIRS); do $(MAKE) $(HOSTVARS) -C $$subdir install; done
	touch $@
