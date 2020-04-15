#!/bin/sh

export TOP_LEVEL=$(pwd)

#############
# FUNCTIONS #
#############

checkfail()
{
    if [ ! $? -eq 0 ];then
        echo "$1"
        exit 1
    fi
}


# Make in //
if [ -z "$MAKEFLAGS" ]; then
    UNAMES=$(uname -s)
    MAKEFLAGS=
    if which nproc >/dev/null; then
        MAKEFLAGS=-j`nproc`
    elif [ "$UNAMES" == "Darwin" ] && which sysctl >/dev/null; then
        MAKEFLAGS=-j`sysctl -n machdep.cpu.thread_count`
    fi
fi


###########################
# Build buildsystem tools #
###########################

export PATH="`pwd`/extras/tools/build/bin:$PATH"
echo "Building tools"
cd extras/tools
./bootstrap
checkfail "buildsystem tools: bootstrap failed"
make $MAKEFLAGS
checkfail "buildsystem tools: make failed"
make $MAKEFLAGS .gas || make $MAKEFLAGS .buildgas
checkfail "buildsystem tools: make failed"
cd ../..


#############
# BOOTSTRAP #
#############
if [ ! -f configure ]; then
    echo "Bootstraping"
    ./bootstrap
    checkfail "vlc: bootstrap failed"
fi


#############################
# Get third-party libraries #
#############################

# Use VLC boostrap arguments from VLC for Android
VLC_BOOTSTRAP_ARGS="\
--disable-a52 \
--enable-aom \
--enable-aribb24 \
--disable-aribb25 \
--disable-asdcplib \
--enable-ass \
--enable-bitstream \
--disable-bluray \
--enable-boost \
--disable-bpg \
--disable-breakpad \
--disable-caca \
--disable-cddb \
--disable-chromaprint \
--disable-crystalhd \
--disable-daala \
--enable-dav1d \
--disable-dca
--disable-directx \
--disable-dshow \
--enable-dvbpsi \
--disable-dvdcss \
--disable-dvdnav \
--disable-dvdread \
--disable-dxvahd \
--disable-ebml \
--enable-faad2 \
--disable-ffi \
--enable-ffmpeg \
--enable-flac \
--disable-fluid \
--disable-fluidlite \
--disable-fontconfig \
--enable-freetype2 \
--disable-fribidi \
--disable-fxc2 \
--disable-gcrypt \
--disable-gettext \
--enable-glew \
--disable-glib \
--disable-glslang \
--disable-gme \
--enable-gmp \
--enable-gnutls \
--disable-goom \
--disable-gpg-error \
--disable-gsm \
--disable-harfbuzz \
--disable-iconv \
--disable-jack \
--disable-jpeg \
--disable-kate \
--disable-lame \
--disable-libarchive \
--disable-libdsm \
--enable-libmpeg2 \
--disable-libplacebo \
--enable-libtasn1 \
--disable-libxml2 \
--enable-live555 \
--disable-lua \
--disable-luac \
--enable-mad \
--disable-matroska \
--disable-medialibrary \
--disable-mfx \
--disable-microdns \
--disable-modplug \
--disable-mpcdec \
--enable-mpg123 \
--disable-mysofa \
--disable-ncurses \
--enable-nettle \
--disable-nfs \
--disable-nvcodec \
--enable-ogg \
--disable-openjpeg \
--enable-opus \
--enable-orc \
--disable-png \
--disable-postproc \
--disable-projectM \
--disable-protobuf \
--disable-pthreads \
--disable-pthread-stubs \
--disable-qt \
--disable-qtdeclarative \
--disable-qtgraphicaleffects \
--disable-qtquickcontrols2 \
--disable-qtsvg \
--enable-raptor \
--enable-raptorrtp \
--enable-regex \
--disable-samplerate \
--enable-schroedinger \
--disable-sdl \
--disable-SDL_image \
--disable-shout \
--disable-sidplay2 \
--disable-smb2 \
--disable-soxr \
--disable-sparkle \
--disable-spatialaudio \
--disable-speex \
--disable-speexdsp \
--disable-sqlite \
--disable-srt \
--disable-ssh2 \
--enable-taglib \
--enable-theora \
--disable-tiff \
--disable-tiger \
--disable-tremor \
--disable-twolame \
--disable-upnp \
--disable-vncclient \
--disable-vorbis \
--disable-vorbisenc \
--enable-vpx \
--disable-wine-headers \
--disable-x264 \
--disable-x26410b \
--disable-x265 \
--disable-xau \
--disable-xcb"

###########################
# VLC CONFIGURE ARGUMENTS #
###########################

