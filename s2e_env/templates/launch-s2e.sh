#!/bin/bash
#
# This file was automatically generated by s2e-env at {{ creation_time }}
#
# This script can be used to run the S2E analysis. Additional QEMU command line
# arguments can be passed to this script at run time
#

ENV_DIR="{{ env_dir }}"
INSTALL_DIR="$ENV_DIR/install"
BUILD_DIR="$ENV_DIR/build/s2e"
BUILD=debug

# Comment this out to enable QEMU GUI
GRAPHICS=-nographic

if [ "x$1" = "xdebug" ]; then
  DEBUG=1
  shift
fi

DRIVE="-drive file=$ENV_DIR/{{ rel_image_path }},format=s2e,cache=writeback"

export S2E_CONFIG=s2e-config.lua
export S2E_SHARED_DIR=$INSTALL_DIR/share/libs2e
export S2E_MAX_PROCESSES=1
export S2E_UNBUFFERED_STREAM=1

if [ "x$DEBUG" != "x" ]; then

if [ ! -d "$BUILD_DIR/qemu-$BUILD" ]; then
    echo "No debug build found in $BUILD_DIR/qemu-$BUILD. Please run \`\`s2e build -g\`\`"
    exit 1
fi

QEMU="$BUILD_DIR/qemu-$BUILD/{{ qemu_arch }}-softmmu/qemu-system-{{ qemu_arch }}"
LIBS2E="$BUILD_DIR/libs2e-$BUILD/{{ qemu_arch }}-s2e-softmmu/libs2e.so"

cat >> gdb.ini <<EOF
handle SIGUSR2 noprint
set disassembly-flavor intel
set print pretty on
set environment S2E_CONFIG=$S2E_CONFIG
set environment S2E_SHARED_DIR=$S2E_SHARED_DIR
set environment LD_PRELOAD=$LIBS2E
set environment S2E_UNBUFFERED_STREAM=1
#set environment QEMU_LOG_LEVEL=int,exec
#set environment S2E_QMP_SERVER=127.0.0.1:3322
EOF

GDB="gdb  --init-command=gdb.ini --args"

$GDB $QEMU $DRIVE \
    -k en-us $GRAPHICS -monitor null -m {{ qemu_memory }} -enable-kvm \
    -serial file:serial.txt {{ qemu_extra_flags }} \
    -loadvm {{ qemu_snapshot }} $*

else

QEMU="$INSTALL_DIR/bin/qemu-system-{{ qemu_arch }}"
LIBS2E="$INSTALL_DIR/share/libs2e/libs2e-{{ qemu_arch }}-s2e.so"

LD_PRELOAD=$LIBS2E $QEMU $DRIVE \
    -k en-us $GRAPHICS -monitor null -m {{ qemu_memory }} -enable-kvm \
    -serial file:serial.txt {{ qemu_extra_flags }} \
    -loadvm {{ qemu_snapshot }} $*

fi
