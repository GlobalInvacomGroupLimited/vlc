# raptor

#raptor_FILE := raptor.2016.01.12.tar.gz
#raptorDOTCOM_URL := http://raptor.com/raptorMedia/public/$(raptor_FILE)
#raptorDOTCOM_URL := $(CONTRIB_VIDEOLAN)/raptor/$(raptor_FILE)
RAPTOR_URL     := https://github.com/GlobalInvacomGroupLimited/raptor.git

ifndef CHECKOUT_TAG
RAPTOR_HASH := 2f44e50290ea1fdd6822cd544ccf2cb760854a36
else
RAPTOR_HASH=$(CHECKOUT_TAG)
endif



ifdef BUILD_NETWORK
PKGS += raptor
endif


DEPS_raptor = boost $(DEPS_boost)


$(TARBALLS)/raptor-$(RAPTOR_HASH).tar.xz:
	$(call download_git,$(RAPTOR_URL),master,$(RAPTOR_HASH))


.sum-raptor: raptor-$(RAPTOR_HASH).tar.xz
	$(call check_githash,$(RAPTOR_HASH))
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

raptor: raptor-$(RAPTOR_HASH).tar.xz .sum-raptor
	rm -Rf raptor
	$(UNPACK)
	mv raptor-$(RAPTOR_HASH) raptor
	chmod -R u+w raptor
	touch $@

.raptor: raptor
	cd raptor && $(HOSTVARS) ./autogen.sh
	cd raptor && $(HOSTVARS) ./configure $(HOSTCONF) --enable-static --disable-shared
	cd raptor && $(MAKE)
	cd raptor && $(MAKE) install
	touch $@
