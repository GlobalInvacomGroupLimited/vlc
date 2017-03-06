# boost

#boost_FILE := boost.2016.01.12.tar.gz
#boostDOTCOM_URL := http://boost.com/boostMedia/public/$(boost_FILE)
#boostDOTCOM_URL := $(CONTRIB_VIDEOLAN)/boost/$(boost_FILE)
BOOST_URL     := git://sourcery/libraries/boost.git

ifndef CHECKOUT_TAG
BOOST_HASH := 5e5c1de7137ee01109eb2b1c4325c4ebdcc57571
else
BOOST_HASH := $(CHECKOUT_TAG)
endif



ifdef BUILD_NETWORK
PKGS += boost
endif

$(TARBALLS)/boost-$(BOOST_HASH).tar.xz:
	$(call download_git,$(BOOST_URL),,$(BOOST_HASH))


.sum-boost: boost-$(BOOST_HASH).tar.xz
	$(call check_githash,$(BOOST_HASH))
	touch $@

boost_TARGET = $(error boost target not defined!)
ifdef HAVE_LINUX
boost_TARGET := linux
endif
ifdef HAVE_WIN32
boost_TARGET := mingw
endif
ifdef HAVE_DARWIN_OS
boost_TARGET := macosx
else
ifdef HAVE_BSD
boost_TARGET := freebsd
endif
endif
ifdef HAVE_SOLARIS
ifeq ($(ARCH),x86_64)
boost_TARGET := solaris-64bit
else
boost_TARGET := solaris-32bit
endif
endif

boost_EXTRA_CFLAGS := $(EXTRA_CFLAGS) -fexceptions

boost: boost-$(BOOST_HASH).tar.xz .sum-boost
	rm -Rf boost
	$(UNPACK)
	mv boost-$(BOOST_HASH) boost
	chmod -R u+w boost
	touch $@

.boost: boost
	mkdir -p -- "$(PREFIX)/lib" "$(PREFIX)/include"
	cp -r $</boost "$(PREFIX)/include/"

	touch $@