VLC_CONFIGURE_ARGS="\
  --disable-dbus \
  --disable-sout \
  --disable-lua \
  --enable-archive \
  --enable-live555 \
  --disable-dc1394 \
  --disable-dv1394 \
  --disable-linsys \
  --disable-dvdread \
  --disable-dvdnav \
  --disable-bluray \
  --disable-opencv \
  --disable-smbclient \
  --disable-dsm \
  --disable-sftp \
  --disable-nfs \
  --disable-smb2 \
  --disable-v4l2 \
  --disable-nvdec \
  --disable-decklink \
  --disable-vcd \
  --disable-libcddb \
  --disable-screen \
  --disable-vnc \
  --disable-freerdp \
  --disable-asdcp \
  --enable-dvbpsi \
  --disable-gme \
  --disable-sid \
  --enable-ogg \
  --disable-shout \
  --disable-matroska \
  --disable-mod \
  --disable-mpc \
  --disable-shine \
  --disable-omxil \
  --disable-rpi-omxil \
  --disable-crystalhd \
  --enable-mad \
  --enable-mpg123 \
  --disable-gst-decode \
  --disable-merge-ffmpeg \
  --enable-avcodec \
  --enable-libva \
  --disable-dxva2 \
  --disable-d3d11va \
  --enable-avformat \
  --enable-swscale \
  --disable-postproc \
  --enable-faad \
  --enable-aom \
  --enable-dav1d \
  --enable-vpx \
  --disable-twolame \
  --disable-fdkaac \
  --disable-a52 \
  --disable-dca \
  --enable-flac \
  --enable-libmpeg2 \
  --disable-vorbis \
  --disable-tremor \
  --disable-speex \
  --enable-opus \
  --disable-spatialaudio \
  --enable-theora \
  --disable-oggspots \
  --disable-daala \
  --enable-schroedinger \
  --disable-png \
  --disable-jpeg \
  --disable-bpg \
  --disable-x262 \
  --disable-x265 \
  --disable-x264 \
  --disable-x26410b \
  --disable-mfx \
  --disable-fluidsynth \
  --disable-fluidlite \
  --enable-zvbi \
  --disable-telx \
  --enable-aribsub \
  --disable-aribb25 \
  --disable-kate \
  --disable-tiger \
  --disable-css \
  --disable-libplacebo \
  --disable-gles2 \
  --disable-vulkan \
  --disable-xcb \
  --enable-vdpau \
  --disable-wayland \
  --disable-sdl-image \
  --enable-freetype \
  --disable-fribidi \
  --disable-harfbuzz \
  --disable-fontconfig \
  --enable-libass \
  --disable-svg \
  --disable-svgdec \
  --disable-directx \
  --disable-kms \
  --disable-caca \
  --disable-kva \
  --disable-mmal \
  --enable-pulse \
  --enable-alsa \
  --disable-oss \
  --disable-sndio \
  --disable-wasapi \
  --disable-jack \
  --disable-opensles \
  --disable-samplerate \
  --disable-soxr \
  --disable-kai \
  --disable-chromaprint \
  --disable-chromecast \
  --disable-qt \
  --disable-qt-qml-cache \
  --disable-qt-qml-debug \
  --disable-skins2 \
  --disable-libtar \
  --disable-macosx \
  --disable-sparkl \
  --disable-minimal-macosx \
  --disable-ncurses \
  --disable-lirc \
  --disable-srt \
  --disable-goom \
  --disable-projectm \
  --disable-vsxu \
  --disable-avahi \
  --disable-udev \
  --disable-mtp \
  --disable-upnp \
  --disable-microdns \
  --disable-libxml2 \
  --enable-libgcrypt \
  --enable-gnutls \
  --enable-taglib \
  --disable-secret \
  --disable-kwallet \
  --disable-update-check \
  --disable-osx-notifications \
  --disable-notify \
  --disable-medialibrary \
  --disable-vlc --disable-shared"

EXTRA_CFLAGS="${EXTRA_CFLAGS} -fpic"
EXTRA_CXXFLAGS="${EXTRA_CXXFLAGS} -fexceptions -frtti"
EXTRA_CXXFLAGS="${EXTRA_CXXFLAGS} -D__STDC_FORMAT_MACROS=1 -D__STDC_CONSTANT_MACROS=1 -D__STDC_LIMIT_MACROS=1"


cd contrib
mkdir native
cd native
../bootstrap ${VLC_BOOTSTRAP_ARGS}

echo "EXTRA_CFLAGS=${EXTRA_CFLAGS}" >> config.mak
echo "EXTRA_CXXFLAGS=${EXTRA_CXXFLAGS}" >> config.mak
echo "EXTRA_LDFLAGS=${EXTRA_LDFLAGS}" >> config.mak


# use BUILD_ALL=1 to force download of all required libraries even if installed with distribution
#make list BUILD_ALL=1
make $MAKEFLAGS


###############
# compile VLC #
###############

# Debug build options:
#--enable-debug --disable-optimizations CFLAGS="-g -Og" CXXFLAGS="-g -Og"

cd $TOP_LEVEL
./configure ${VLC_CONFIGURE_ARGS}
make $MAKEFLAGS
