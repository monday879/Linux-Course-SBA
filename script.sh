#!/bin/sh -u
#
# CST8213
# Qichen Jia
# This script documents and tries to completes the CST8213 SBA tasks.
#
PATH=/bin:/usr/bin:/sbin ; export PATH          # (2) PATH line
umask 022                                    # (3) umask line
#
# Variables
testuser=last
testuserpass=exam
#ncport1=234
#ncport2=432
testservernet=172.16.30.44
testclientnet=172.16.31.44
testaliasnet=172.16.32.44

# Minor services domain, 1 name server and a reverse zone, and a www. virtual hosts.
testdomain1=snow.lab

# Discarded
testdomain2=snow.lab

# Apache section first virtual host.
vdomain1=white.lab

# Maildomain in major services.
testmaildomain=bashful.lab
testmaildomain2=sleppy.lab

testhostname=jia00025-srv.$testdomain1
mailalias=labtest

# LDAP
ldapdb=bdb
ldapcn=ldapadm
ldapdc1=grumpy
ldapdc2=lab
ldapdir=grumpy.lab
# You may need to type in ldap entries manully
#
# Required Setup Section
#
yum install postfix
yum install bind
yum install httpd
systemctl stop NetworkManager.service
systemctl disable NetworkManager.service
iptables -F

useradd $testuser -g wheel -p $testuserpass
useradd cst8213 -g wheel -p cst8213

hostnamectl set-hostname $testhostname
echo "`cat /etc/sysconfig/network-scripts/ifcfg-ens33 | grep UUID`" >> sba/ifcfg-ens33
echo "UUID=`uuidgen ens34`" >> sba/ifcfg-ens34
echo "`cat sba/ifcfg-ens34 | grep UUID`" >> sba/ifcfg-ens34:0
echo -e "# Red network server Alias
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
IPADDR=$testaliasnet
NETMASK=255.255.0.0
NETWORK=172.16.0.0
BROADCAST=172.16.255.255
DEFROUTE=no
IPV4_FAILURE_FATAL=no
IPV6INIT=no
IPV6_AUTOCONF=no
IPV6_DEFROUTE=no
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens34:0
DEVICE=ens34:0
ONBOOT=yes
NM_CONTROLLED=no" >> sba/ifcfg-ens34:0
#
cp sba/ifcfg-ens33 /etc/sysconfig/network-scripts/ifcfg-ens33 
cp sba/ifcfg-ens34 /etc/sysconfig/network-scripts/ifcfg-ens34
cp sba/ifcfg-ens34:0 /etc/sysconfig/network-scripts/ifcfg-ens34:0
#
echo "$testservernet $testhostname" >> sba/hosts
cp sba/hosts /etc/hosts 
#
echo "nameserver $testservernet" >> sba/resolv.conf
echo "search $testdomain1" >> sba/resolv.conf
#echo "search $testdomain2" >> sba/resolv.conf
cp sba/resolv.conf /etc/resolv.conf 
#
#
# cp sba/nsswitch.conf /etc/nsswitch.conf 
#
systemctl restart network

# Minor Services Section
# SSH
cp sba/sshd_config1 /etc/ssh/sshd_config
systemctl restart sshd
#
# SSH for client
# ssh-keygen –t rsa
# ssh-copy-id $testuser@$testservernet
#
# Firewall / NC
#gnome-terminal -e "nc -kvl $ncport1"
#echo "iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport $ncport1 -j ACCEPT" >> sba/FWrules.sh
#echo "iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport $ncport1 -j REJECT" >> sba/FWrules.sh
#./sba/FWrules.sh
#
# Postfix

# DNS

# Creat forward and reverse zone files
echo -e "\$TTL 86400
; zone $testdomain1
@   IN  SOA ns1.$testdomain1. dnsadm.$testdomain1.  ( 
       
          201902271       ; Serial
          28800           ; Refresh
          14400           ; Retry
          604800          ; Expire
          10800           ; Minimum
          )

$testdomain1.      IN  NS    ns1.$testdomain1.
                   IN  NS    ns2.$testdomain1.
                   IN  MX 10 mail.$testdomain1.

ns1              IN  A     $testservernet
ns2              IN  A     $testclientnet
mail             IN  A     $testaliasnet
www              IN  A     $testservernet" >> sba/named.$testdomain1

