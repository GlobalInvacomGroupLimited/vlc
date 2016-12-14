# raptorrtp


RAPTOR_RTP_GI_URL     := ssh://git@sourcery/redmine/vsat-ip/raptorrtp.git

ifndef CHECKOUT_TAG
HASH=HEAD
else
HASH=$(CHECKOUT_TAG)
endif



ifdef BUILD_NETWORK
PKGS += raptorrtp
endif

DEPS_raptorrtp = raptor $(DEPS_raptor)

$(TARBALLS)/raptorrtp-$(HASH).tar.xz:
	$(call download_git,$(RAPTOR_RTP_GI_URL),master,$(HASH))
#	$(call download,$(LIVEDOTCOM_URL))

.sum-raptorrtp: raptorrtp-$(HASH).tar.xz
	$(warning Not implemented.)
	touch $@

RAPTOR_RTP_TARGET = $(error live555 target not defined!)
ifdef HAVE_LINUX
 RAPTOR_RTP_TARGET := linux
endif
ifdef HAVE_WIN32
 RAPTOR_RTP_TARGET := mingw
endif
ifdef HAVE_DARWIN_OS
 RAPTOR_RTP_TARGET := macosx
else
ifdef HAVE_BSD
 RAPTOR_RTP_TARGET := freebsd
endif
endif
ifdef HAVE_SOLARIS
ifeq ($(ARCH),x86_64)
 RAPTOR_RTP_TARGET := solaris-64bit
else
 RAPTOR_RTP_TARGET := solaris-32bit
endif
endif

RAPTOR_RTP_EXTRA_CFLAGSEXTRA_CFLAGS := $(EXTRA_CFLAGS) -fexceptions

raptorrtp: raptorrtp-$(HASH).tar.xz .sum-raptorrtp
	rm -Rf raptorrtp
	$(UNPACK)
	mv raptorrtp-$(HASH) raptorrtp
	chmod -R u+w raptorrtp
	touch $@

.raptorrtp: raptorrtp
	cd raptorrtp && $(HOSTVARS) ./autogen.sh
	cd raptorrtp && $(HOSTVARS) ./configure $(HOSTCONF) --enable-static --disable-shared --enable-logging
	cd raptorrtp && $(MAKE)
	cd raptorrtp && $(MAKE) install
	touch $@
