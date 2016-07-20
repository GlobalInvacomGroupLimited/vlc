#!/bin/sh

export TOP_LEVEL=$(pwd)


#################
# bootstrap VLC #
#################
./bootstrap


#############################
# Get third-party libraries #
#############################

# Use VLC boostrap arguments from VLC for Android
VLC_BOOTSTRAP_ARGS="\
    --disable-disc \
    --disable-sout \
    --enable-dvdread \
    --enable-dvdnav \
    --disable-dca \
    --disable-goom \
    --disable-chromaprint \
    --disable-lua \
    --disable-schroedinger \
    --disable-sdl \
    --disable-SDL_image \
    --disable-fontconfig \
    --enable-zvbi \
    --disable-kate \
    --disable-caca \
    --disable-gettext \
    --disable-mpcdec \
    --enable-upnp \
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
    --enable-libdsm \
    --enable-libarchive \
    --disable-libmpeg2 \
    --enable-soxr \
    --disable-libnfs \
    --disable-nfs \
"

cd contrib
mkdir native
cd native
../bootstrap --disable-chromaprint --enable-dvbpsi #${VLC_BOOTSTRAP_ARGS}

# use BUILD_ALL=1 to force download of all required libraries even if installed with distribution
#make list BUILD_ALL=1
make BUILD_ALL=1


###############
# compile VLC #
###############

cd $TOP_LEVEL
./configure --enable-chromaprint=no
make