#echo -e "\$TTL 86400
#; zone $testdomain2
#@   IN  SOA dns1.$testdomain2. dnsadm.$testdomain2.  ( 
#      
#          201902271       ; Serial
#          28800           ; Refresh
#          14400           ; Retry
#          604800          ; Expire
#          10800           ; Minimum
#          )
#
#$testdomain2.      IN  NS    ds1.$testdomain2.
#                   IN  NS    ds2.$testdomain2.
#
#dns1              IN  A     $testservernet
#dns2              IN  A     $testclientnet
#www              IN  A     $testservernet" >> sba/named.$testdomain2

echo -e "\$TTL 86400
; zone $vdomain1
@   IN  SOA ns1.$vdomain1. dnsadm.$vdomain1.  ( 
       
          201902271       ; Serial
          28800           ; Refresh
          14400           ; Retry
          604800          ; Expire
          10800           ; Minimum
          )

$vdomain1.      IN  NS    ds1.$vdomain1.
                IN  NS    ds2.$vdomain1.

ds1              IN  A     $testservernet
ds2              IN  A     $testclientnet
www1             IN  A     $testservernet
www2             IN  A     $testservernet
secure           IN  A     $testaliasnet
www              IN  A     $testservernet" >> sba/named.$vdomain1

echo -e "\$TTL 86400
; zone $testmaildomain
@   IN  SOA ns1.$testmaildomain. dnsadm.$testmaildomain.  ( 
       
          201902271       ; Serial
          28800           ; Refresh
          14400           ; Retry
          604800          ; Expire
          10800           ; Minimum
          )

$testmaildomain.      IN  NS    ns1.$testmaildomain.
                      IN  NS    ns2.$testmaildomain.
                      IN  MX 10 mail.$testmaildomain.

ns1              IN  A     $testservernet
ns2              IN  A     $testclientnet
www              IN  A     $testservernet
mail             IN  A     $testservernet
" >> sba/named.$testmaildomain

echo -e "\$TTL 86400
; zone $testmaildomain2
@   IN  SOA ns1.$testmaildomain2. dnsadm.$testmaildomain2.  ( 
       
          201902271       ; Serial
          28800           ; Refresh
          14400           ; Retry
          604800          ; Expire
          10800           ; Minimum
          )

$testmaildomain2.      IN  NS    ns1.$testmaildomain2.
                       IN  NS    ns2.$testmaildomain2.
                       IN  MX 10 mail.$testmaildomain2.

ns1              IN  A     $testservernet
ns2              IN  A     $testclientnet
www              IN  A     $testservernet
mail             IN  A     $testservernet
" >> sba/named.$testmaildomain2

echo -e "; Reverse zone file for zone $testdomain1
;
\$TTL 1D
\$ORIGIN 16.172.IN-ADDR.ARPA.
@        IN    SOA    ns1.$testdomain1. dnsadmin.$testdomain1. (
           201902271     ; Serial
           3600          ; Refresh
           300           ; Retry
           3600000       ; Expire
           3600          ; Minimum
          )
; name servers
         IN    NS    ns1.$testdomain1.
         IN    NS    ns2.$testdomain1.
; pointer records: 172.16.30.44 172.16.32.44
44.30    IN    PTR   ns1.$testdomain1.
44.31    IN    PTR   ns2.$testdomain1.
44.30    IN    PTR   mail.$testmaildomain.
44.30    IN    PTR   mail.$testmaildomain2. 
44.30    IN    PTR   www.$vdomain1.
44.30    IN    PTR   www1.$vdomain1.
44.30    IN    PTR   www2.$vdomain1.
44.32    IN    PTR   secure.$vdomain1.
44.30    IN    PTR   www.$testdomain1." > sba/named.16.172
#
# Edit DNS config file
echo -e "zone \".\" IN {
	type hint;
	file \"named.ca\";
};

zone \"$testdomain1\" IN {
	type master;
	file \"named.$testdomain1\";
};

zone \"$vdomain1\" IN {
        type master;
        file \"named.$vdomain1\";
};

zone \"$testmaildomain\" IN {
        type master;
        file \"named.$testmaildomain\";
};

zone \"$testmaildomain2\" IN {
        type master;
        file \"named.$testmaildomain2\";
};

zone \"16.172.IN-ADDR.ARPA\" in {
        type master;
        file \"named.16.172\";
};

