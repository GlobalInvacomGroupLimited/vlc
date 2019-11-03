#!/bin/sh

export CFLAGS="-I/opt/vc/include/ -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include/interface/mmal -I/opt/vc/include/interface/vchiq_arm -I/opt/vc/include/IL -I/opt/vc/include/GLES2 -mfloat-abi=hard -mcpu=cortex-a7 -mfpu=neon-vfpv4 -DNDEBUG"
export GLES2_CFLAGS="-I/opt/vc/include/ -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include/interface/mmal -I/opt/vc/include/interface/vchiq_arm -I/opt/vc/include/IL -I/opt/vc/include/GLES2"
export CXXFLAGS="-I/opt/vc/include/ -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include/interface/mmal -I/opt/vc/include/interface/vchiq_arm -I/opt/vc/include/IL -mfloat-abi=hard -I/opt/vc/include/GLES2 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -DNDEBUG"

export LDFLAGS="-L/opt/vc/lib"
export GLES2_LIBS="-L/opt/vc/lib"

EXTRA_CFLAGS="-DNDEBUG "


avlc_checkfail()
{
    if [ ! $? -eq 0 ];then
        echo "$1"
        exit 1
    fi
}



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


VLC_BOOTSTRAP_ARGS="\
    --disable-disc \
    --disable-dca \
    --disable-goom \
    --disable-chromaprint \
    --disable-schroedinger \
    --disable-sdl \
    --disable-SDL_image \
    --disable-fontconfig \
    --disable-kate \
    --disable-caca \
    --disable-gettext \
    --disable-mpcdec \
    --disable-gme \
    --disable-tremor \
    --disable-sidplay2 \
    --disable-samplerate \
    --disable-faad2 \
    --disable-aribb24 \
    --disable-aribb25 \
    --disable-libmpeg2 \
    --disable-mad \
    --disable-vncclient \
    --disable-vnc \
    --disable-srt \
    --disable-x265 \
    --disable-medialibrary \
    --disable-lua"

###########################
# VLC CONFIGURE ARGUMENTS #
###########################

VLC_CONFIGURE_ARGS="\
    --with-pic \
    --disable-nls \
    --enable-live555 --enable-realrtsp \
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
    --disable-lua \
    --disable-vcd \
    --disable-v4l2 \
    --disable-dvdread \
    --disable-dvdnav \
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
    --disable-fluidsynth \
    --disable-fluidlite \
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
    --enable-gles2 \
    --disable-goom \
    --disable-projectm \
    --enable-sout \
    --enable-vorbis \
    --disable-faad \
    --disable-schroedinger \
    --disable-vnc \
    --enable-jpeg \
    --enable-smb2 \
"

########################
# VLC MODULE BLACKLIST #
########################

VLC_MODULE_BLACKLIST="
    addons.*
    stats
    access_(bd|shm|imem)
    oldrc
    real
    hotkeys
    gestures
    sap
    dynamicoverlay
    rss
    ball
    audiobargraph_[av]
    clone
    mosaic
    osdmenu
    puzzle
    mediadirs
    t140
    ripple
    motion
    sharpen
    grain
    posterize
    mirror
    wall
    scene
    blendbench
    psychedelic
    alphamask
    netsync
    audioscrobbler
    motiondetect
    motionblur
    export
    smf
    podcast
    bluescreen
    erase
    stream_filter_record
    speex_resampler
    remoteosd
    magnify
    gradient
    dtstofloat32
    logger
    visual
    fb
    aout_file
    yuv
    .dummy
"



###########################
# Build buildsystem tools #
###########################

VLC_SRC_DIR=$PWD

export PATH="$VLC_SRC_DIR/extras/tools/build/bin:$PATH"
echo "Building tools"
cd $VLC_SRC_DIR/extras/tools
./bootstrap
avlc_checkfail "buildsystem tools: bootstrap failed"
make -j3
avlc_checkfail "buildsystem tools: make failed"
make -j3 .	gas || make -j3 .buildgas		
avlc_checkfail "buildsystem tools: make failed"
cd $VLC_SRC_DIR





cd contrib
mkdir -p native
cd native
../bootstrap --disable-chromaprint --enable-dvbpsi ${VLC_BOOTSTRAP_ARGS}

echo "EXTRA_CFLAGS=${EXTRA_CFLAGS}" >> config.mak

# use BUILD_ALL=1 to force download of all required libraries even if installed with distribution
make -j3 $BUILD_TAG


###############
# compile VLC #
###############		

# Debug build options:
#--enable-debug --disable-optimizations CFLAGS="-g -Og" CXXFLAGS="-g -Og"

cd $TOP_LEVEL
./configure --prefix=/usr --enable-omxil --enable-rpi-omxil --disable-mmal --enable-gles2 --enable-chromaprint=no --disable-wayland ${VLC_CONFIGURE_ARGS}
make -j3
