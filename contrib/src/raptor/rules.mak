# raptor

#raptor_FILE := raptor.2016.01.12.tar.gz
#raptorDOTCOM_URL := http://raptor.com/raptorMedia/public/$(raptor_FILE)
#raptorDOTCOM_URL := $(CONTRIB_VIDEOLAN)/raptor/$(raptor_FILE)
RAPTOR_URL     := git://sourcery/raptor.git

ifndef CHECKOUT_TAG
HASH=HEAD
else
HASH=$(CHECKOUT_TAG)
endif



ifdef BUILD_NETWORK
PKGS += raptor
endif


DEPS_raptor = boost $(DEPS_boost)


$(TARBALLS)/raptor-$(HASH).tar.xz:
	$(call download_git,$(RAPTOR_URL),master,$(HASH))


.sum-raptor: raptor-$(HASH).tar.xz
	$(warning Not implemented.)
	touch $@

raptor_TARGET = $(error raptor target not defined!)
ifdef HAVE_LINUX
raptor_TARGET := linux
endif
ifdef HAVE_WIN32
raptor_TARGET := mingw
endif
ifdef HAVE_DARWIN_OS
raptor_TARGET := macosx
else
ifdef HAVE_BSD
raptor_TARGET := freebsd
endif
endif
ifdef HAVE_SOLARIS
ifeq ($(ARCH),x86_64)
raptor_TARGET := solaris-64bit
else
raptor_TARGET := solaris-32bit
endif
endif

raptor_EXTRA_CFLAGS := $(EXTRA_CFLAGS) -fexceptions

raptor: raptor-$(HASH).tar.xz .sum-raptor
	rm -Rf raptor
	$(UNPACK)
	mv raptor-$(HASH) raptor
	chmod -R u+w raptor
	touch $@

.raptor: raptor
	cd raptor && $(HOSTVARS) ./autogen.sh
	cd raptor && $(HOSTVARS) ./configure $(HOSTCONF) --enable-static --disable-shared
	cd raptor && $(MAKE)
	cd raptor && $(MAKE) install
	touch $@