include \"/etc/named.rfc1912.zones\";
#include \"/etc/named.root.key\";
" >> sba/named.conf
# Copy config and forward zone files
cp sba/named.conf /etc/named.conf 
cp sba/named.16.172 /var/named/named.16.172 
cp sba/named.$testdomain1 /var/named/named.$testdomain1 
#cp sba/named.$testdomain2 /var/named/named.$testdomain2 
cp sba/named.$vdomain1 /var/named/named.$vdomain1
cp sba/named.$testmaildomain /var/named/named.$testmaildomain
cp sba/named.$testmaildomain2 /var/named/named.$testmaildomain2
#
# YOU NEED TO CONFIG THE SLAVE ZONES IN CLIENT !!!!!
#
# Restart DNS service
systemctl restart named
#
# Major services
# Firewall / NC
#gnome-terminal -e "nc -kvl $ncport2"
#echo "iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport $ncport2 -j ACCEPT" >> sba/FWrules.sh
#echo "iptables -A INPUT -s 172.16.32.0/24 -p tcp --dport $ncport2 -j ACCEPT" >> sba/FWrules.sh
#echo "iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport $ncport2 -j REJECT" >> sba/FWrules.sh
#./sba/FWrules.sh
#
# SSH
# cp sba/sshd_config2 /etc/ssh/sshd_config
systemctl restart sshd
#
# Apache
# Install httpd
yum install openssl
yum install mod_ssl
mkdir /etc/httpd/tls
mkdir /etc/httpd/tls/key
chmod 700 /etc/httpd/tls/key
mkdir /etc/httpd/tls/cert
chmod 755 /etc/httpd/tls/cert
openssl req -x509 -newkey rsa -days 120 -nodes -keyout /etc/httpd/tls/key/white.key -out /etc/httpd/tls/cert/white.cert -subj '/O=CST8213/OU=white.lab/CN=secure.white.lab'
# Create directory tree
mkdir /var/www/vhosts
mkdir /var/www/vhosts/www.$vdomain1
mkdir /var/www/vhosts/www1.$vdomain1
mkdir /var/www/vhosts/www2.$vdomain1
mkdir /var/www/vhosts/secure.$vdomain1
mkdir /var/www/vhosts/www.$testdomain1
mkdir /var/www/vhosts/www.$vdomain1/html
mkdir /var/www/vhosts/www1.$vdomain1/html
mkdir /var/www/vhosts/www2.$vdomain1/html
mkdir /var/www/vhosts/secure.$vdomain1/html
mkdir /var/www/vhosts/www.$testdomain1/html
#
# Create index files
#
echo -e "<Title>default.$testdomain1</Title>
<H1>Host: $testhostname [$testservernet]</H1>
<H1>MagicNumber: 44</H1>
<H1>Network-ID: $testservernet</H1>
<H1>Name: Qichen Jia</H1>
<H1>Station: 12</H1>
<H1>Word: DEFAULT</H1>
" >> /var/www/html/index.html

echo -e "<Title>www.$vdomain1</Title>
<H1>Service: HTTP</H1>
<H1>Server: jia00025-srv.$vdomain1</H1>
<H1>IP address/port: $testservernet[80]</H1>
<H1>Host: $testhostname [$testservernet]</H1>
<H1>MagicNumber: 44</H1>
<H1>Network-ID: $testservernet</H1>
<H1>Name: Qichen Jia</H1>
<H1>Station: 12</H1>
<H1>Word: WHITE</H1>
<H1>Site Name: www.$vdomain1</H1>
" >> /var/www/vhosts/www.$vdomain1/html/index.html

echo -e "<Title>www1.$vdomain1</Title>
<H1>Service: HTTP</H1>
<H1>Server: jia00025-srv.$vdomain1</H1>
<H1>IP address/port: $testservernet[80]</H1>
<H1>Host: $testhostname [$testservernet]</H1>
<H1>MagicNumber: 44</H1>
<H1>Network-ID: $testservernet</H1>
<H1>Name: Qichen Jia</H1>
<H1>Station: 12</H1>
<H1>Site Name: www1.$vdomain1</H1>
" >> /var/www/vhosts/www1.$vdomain1/html/index.html

echo -e "<Title>www2.$vdomain1</Title>
<H1>Service: HTTP</H1>
<H1>Server: jia00025-srv.$vdomain1</H1>
<H1>IP address/port: $testservernet[80]</H1>
<H1>Host: $testhostname [$testservernet]</H1>
<H1>MagicNumber: 44</H1>
<H1>Network-ID: $testservernet</H1>
<H1>Name: Qichen Jia</H1>
<H1>Station: 12</H1>
<H1>Site Name: www2.$vdomain1</H1>
" >> /var/www/vhosts/www2.$vdomain1/html/index.html

