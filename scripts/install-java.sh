#!/bin/sh
#
# Created on January 31, 2017
#
# @author: sgoldsmith
#
# Install and configure Oracle JDK 8 and Apache Ant for Debian Jessie on CHIP.
# If JDK or Ant was already installed with this script then they will be
# replaced.
#
# This should work on other ARM based systems with similar architecture and
# Ubuntu as well.
#
# Steven P. Goldsmith
# sgjava@gmail.com
# 

# Get start time
dateformat="+%a %b %-eth %Y %I:%M:%S %p %Z"
starttime=$(date "$dateformat")
starttimesec=$(date +%s)

# Get current directory
curdir=$(cd `dirname $0` && pwd)

# Source config file
. "$curdir"/config.sh

# JDK archive stuff

jdkurl="http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/"
jdkver="jdk1.8.0_181"
# ARM 32
if [ "$arch" = "armv7l" ]; then
	jdkarchive="jdk-8u181-linux-arm32-vfp-hflt.tar.gz"
# ARM 64
elif [ "$arch" = "aarch64" ]; then
	jdkarchive="jdk-8u181-linux-arm64-vfp-hflt.tar.gz"
# X86
elif [ "$arch" = "i586" ] || [ "$arch" = "i686" ]; then
	jdkarchive="jdk-8u181-linux-i586.tar.gz"
# X86_64	
elif [ "$arch" = "x86_64" ]; then
	jdkarchive="jdk-8u181-linux-x64.tar.gz"
fi

# Apache Ant
anturl="https://www.apache.org/dist/ant/binaries/"
antarchive="apache-ant-1.10.5-bin.tar.gz"
antver="apache-ant-1.10.5"
anthome="/opt/ant"
antbin="/opt/ant/bin"

# stdout and stderr for commands logged
logfile="$curdir/install-java.log"
rm -f $logfile

# Simple logger
log(){
	timestamp=$(date +"%m-%d-%Y %k:%M:%S")
	echo "$timestamp $1"
	echo "$timestamp $1" >> $logfile 2>&1
}

log "Installing Java..."

# Remove temp dir
log "Removing temp dir $tmpdir"
rm -rf "$tmpdir" >> $logfile 2>&1
mkdir -p "$tmpdir" >> $logfile 2>&1

# Install Oracle Java JDK
log "Downloading $jdkarchive to $tmpdir"
wget --directory-prefix=$tmpdir --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$jdkurl$jdkarchive" >> $logfile 2>&1
log "Extracting $jdkarchive to $tmpdir"
tar -xf "$tmpdir/$jdkarchive" -C "$tmpdir" >> $logfile 2>&1
log "Removing $javahome"
rm -rf "$javahome" >> $logfile 2>&1
mkdir -p /usr/lib/jvm >> $logfile 2>&1
log "Moving $tmpdir/$jdkver to $javahome"
mv "$tmpdir/$jdkver" "$javahome" >> $logfile 2>&1
update-alternatives --quiet --install "/usr/bin/java" "java" "$javahome/bin/java" 1 >> $logfile 2>&1
update-alternatives --quiet --install "/usr/bin/javac" "javac" "$javahome/bin/javac" 1 >> $logfile 2>&1
# See if JAVA_HOME exists and if not add it to /etc/environment
if grep -q "JAVA_HOME" /etc/environment; then
	log "JAVA_HOME already exists"
else
	# Add JAVA_HOME to /etc/environment
	log "Adding JAVA_HOME to /etc/environment"
	echo "JAVA_HOME=$javahome" >> /etc/environment
	. /etc/environment
	log "JAVA_HOME = $JAVA_HOME"
fi

# Install latest ANT without all the junk from 'apt-get install ant'
log "Installing Ant $antver..."
log "Downloading $anturl$antarchive to $tmpdir     "
wget --directory-prefix=$tmpdir "$anturl$antarchive" >> $logfile 2>&1
log "Extracting $tmpdir/$antarchive to $tmpdir"
tar -xf "$tmpdir/$antarchive" -C "$tmpdir" >> $logfile 2>&1
log "Removing $anthome"
rm -rf "$anthome" >> $logfile 2>&1
# In case /opt doesn't exist
mkdir -p /opt >> $logfile 2>&1
log "Moving $tmpdir/$antver to $anthome"
mv "$tmpdir/$antver" "$anthome" >> $logfile 2>&1
# See if ANT_HOME exists and if not add it to /etc/environment
if grep -q "ANT_HOME" /etc/environment; then
	log "ANT_HOME already exists"
else
	# OpenCV make will not find ant by ANT_HOME, so create link to where it's looking
	ln -s "$antbin/ant" /usr/bin/ant >> $logfile 2>&1
	# Add ANT_HOME to /etc/environment
	log "Adding ANT_HOME to /etc/environment"
	echo "ANT_HOME=$anthome" >> /etc/environment
	. /etc/environment
	log "ANT_HOME = $ANT_HOME"
	log "PATH = $PATH"
fi

# Clean up
log "Removing $tmpdir"
rm -rf "$tmpdir" 

# Get end time
endtime=$(date "$dateformat")
endtimesec=$(date +%s)

# Show elapsed time
elapsedtimesec=$(expr $endtimesec - $starttimesec)
ds=$((elapsedtimesec % 60))
dm=$(((elapsedtimesec / 60) % 60))
dh=$((elapsedtimesec / 3600))
displaytime=$(printf "%02d:%02d:%02d" $dh $dm $ds)
log "Elapsed time: $displaytime"
