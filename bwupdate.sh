#!/bin/bash
### BEGIN INIT INFO
# Provides:          blackweb update
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       blackweb for Squid
# by:	             maravento.com, novatoz.com
### END INIT INFO
# Language spa-eng
cm1=("Este proceso puede tardar mucho tiempo. Sea paciente..." "This process can take a long time. Be patient...")
cm2=("Verifique su conexion a internet y reinicie el script" "Check your internet connection and restart the script")
test "${LANG:0:2}" == "es"
es=$?

clear
echo
echo "Blackweb Project"
echo "${cm1[${es}]}"
echo
# PATH
bw=~/blackweb

# DEL OLD REPOSITORY
if [ -d $bw ]; then rm -rf $bw; fi

# GIT CLONE BLACLISTWEB
echo "Download Blackweb..."
git clone https://github.com/maravento/blackweb.git >/dev/null 2>&1
echo "OK"

# CREATE DIR
if [ ! -d $bw/bl ]; then mkdir -p $bw/bl; fi
if [ ! -d /etc/acl ]; then mkdir -p /etc/acl; fi

echo "Checking Sum..."
a=$(md5sum $bw/blackweb.tar.gz | awk '{print $1}')
b=$(cat $bw/blackweb.md5 | awk '{print $1}')
	if [ "$a" = "$b" ]
	then 
		echo "Sum Matches"
		cd $bw
		tar -C bl -xvzf blackweb.tar.gz >/dev/null 2>&1
		sed -e '/^#/d' blackurls.txt | sort -u >> bl/bls.txt
		echo "OK"
	else
		echo "Bad Sum. Abort"
		echo "${cm2[${es}]}"
		date=`date +%d/%m/%Y" "%H:%M:%S`
		echo "Blackweb for Squid: Abort $date Check Internet Connection" >> /var/log/syslog
		rm -rf $bw
		exit
fi

# DOWNLOAD BL
echo "Download Public Bls..."
cd $bw

function bldownload() {
    wget -q -c --retry-connrefused -t 0 "$1" -O - | sort -u >> bl/bls.txt
}
	bldownload 'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=nohtml' && sleep 1
	bldownload 'http://malwaredomains.lehigh.edu/files/justdomains' && sleep 1
	bldownload 'https://easylist-downloads.adblockplus.org/malwaredomains_full.txt' && sleep 1
	bldownload 'http://www.passwall.com/blacklist.txt' && sleep 1
	bldownload 'https://zeustracker.abuse.ch/blocklist.php?download=squiddomain' && sleep 1
	bldownload 'http://someonewhocares.org/hosts/hosts' && sleep 1
	bldownload 'http://winhelp2002.mvps.org/hosts.txt' && sleep 1
	bldownload 'https://raw.githubusercontent.com/oleksiig/Squid-BlackList/master/denied_ext.conf' && sleep 1
	bldownload 'http://www.joewein.net/dl/bl/dom-bl-base.txt' && sleep 1
	bldownload 'http://www.joewein.net/dl/bl/dom-bl.txt' && sleep 1
	bldownload 'http://www.malwaredomainlist.com/hostslist/hosts.txt' && sleep 1
	bldownload 'http://adaway.org/hosts.txt' && sleep 1
	bldownload 'https://openphish.com/feed.txt' && sleep 1
	bldownload 'http://cybercrime-tracker.net/all.php' && sleep 1
	bldownload 'https://ransomwaretracker.abuse.ch/downloads/RW_URLBL.txt' && sleep 1
	bldownload 'https://ransomwaretracker.abuse.ch/downloads/RW_DOMBL.txt' && sleep 1
	bldownload 'http://hosts-file.net/download/hosts.txt' && sleep 1
	bldownload 'http://osint.bambenekconsulting.com/feeds/dga-feed.txt' && sleep 1
	bldownload 'http://malc0de.com/bl/ZONES' && sleep 1

function blzip() {
    wget -q -c --retry-connrefused -t 0 "$1" && unzip -p domains.zip >> bl/bls.txt
}
	blzip 'http://www.malware-domains.com/files/domains.zip' && sleep 1

function bltar() {
    wget -q -c --retry-connrefused -t 0 "$1" && for F in *.tar.gz; do R=$RANDOM ; mkdir bl/$R ; tar -C bl/$R -zxvf $F -i; done >/dev/null 2>&1
}
	bltar 'http://www.shallalist.de/Downloads/shallalist.tar.gz' && sleep 2
	bltar 'http://dsi.ut-capitole.fr/blacklists/download/blacklists.tar.gz' && sleep 2

function blbig() {
    wget -q -c --retry-connrefused -t 0 "$1" -O bigblacklist.tar.gz && for F in bigblacklist.tar.gz; do R=$RANDOM ; mkdir bl/$R ; tar -C bl/$R -zxvf $F -i; done >/dev/null 2>&1
}
	blbig 'http://urlblacklist.com/cgi-bin/commercialdownload.pl?type=download&file=bigblacklist' && sleep 2

function blgz() {
    wget -q -c --retry-connrefused -t 0 "$1" && for F in *.tgz; do R=$RANDOM ; mkdir bl/$R ; tar -C bl/$R -zxvf $F -i; done >/dev/null 2>&1
}
	blgz 'http://squidguard.mesd.k12.or.us/blacklists.tgz' && sleep 2

echo "OK"

# DOWNLOAD TLDS
echo "Download Public TLDs..."
cd $bw

function iana() {
    wget -q -c --retry-connrefused -t 0 "$1" -O - | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' | sed -e '/^#/d' | sed 's/^/./' | sort -u >> ptlds.txt
}
	iana 'https://data.iana.org/TLD/tlds-alpha-by-domain.txt'

function suffix() {
    wget -q -c --retry-connrefused -t 0 "$1" -O - | grep -v "//" | grep -ve "^$" | sed 's:\(.*\):\.\1:g' | sort -u | grep -v -P "[^a-z0-9_.-]" >> ptlds.txt
}
	suffix 'https://publicsuffix.org/list/public_suffix_list.dat'

echo "OK"

# JOINT WHITELIST
echo "Joint Whitelist..."
cd $bw
sed -e '/^#/d' {ptlds,whiteurls,whitetlds}.txt | sort -u > tlds.txt
echo "OK"

# CAPTURE AND DELETE OVERLAPPING DOMAINS
echo "Capture Domains..."
cd $bw
regexd='([a-zA-Z0-9][a-zA-Z0-9-]{1,61}\.){1,}(\.?[a-zA-Z]{2,}){1,}'
find bl -type f -execdir egrep -oi "$regexd" {} \; | awk '{print "."$1}' | sort -u | sed 's:\(www\.\|WWW\.\|ftp\.\|/.*\)::g' > bldomains.txt
echo "OK"

echo "Delete Overlapping Domains..."
chmod +x parse_domain.py && python parse_domain.py | sort -u > blackweb.txt
cp -f {blackweb,blackdomains,whitedomains}.txt /etc/acl >/dev/null 2>&1
cd
rm -rf $bw
echo "OK"

# LOG
date=`date +%d/%m/%Y" "%H:%M:%S`
echo "Blackweb for Squid: Done $date" >> /var/log/syslog
echo "Done"