echo -e "<Title>secure.$vdomain1</Title>
<H1>Service: HTTPS</H1>
<H1>Server: jia00025-srv.$vdomain1</H1>
<H1>IP address/port: $testaliasnet[443]</H1>
<H1>Host: $testhostname [$testaliasnet]</H1>
<H1>MagicNumber: 44</H1>
<H1>Network-ID: $testaliasnet</H1>
<H1>Name: Qichen Jia</H1>
<H1>Station: 12</H1>
<H1>Site Name: secure.$vdomain1</H1>
" >> /var/www/vhosts/secure.$vdomain1/html/index.html

echo -e "<Title>www.$testdomain1</Title>
<H1>Service: HTTP</H1>
<H1>Server: jia00025-srv.$testdomain1</H1>
<H1>IP address/port: $testservernet[80]</H1>
<H1>Site Name: www.$testdomain1</H1>
" >> /var/www/vhosts/www.$testdomain1/html/index.html
#
# Config file
#
echo -e "ServerName $testhostname

ServerAdmin webmaster@$testdomain1

<VirtualHost 172.0.0.1>
</VirtualHost>

<VirtualHost $testservernet>
ServerName www.$vdomain1
DocumentRoot \"/var/www/vhosts/www.$vdomain1/html\"
</VirtualHost>

<VirtualHost $testservernet>
ServerName www1.$vdomain1
DocumentRoot \"/var/www/vhosts/www1.$vdomain1/html\"
</VirtualHost>

<VirtualHost $testservernet>
ServerName www2.$vdomain1
DocumentRoot \"/var/www/vhosts/www2.$vdomain1/html\"
</VirtualHost>

<VirtualHost $testaliasnet>
ServerName secure.$vdomain1
DocumentRoot \"/var/www/vhosts/secure.$vdomain1/html\"
SSLCertificateFile /etc/httpd/tls/cert/white.cert
SSLCertificateKeyFile /etc/httpd/tls/key/white.key
SSLEngine On
</VirtualHost>

<VirtualHost $testservernet>
ServerName www.$testdomain1
DocumentRoot \"/var/www/vhosts/www.$testdomain1/html\"
</VirtualHost>" >> sba/httpd.conf

cp sba/httpd.conf /etc/httpd/conf/httpd.conf 
systemctl restart httpd
#
# Postfix
# Config aliases
echo -e "$mailalias: $testuser, cst8213, dnsadmin" >> /etc/aliases 
postalias -q $mailalias /etc/aliases
# Edit postfix config file
echo -e "$testmaildomain2  # The second test mail domain" > /etc/postfix/virtual_domains
echo "mydomain = $testmaildomain" >> sba/main.cf
cp sba/main.cf /etc/postfix/main.cf
postmap /etc/postfix/virtual_domains
systemctl restart postfix
#
# LDAP
#
yum install openldap
yum install openldap-servers
yum install openldap-clients

echo -e "include /etc/openldap/schema/core.schema
include /etc/openldap/schema/cosine.schema
include /etc/openldap/schema/inetorgperson.schema
include /etc/openldap/schema/nis.schema

pidfile /var/run/openldap/slapd.pid

loglevel 256

database $ldapdb

# The suffix directive refers to the DN that identifies the top entry of the server's DIT.
suffix \"dc=$ldapdc1,dc=$ldapdc2\"

# The directory gives the database location.
directory /var/lib/ldap/$ldapdir

# The rootdn directive is set to the DN of the administrative account of your directory name space; this account has unrestricted access for the management of the DIT. This user does not need to exist in the Linux user database.
rootdn \"cn=$ldapcn,dc=$ldapdc1,dc=$ldapdc2\"

# The LDAP administrator\'s password.
rootpw secret" >> sba/slapd.conf

cp sba/slapd.conf /etc/openldap/slapd.conf
chgrp ldap /etc/openldap/slapd.conf
chmod 770 /etc/openldap/slapd.conf
mv /etc/openldap/slapd.d /etc/openldap/slapd.dbackup

mkdir /var/lib/ldap/$ldapdir
chown ldap /var/lib/ldap/$ldapdir
chgrp ldap /var/lib/ldap/$ldapdir
chmod 700 /var/lib/ldap/$ldapdir
cp sba/DB_CONFIG /var/lib/ldap/$ldapdir/DB_CONFIG
chown ldap /var/lib/ldap/$ldapdir/DB_CONFIG
systemctl enable slapd
systemctl start slapd

echo -e "#
# LDAP Defaults
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.

#BASE	dc=example,dc=com
#URI	ldap://ldap.example.com ldap://ldap-master.example.com:666
BASE dc=$ldapdc1,dc=$ldapdc2
URI  ldap://127.0.0.1 ldap://$testservernet

#SIZELIMIT	12
#TIMELIMIT	15
#DEREF		never

