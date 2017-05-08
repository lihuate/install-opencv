#!/bin/sh
#
# Created on February 21, 2017
#
# @author: sgoldsmith
#
# Make sure you change this before running any script!
#
# Tested configs:
#
# x86 generic (no GPU/VPU optimizations)
#
# If you get SSSE3 - NOT AVAILABLE error add -DENABLE_SSSE3=OFF
#
# extracflag=""
# cmakeopts="-DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DWITH_QT=OFF -DWITH_GTK=OFF -DWITH_TBB=ON -DBUILD_TBB=ON"
#
# OpenCV 3.2 detects NEON, so we leave that out
#
# CHIP R8 - TBB build failed, so we use built in one
#
# extracflag="-mtune=cortex-a8 -mfloat-abi=hard"
# cmakeopts="-DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DWITH_QT=OFF -DWITH_GTK=OFF -DWITH_TBB=ON -DBUILD_TBB=OFF -DENABLE_NEON=ON"
#
# Pine64 - Carotene fails with "conflicts with asm clobber list", so we disable
#
# extra_c_flag="-mtune=cortex-a53"
# cmakeopts="-DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DWITH_QT=OFF -DWITH_GTK=OFF -DWITH_TBB=ON -DBUILD_TBB=ON -DWITH_CAROTENE=OFF"
#
# Steven P. Goldsmith
# sgjava@gmail.com
# 

# Get architecture
arch=$(uname -m)

# Temp dir for downloads, etc.
tmpdir="$HOME/temp"

# Build home
buildhome="$HOME"

# OpenCV extra cflags
extracflag=""

# Custom cmake options
cmakeopts="-DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DWITH_QT=OFF -DWITH_GTK=OFF -DWITH_TBB=ON -DBUILD_TBB=ON"

# Change to False if you get a white image in mjpg-streamer
whitepatch="True"

# Oracle JDK
javahome=/usr/lib/jvm/jdk1.8.0

# Patch OpenCV Java code to fix memory leaks and performance issues.
# See https://github.com/sgjava/opencvmem for details
patchjava="False"

# Make sure we support architecture
if [ "$arch" = "i586" ] || [ "$arch" = "i686" ] || [ "$arch" = "armv7l" ] || [ "$arch" = "aarch64" ] || [ "$arch" = "x86_64" ]; then
	echo "\nArchitecture supported."
# Not supported
else
	echo "\nNo supported architectures detected!"
	exit 1
fi
