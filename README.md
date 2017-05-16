## [Blackweb](http://www.maravento.com/p/blacklistweb.html)

<a target="_blank" href=""><img src="https://img.shields.io/badge/Development-ALPHA-blue.svg"></a>

[Blackweb](http://www.maravento.com/p/blacklistweb.html) es un proyecto que pretende recopilar la mayor cantidad de listas negras públicas de dominios (para bloquear porno, descargas, drogas, malware, spyware, trackers, bots, redes sociales, warez, venta de armas, etc), con el objeto de unificarlas y hacerlas compatibles con [Squid-Cache](http://www.squid-cache.org/) (Tested in v3.5.x). Para lograrlo, realizamos una depuración de urls, para evitar duplicados, dominios inválidos (validación de ccTLD, ccSLD, sTLD, uTLD, gSLD, gTLD, etc), y un filtrado con listas blancas de dominios (falsos positivos, como google, hotmail, yahoo, etc), para obtener una mega ACL, optimizada para [Squid-Cache](http://www.squid-cache.org/), libre de "overlapping domains" (e.g: "ERROR: '.sub.example.com' is a subdomain of '.example.com'").

[Blackweb](http://www.maravento.com/p/blacklistweb.html) is a project that aims to collect as many public domain blacklists (to block porn, downloads, drugs, malware, spyware, trackers, Bots, social networks, warez, arms sales, etc.), in order to unify them and make them compatible with [Squid-Cache](http://www.squid-cache.org/) (Tested in v3.5.x ). To do this, we perform a debugging of urls, to avoid duplicates, invalid domains (validation, ccTLD, ccSLD, sTLD, uTLD, gSLD, gTLD, etc), and filter with white lists of domains (false positives such as google , hotmail, yahoo, etc.), to get a mega ACL, optimized for [Squid-Cache](http://www.squid-cache.org/), free of overlapping domains (eg: "ERROR: '.sub.example.com' is a subdomain of '.example.com'").

### Descripción / Description

|File|BL Domains|File size|
|----|----------|---------|
|blackweb.txt|6.242.455|139,3 Mb|

### Dependencias / Dependencies

```
git squid bash tar zip wget
```

### Modo de uso / How to use

La ACL **blackweb.txt** ya viene optimizada para [Squid-Cache](http://www.squid-cache.org/). Descárguela, descomprímala, ponga la ACL en el directorio de su preferencia y active la regla de [Squid-Cache](http://www.squid-cache.org/) (El directorio por defecto es **/etc/acl**) / The ACL **blackweb.txt** is already optimized for [Squid-Cache](http://www.squid-cache.org/). Download it, decompress it, put the ACL in the directory of your preference and activate the [Squid-Cache](http://www.squid-cache.org/) rule (The default directory is **/etc/acl**)

```
if [ ! -d /etc/acl ]; then mkdir -p /etc/acl; fi
wget https://github.com/maravento/blackweb/raw/master/blackweb.tar.gz
tar -C /etc/acl -xvzf blackweb.tar.gz

```

### Actualización BLs / Update BLs

También puede descargar el proyecto Blackweb y actualizar la ACL **blackweb.txt** en dependencia de sus necesidades / You can also download the Blackweb project and update the **blackweb.txt** ACL depending on your needs

```
git clone https://github.com/maravento/blackweb.git
sudo cp -f blackweb/blackweb.sh /etc/init.d
sudo chown root:root /etc/init.d/blackweb.sh
sudo chmod +x /etc/init.d/blackweb.sh
sudo /etc/init.d/blackweb.sh
```

#####  Verifique su ejecución / Check execution (/var/log/syslog):

Ejecución exitosa / Successful execution
```
Blackweb for Squid: Done 06/05/2017 15:47:14
```
Ejecución fallida / Execution failed

```
Blackweb for Squid: Abort 06/05/2017 15:47:14 Check Internet Connection
```

### Regla de [Squid-Cache](http://www.squid-cache.org/) / [Squid-Cache](http://www.squid-cache.org/) Rule

Edit /etc/squid/squid.conf:
```
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
acl blackweb dstdomain -i "/etc/acl/blackweb.txt"
http_access deny blackweb
```
### Edición / Edition

Blackweb contiene millones de dominios bloqueados, por tanto, editarla manualmente puede ser frustrante. Entonces, si detecta un falso positivo, utilice la ACL "whitedomains" y reporte el incidente, para corregirlo en la próxima actualización. Lo mismo aplica para dominios no incluidos en Blackweb, que quiera bloquear, puede incluirlos en "blackdomains" / Blackweb contains million domains blocked therefore manually editing can be frustrating. Then, if it detects a false positive, use the ACL "whitedomains" and report the incident to correct it in the next update. The same applies for domains not included in Blackweb, you want to block, you can include them in "blackdomains"

```
acl whitedomains dstdomain -i "/etc/acl/whitedomains.txt"
acl blackdomains dstdomain -i "/etc/acl/blackdomains.txt"
acl blackweb dstdomain -i "/etc/acl/blackweb.txt"
http_access allow whitedomains
http_access deny blackdomains 
http_access deny blackweb
```
### Important

- "Blackdomains" incluye por default algunos dominios no incluidos en Blackweb (e.g. .youtube.com .googlevideo.com, .ytimg.com) y "whitedomains" incluye el subdominio accounts.youtube.com [desde Feb 2014, Google utiliza el subdominio accounts.youtube.com para autenticar sus servicios](http://wiki.squid-cache.org/ConfigExamples/Streams/YouTube) / "Blackdomains" by default includes some domains not included in Blackweb (eg .youtube.com .googlevideo.com, .ytimg.com) and "whitedomains" includes the subdomain accounts.youtube.com [since February 2014, Google uses the accounts subdomain .youtube.com to authenticate their services](http://wiki.squid-cache.org/ConfigExamples/Streams/YouTube).
- Por defecto, la ruta de blackweb es **/etc/acl** y del script **/etc/init.d** / By default, blackweb path is **/etc/acl** and the script **/etc/init.d**
- Blackweb está diseñada exclusivamente para bloquear dominios. Para los interesados en bloquear banners y otras modalidades publicitarias, visite el foro [Alterserv](http://www.alterserv.com/foros/index.php?topic=1428.0) / Blackweb is designed exclusively to block domains. For those interested in blocking banners and other advertising forms, visit the [Alterserv](http://www.alterserv.com/foros/index.php?topic=1428.0) forum.
- Los interesados pueden contribuir, enviándonos enlaces de nuevas BLs, para ser incluidas en este proyecto / Those interested may contribute sending us new BLs links to be included in this project

### Datasheet

##### General Public and Malware BLs

[Shallalist](http://www.shallalist.de/Downloads/shallalist.tar.gz)

[UrlBlacklist](http://urlblacklist.com/?sec=download)

[Capitole - Direction du Système d'Information (DSI)](http://dsi.ut-capitole.fr/blacklists/download/)

[MESD blacklists](http://squidguard.mesd.k12.or.us/blacklists.tgz)

[Yoyo Serverlist](http://pgl.yoyo.org/adservers/serverlist.php?hostformat=nohtml)

[Passwall](http://www.passwall.com/blacklist.txt)

[Oleksiig Blacklist](https://raw.githubusercontent.com/oleksiig/Squid-BlackList/master/denied_ext.conf)

[Someonewhocares](http://someonewhocares.org/hosts/hosts)

[HP Hosts-file](http://hosts-file.net/download/hosts.txt)

[Winhelp2002](http://winhelp2002.mvps.org/hosts.txt)

[Cibercrime-Tracker](http://cybercrime-tracker.net/all.php)

[Joewein Blacklist](http://www.joewein.de/sw/bl-text.htm)

[Tracking-Addresses](https://github.com/10se1ucgo/DisableWinTracking/wiki/Tracking-Addresses)

[Adaway](http://adaway.org/hosts.txt)

[Lehigh Malwaredomains](http://malwaredomains.lehigh.edu/files/)

[Easylist for adblockplus](https://easylist-downloads.adblockplus.org/malwaredomains_full.txt)

[Zeus tracker](https://zeustracker.abuse.ch/blocklist.php?download=squiddomain)

[Malwaredomain Hosts List](http://www.malwaredomainlist.com/hostslist/hosts.txt)

[Malware-domains](http://www.malware-domains.com/)

[malc0de](http://malc0de.com/bl/)

[BambenekConsulting](http://osint.bambenekconsulting.com/feeds/dga-feed.txt)

[openphish](https://openphish.com/feed.txt)

##### Ransomware BL

[Ransomware Abuse](https://ransomwaretracker.abuse.ch/blocklist/)

##### TLDs

[IANA](https://www.iana.org/domains/root/db)

[Mozilla Public Suffix](https://publicsuffix.org/list/public_suffix_list.dat)

[Wikipedia Top Level Domains](https://en.wikipedia.org/wiki/List_of_Internet_top-level_domains)

##### Domains Debugging

[Whitetlds](https://github.com/maravento/blackweb/raw/master/whitetlds.txt)

[Blackurls](https://github.com/maravento/blackweb/raw/master/blackurls.txt)

[Whiteurls](https://github.com/maravento/blackweb/raw/master/whiteurls.txt)

[httpstatus](https://httpstatus.io/)

### Licence

[GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)

Agradecemos a todos aquellos que han contribuido a este proyecto. We thank all those who contributed to this project. Special thanks to [novatoz.com](http://www.novatoz.com)

© 2016 [Gateproxy](https://github.com/maravento/gateproxy) by [maravento](http://www.maravento.com)

#### Disclaimer

Este script puede dañar su sistema si se usa incorrectamente. Úselo bajo su propio riesgo. This script can damage your system if used incorrectly. Use it at your own risk. [HowTO Gateproxy](https://github.com/maravento/gateproxy/blob/master/gateproxy.pdf)
