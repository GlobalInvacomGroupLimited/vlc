# raptorrtp


RAPTOR_RTP_GI_URL     := https://github.com/GlobalInvacomGroupLimited/raptorrtp.git

ifndef CHECKOUT_TAG
RAPTORRTP_HASH := 72627d995c3947de5458391a671b55677731c1a1
else
RAPTORRTP_HASH := $(CHECKOUT_TAG)
endif



ifdef BUILD_NETWORK
PKGS += raptorrtp
endif

DEPS_raptorrtp = raptor $(DEPS_raptor)

$(TARBALLS)/raptorrtp-$(RAPTORRTP_HASH).tar.xz:
	$(call download_git,$(RAPTOR_RTP_GI_URL),master,$(RAPTORRTP_HASH))
#	$(call download,$(LIVEDOTCOM_URL))

.sum-raptorrtp: raptorrtp-$(RAPTORRTP_HASH).tar.xz
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

raptorrtp: raptorrtp-$(RAPTORRTP_HASH).tar.xz .sum-raptorrtp
	rm -Rf raptorrtp
	$(UNPACK)
	mv raptorrtp-$(RAPTORRTP_HASH) raptorrtp
	chmod -R u+w raptorrtp
	touch $@

.raptorrtp: raptorrtp
	cd raptorrtp && $(HOSTVARS) ./autogen.sh
	cd raptorrtp && $(HOSTVARS) ./configure $(HOSTCONF) --with-liveMedia=$(PREFIX)/include/liveMedia \
                                                            --with-BasicUsageEnvironment=$(PREFIX)/include/BasicUsageEnvironment \
                                                            --with-groupsock=$(PREFIX)/include/groupsock \
                                                            --with-UsageEnvironment=$(PREFIX)/include/UsageEnvironment \
                                                            --enable-static --disable-shared --enable-logging
	cd raptorrtp && $(MAKE)
	cd raptorrtp && $(MAKE) install
	touch $@
