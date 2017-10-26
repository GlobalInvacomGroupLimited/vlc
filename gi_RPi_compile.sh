#!/bin/sh

export CFLAGS="-I/opt/vc/include/ -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include/interface/mmal -I/opt/vc/include/interface/vchiq_arm -I/opt/vc/include/IL -I/opt/vc/include/GLES2 -mfloat-abi=hard -mcpu=cortex-a7 -mfpu=neon-vfpv4"

export CXXFLAGS="-I/opt/vc/include/ -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include/interface/mmal -I/opt/vc/include/interface/vchiq_arm -I/opt/vc/include/IL -mfloat-abi=hard -I/opt/vc/include/GLES2 -mcpu=cortex-a7 -mfpu=neon-vfpv4"

export LDFLAGS="-L/opt/vc/lib"

while [ $# -gt 0 ]; do
    case $1 in
        help|--help|-h)
            echo "Use -t|--tag to fetch contrib sources with specific git tag"
            echo "  e.g --tag v0.00rc1"
            echo "  only libav,ffmpeg and postproc are available from sourcery"
            exit 0
            ;;
        -t|--tag)
            GIT_TAG=$2
            shift
            ;;
    esac
    shift
done

TOP_LEVEL=$(pwd)
BUILD_TAG=

if [ -v GIT_TAG ]; then
  # a git tag has been specified, check if vlc repo is on that tag
  GIT_LOCATION=$(git log --pretty=format:'%ad %h %d' --abbrev-commit --date=short -1)
  echo $GIT_LOCATION
  if [[ $GIT_LOCATION != *$GIT_TAG* ]]; then
    echo "tag $GIT_TAG not found - run git checkout $GIT_TAG first";
    exit 0
  else
    BUILD_TAG=CHECKOUT_TAG=$GIT_TAG
  fi
fi


#################
# bootstrap VLC #
#################
./bootstrap


#############################
# Get third-party libraries #
#############################

# All third party libraries are obtained from versioned tar archives from various repositories
# Except for libav/ffmpeg, postproc and x264
# libav/ffmpeg and postproc are originally obtained from the HEAD of git repos at git://git.videolan.org
# and have been changed to mirror repos on sourcery/redmine to enable tagging of specific version
# x264 still is obtained from an unversioned tar archive from ftp://ftp.videolan.org/pub/videolan/x264/snapshots/
# x264 is not needed, so this is left unchanged for now
# This means x264 sources are NOT tagged for now 


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
mkdir -p native
cd native
../bootstrap --disable-chromaprint --enable-dvbpsi #${VLC_BOOTSTRAP_ARGS}

# use BUILD_ALL=1 to force download of all required libraries even if installed with distribution
make $BUILD_TAG 


###############
# compile VLC #
###############

# Debug build options:
#--enable-debug --disable-optimizations CFLAGS="-g -Og" CXXFLAGS="-g -Og"

cd $TOP_LEVEL
./configure --prefix=/usr --enable-omxil --enable-omxil-vout --enable-rpi-omxil --disable-mmal --disable-mmal-codec --disable-mmal-vout --enable-gles2 --enable-chromaprint=no --disable-wayland
make
