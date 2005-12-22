#!/bin/sh
#
# Copyright (C) 2004-2005 Nokia Corporation.

AF_PIDDIR=/tmp/af-piddir
if [ ! -d $AF_PIDDIR ]; then
	# note, no write to flash involved here
	mkdir $AF_PIDDIR
	# I'm not the only one writing here
	chmod 777 $AF_PIDDIR
fi
PIDFILE=$AF_PIDDIR/fb-progress.pid
IMGDIR=/usr/share/icons/hicolor/scalable/hildon
LOGO=qgn_indi_startup_nokia_logo.png
BAR=qgn_indi_progressbar.png

# is link/init file name of the format 'fb-progress-<secs>'?
SECS=${0#*fb-progress-}
if [ "$SECS" = "$0" ]; then
	# no match, use the default progress timeout
	SECS=20
fi

case "$1" in
start)	
	# don't show progress bar if device started to ACTDEAD first
        BOOTREASON=`cat /proc/bootreason`
        if [ "x$BOOTREASON" != "xcharger" \
	     -a ! -f /tmp/skip-fb-progress.tmp ]; then
        	echo "Starting: fb-progress"
        	fb-progress -l $IMGDIR/$LOGO -g $IMGDIR/$BAR $SECS &
        	echo "$!" > $PIDFILE
        	chmod 666 $PIDFILE
	fi
        rm -f /tmp/skip-fb-progress.tmp
	;;
stop)	if [ -f $PIDFILE ]; then
		PID=$(cat $PIDFILE)
		if [ -d /proc/$PID ]; then
			kill -TERM $PID
		fi
		rm $PIDFILE
	fi
        # this is for the case of USER -> ACTDEAD -> USER
        touch /tmp/skip-fb-progress.tmp
	;;
restart)
	echo "$0: not implemented"
	exit 1
	;;
force-reload)
	echo "$0: not implemented"
	exit 1
	;;
*)	echo "Usage: $0 {start|stop}"
	exit 1
	;;
esac
