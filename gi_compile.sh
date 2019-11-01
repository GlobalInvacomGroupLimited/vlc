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
    --disable-disc \
    --enable-dvdread \
    --enable-dvdnav \
    --disable-dca \
    --disable-goom \
    --disable-chromaprint \
    --disable-schroedinger \
    --disable-sdl \
    --disable-SDL_image \
    --disable-fontconfig \
    --enable-zvbi \
    --disable-kate \
    --disable-caca \
    --disable-gettext \
    --disable-mpcdec \
    --disable-upnp \
    --disable-gme \
    --disable-tremor \
    --enable-vorbis \
    --disable-sidplay2 \
    --disable-samplerate \
    --disable-faad2 \
    --enable-harfbuzz \
    --enable-iconv \
    --disable-aribb24 \
    --disable-aribb25 \
    --enable-mpg123 \
    --disable-libdsm \
    --enable-libarchive \
    --disable-libmpeg2 \
    --enable-soxr \
    --enable-nfs \
    --enable-microdns \
    --disable-mad \
    --disable-vncclient \
    --disable-vnc \
    --enable-jpeg \
    --enable-libplacebo \
    --enable-ad-clauses \
    --disable-srt \
    --enable-vpx \
    --disable-x265 \
    --disable-medialibrary \
    --enable-dvbpsi
"

###########################
# VLC CONFIGURE ARGUMENTS #
###########################

VLC_CONFIGURE_ARGS="\
    --disable-nls \
    --enable-live555 \
    --enable-avformat \
    --enable-swscale \
    --enable-avcodec \
    --enable-opus \
    --enable-opensles \
    --enable-matroska \
    --enable-taglib \
    --enable-dvbpsi \
    --disable-vlc --disable-shared \
    --disable-update-check \
    --disable-vlm \
    --disable-dbus \
    --enable-lua \
    --disable-vcd \
    --disable-v4l2 \
    --disable-dvdread \
    --enable-dvdnav \
    --disable-bluray \
    --disable-linsys \
    --disable-decklink \
    --disable-libva \
    --disable-dv1394 \
    --enable-mod \
    --disable-sid \
    --disable-gme \
    --disable-tremor \
    --disable-mad \
    --enable-mpg123 \
    --disable-dca \
    --disable-sdl-image \
    --enable-zvbi \
    --disable-jack \
    --disable-pulse \
    --disable-alsa \
    --disable-samplerate \
    --disable-xcb \
    --disable-qt \
    --disable-skins2 \
    --disable-mtp \
    --disable-notify \
    --enable-libass \
    --disable-svg \
    --disable-udev \
    --enable-libxml2 \
    --disable-caca \
    --disable-goom \
    --disable-projectm \
    --enable-sout \
    --enable-vorbis \
    --disable-faad \
    --disable-schroedinger \
    --disable-vnc \
    --enable-jpeg \
    --enable-chromaprint=no \
    --disable-wayland
"

EXTRA_CFLAGS="${EXTRA_CFLAGS} -fpic"
EXTRA_CXXFLAGS="${EXTRA_CXXFLAGS} -fexceptions -frtti"
EXTRA_CXXFLAGS="${EXTRA_CXXFLAGS} -D__STDC_FORMAT_MACROS=1 -D__STDC_CONSTANT_MACROS=1 -D__STDC_LIMIT_MACROS=1"


cd contrib
mkdir native
cd native
../bootstrap --disable-chromaprint --enable-dvbpsi ${VLC_BOOTSTRAP_ARGS}

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
./configure --enable-chromaprint=no --disable-wayland ${VLC_CONFIGURE_ARGS}
make $MAKEFLAGS
