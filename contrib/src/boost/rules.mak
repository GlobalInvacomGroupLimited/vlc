# boost

BOOST_VERSION := 1.63.0
BOOST_TAR     := 1_63_0
BOOST_URL     := https://sourceforge.net/projects/boost/files/boost/$(BOOST_VERSION)/boost_$(BOOST_TAR).tar.gz


ifdef BUILD_NETWORK
PKGS += boost
endif

$(TARBALLS)/boost_$(BOOST_TAR).tar.gz:
	$(call download_pkg,$(BOOST_URL),boost)


.sum-boost: boost_$(BOOST_TAR).tar.gz
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

boost: boost_$(BOOST_TAR).tar.gz .sum-boost
	rm -Rf boost
	$(UNPACK)
	mv boost_$(BOOST_TAR) boost
	chmod -R u+w boost
	touch $@

.boost: boost
	mkdir -p -- "$(PREFIX)/lib" "$(PREFIX)/include"
	cp -r $</boost "$(PREFIX)/include/"

	touch $@
