#!/bin/bash
### BEGIN INIT INFO
# Provides:          blackweb
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       blackweb for Squid
# by:	             maravento.com, novatoz.com
### END INIT INFO

blw=/etc/acl # destination_folder_to_store_blackweb (e.g: /etc/acl)

if [ ! -d $blw ]; then mkdir -p $blw; fi
wget -c https://github.com/maravento/blackweb/raw/master/blackweb.tar.gz
wget -c https://github.com/maravento/blackweb/raw/master/blackweb.md5

echo "Checking Sum..."
a=$(md5sum blackweb.tar.gz | awk '{print $1}')
b=$(cat blackweb.md5 | awk '{print $1}')
	if [ "$a" = "$b" ]
	then 
		echo "Sum Matches"
		tar -C $blw -xvzf blackweb.tar.gz
		date=`date +%d/%m/%Y" "%H:%M:%S`
		echo "Blackweb for Squid: Done $date" >> /var/log/syslog
		rm -rf blackweb*
		echo "OK"
	else
		echo "Bad Sum. Abort"
		date=`date +%d/%m/%Y" "%H:%M:%S`
		echo "Blackweb for Squid: Abort $date Check Internet Connection" >> /var/log/syslog
		rm -rf blackweb*
		exit
fi