TLS_CACERTDIR	/etc/openldap/certs

# Turning this off breaks GSSAPI used with krb5 when rdns = false
SASL_NOCANON	on" > /etc/openldap/ldap.conf

mkdir /etc/openldap/ldif.$ldapdc1

echo -e "dn: dc=$ldapdc1,dc=$ldapdc2
objectclass: domain
dc: $ldapdc1" > /etc/openldap/ldif.$ldapdc1/base.ldif

echo -e "dn: ou=people,dc=$ldapdc1,dc=$ldapdc2
objectclass: organizationalUnit
ou: people

dn: uid=Richard Hagemeyer,ou=people,dc=$ldapdc1,dc=$ldapdc2
objectclass: inetOrgPerson
objectclass: posixAccount
cn: Richard
sn: Hagemeyer
uid: Richard Hagemeyer
uidNumber: 1003
gidNumber: 1000
homeDirectory: /home/jia00025
loginshell: /bin/bash
mail: Richard Hagemeyer@$ldapdir
userPassword:
" > /etc/openldap/ldif.$ldapdc1/ou.ldif

echo -e "dn: ou=hosts,dc=$ldapdc1,dc=$ldapdc2
objectclass: organizationalUnit
ou: hosts

dn: cn=www.$ldapdir,ou=hosts,dc=$ldapdc1,dc=$ldapdc2
objectclass: ipHost
objectclass: device
cn: www.$ldapdir
ipHostNumber: 172.16.30.44
description: www.$ldapdir
" > /etc/openldap/ldif.$ldapdc1/ouhosts.ldif

ldapadd -x -D "cn=ldapadm,dc=$ldapdc1,dc=$ldapdc2" -w secret -f /etc/openldap/ldif.$ldapdc1/base.ldif
ldapadd -x -D "cn=ldapadm,dc=$ldapdc1,dc=$ldapdc2" -w secret -f /etc/openldap/ldif.$ldapdc1/ou.ldif
ldapadd -x -D "cn=ldapadm,dc=$ldapdc1,dc=$ldapdc2" -w secret -f /etc/openldap/ldif.$ldapdc1/ouhosts.ldif
systemctl restart named
#
# Samba
yum install samba
yum install samba-common
systemctl start smb
systemctl enable smb
# smbpasswd -a $testuser1
# smbpasswd -a $testuser2
echo -e "# See smb.conf.example for a more detailed config file or
# read the smb.conf manpage.
# Run 'testparm' to verify the config is correct after
# you modified it.

[global]
	workgroup = CST8213
	security = user

	passdb backend = tdbsam

	printing = cups
	printcap name = cups
	load printers = yes
	cups options = raw
        wins support = Yes

[homes]
	comment = Home Directories
        valid users = %S, %D%w%S
	browseable = Yes
	read only = No
        writeable = Yes
	inherit acls = No
        available = Yes
        

[printers]
	comment = All Printers
	path = /var/tmp
	printable = Yes
	create mask = 0600
	browseable = No

[print\$]
	comment = Printer Drivers
	path = /var/lib/samba/drivers
	write list = @printadmin root
	force group = @printadmin
	create mask = 0664
	directory mask = 0775

[public]
        comment = share for cst8213 SBA
        path = /srv/samba/rwShare
        public = yes
        readonly = yes
        directory mask = 000
        create mask = 000" > /etc/samba/smb.conf
chmod 644 /etc/samba/smb.conf
mkdir /srv/samba
mkdir /srv/samba/rwShare
echo -e "Magic Number: 44
Network-ID: 172.16.30.44
Name: Qichen Jia
Station: 12" > /srv/samba/rwShare/readme.smb
echo -e "Magic Number: 44
Network-ID: 172.16.30.44
Name: Qichen Jia
Station: 12" > /home/last/readme.smb
chmod 777 /home/last/readme.smb

#
# NFS
#
yum install nfs-utils
systemctl start rpcbind
systemctl start nfs
# mkdir
mkdir /srv/nfs
mkdir /srv/nfs/share
echo -e "Magic Number: 44
Network-ID: 172.16.30.44
Name: Qichen Jia
Station: 12" > /srv/nfs/share/readme.nfs
chmod 777 /srv/nfs/share/readme.nfs

echo -e "/srv/nfs/share 172.16.31.44(rw)
/srv/nfs/share *(ro)" >> /etc/exports
exportfs -r -a
exportfs -v
#
# Postgresql
yum install postgresql-server
yum install postgresql
yum install postgres-libs
postgresql-setup initdb
systemctl enable postgresql.service
systemctl start postgresql.service