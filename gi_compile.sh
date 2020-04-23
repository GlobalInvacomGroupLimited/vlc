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
--disable-aom \
--disable-aribb24 \
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
--disable-disc \
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
--disable-gnutls \
--disable-goom \
--disable-gpg-error \
--disable-growl \
--disable-gsm \
--disable-harfbuzz \
--disable-iconv \
--disable-jack \
--disable-jpeg \
--disable-kate \
--disable-lame \
--disable-libarchive \
--disable-libdsm \
--disable-libmpeg2 \
--disable-libplacebo \
--enable-libtasn1 \
--disable-libxml2 \
--enable-live555 \
--disable-lua \
--disable-luac \
--disable-mad \
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
--disable-orc \
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
--disable-regex \
--disable-samplerate \
--disable-schroedinger \
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
--disable-vnc \
--disable-vncclient \
--disable-vncserver \
--disable-vorbis \
--disable-vorbisenc \
--enable-vpx \
--disable-wine-headers \
--disable-x264 \
--disable-x26410b \
--disable-x265 \
--disable-xau \
--disable-xcb \
--enable-zvbi "

###########################
# VLC CONFIGURE ARGUMENTS #
###########################

VLC_CONFIGURE_ARGS="\
--with-pic \
--disable-a52 \
--disable-addonmanagermodules \
--enable-alsa \
--disable-aom \
--disable-archive \
--disable-aribb25 \
--enable-aribsub \
--disable-asdcp \
--disable-avahi \
--enable-avcodec \
--enable-avformat \
--disable-bluray \
--disable-bpg \
--disable-caca \
--disable-chromaprint \
--disable-chromecast \
--disable-crystalhd \
--disable-css \
--disable-d3d11va \
--disable-daala \
--enable-dav1d \
--disable-dbus \
--disable-dc1394 \
--disable-dca \
--disable-decklink \
--disable-directx \
--disable-dsm \
--disable-dv1394 \
--enable-dvbpsi \
--disable-dvdnav \
--disable-dvdread \
--disable-dxva2 \
--enable-faad \
--disable-fdkaac \
--enable-flac \
--disable-fluidlite \
--disable-fluidsynth \
--disable-fontconfig \
--disable-freerdp \
--enable-freetype \
--disable-fribidi \
--disable-gles2 \
--disable-gme \
--disable-gnutls \
--disable-goom \
--disable-gst-decode \
--disable-harfbuzz \
--disable-jack \
--disable-jpeg \
--disable-kai \
--disable-kate \
--disable-kms \
--disable-kva \
--disable-kwallet \
--enable-libass \
--disable-libcddb \
--disable-libgcrypt \
--disable-libmpeg2 \
--disable-libplacebo \
--disable-libtar \
--enable-libva \
--disable-libxml2 \
--disable-linsys \
--disable-lirc \
--enable-live555 \
--disable-lua \
--disable-macosx \
--disable-macosx-avfoundation \
--disable-mad \
--enable-mmx \
--disable-matroska \
--disable-medialibrary \
--disable-merge-ffmpeg \
--disable-mfx \
--disable-microdns \
--disable-minimal-macosx \
--disable-mmal \
--disable-mod \
--disable-mpc \
--disable-mpg123 \
--disable-mtp \
--disable-ncurses \
--disable-nfs \
--disable-nls \
--disable-notify \
--disable-nvdec \
--enable-ogg \
--disable-oggspots \
--disable-omxil \
--disable-opencv \
--disable-opensles \
--enable-opus \
--disable-oss \
--disable-osx-notifications \
--disable-png \
--disable-postproc \
--disable-projectm \
--disable-pulse \
--disable-qt \
--disable-qt-qml-cache \
--disable-qt-qml-debug \
--disable-rpi-omxil \
--disable-samplerate \
--disable-schroedinger \
--disable-screen \
--disable-sdl-image \
--disable-secret \
--disable-sftp \
--disable-shine \
--disable-shout \
--disable-sid \
--disable-skins2 \
--disable-sparkle \
--enable-sse \
--disable-smb2 \
--disable-smbclient \
--disable-sndio \
--disable-sout \
--disable-soxr \
--disable-sparkl \
--disable-spatialaudio \
--disable-speex \
--disable-srt \
--disable-svg \
--disable-svgdec \
--enable-swscale \
--enable-taglib \
--disable-telx \
--enable-theora \
--disable-tiger \
--disable-tremor \
--disable-twolame \
--disable-udev \
--disable-update-check \
--disable-upnp \
--disable-v4l2 \
--disable-vcd \
--enable-vdpau \
--disable-vlc --disable-shared \
--disable-vlm \
--disable-vnc \
--disable-vorbis \
--enable-vpx \
--disable-vsxu \
--disable-vulkan \
--disable-wasapi \
--disable-wayland \
--disable-x262 \
--disable-x264 \
--disable-x26410b \
--disable-x265 \
--disable-xcb \
--enable-zvbi "

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
