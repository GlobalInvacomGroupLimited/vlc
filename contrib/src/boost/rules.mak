# boost

#boost_FILE := boost.2016.01.12.tar.gz
#boostDOTCOM_URL := http://boost.com/boostMedia/public/$(boost_FILE)
#boostDOTCOM_URL := $(CONTRIB_VIDEOLAN)/boost/$(boost_FILE)
BOOST_URL     := git://sourcery/libraries/boost.git

ifndef CHECKOUT_TAG
HASH=HEAD
else
HASH=$(CHECKOUT_TAG)
endif



ifdef BUILD_NETWORK
PKGS += boost
endif

$(TARBALLS)/boost-$(HASH).tar.xz:
	$(call download_git,$(BOOST_URL),master,$(HASH))


.sum-boost: boost-$(HASH).tar.xz
	$(warning Not implemented.)
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

boost: boost-$(HASH).tar.xz .sum-boost
	rm -Rf boost
	$(UNPACK)
	mv boost-$(HASH) boost
	chmod -R u+w boost
	touch $@

.boost: boost
	mkdir -p -- "$(PREFIX)/lib" "$(PREFIX)/include"
	cp -r $</boost "$(PREFIX)/include/"

	touch $@
