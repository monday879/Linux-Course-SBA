#!/bin/sh -u
#
# CST8213 - Firewall rules
# Qichen Jia

#
# Variables
PATH=/bin:/usr/bin:/sbin ; export PATH          # (2) PATH line
umask 022                                       # (3) umask line

#
# Flush iptables to start with a clean slate
iptables -F

#
# Set the default policy to be permissive
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
#
# SSH rule: accept incoming SSH traffic for subnet users
# iptables -A INPUT -s 172.16.32.0/24 -p tcp --dport 22 -j ACCEPT
# iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 22 -j ACCEPT
#
# SSH rule: deny incoming SSH traffic from all other users
# iptables -A INPUT -p tcp --dport 22 -j REJECT
#
# Rules for hosts:
# iptables -A INPUT -i lo -j ACCEPT
# iptables -A INPUT -s 172.16.30.44 -j ACCEPT
#
# Lab2 nc connection to 49999 port
# iptables -A INPUT -s 172.16.31.44 -p tcp --dport 49999 -j REJECT
# iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 49999 -j ACCEPT
# iptables -A INPUT -p tcp --dport 49999 -j REJECT
#
# Lab5 DNS access
# iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 53 -j ACCEPT
# iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 53 -j ACCEPT
# iptables -A INPUT -s 172.16.32.0/24 -p tcp --dport 53 -j REJECT
#
# Lab6 Mail access
# iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 25 -j ACCEPT
# iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 25 -j ACCEPT
# iptables -A INPUT -s 172.16.32.0/24 -p tcp --dport 25 -j REJECT
#
# Lab7 http access
# iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 80 -j ACCEPT
# iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 443 -j ACCEPT
# iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 80 -j REJECT
# iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 443 -j REJECT
# iptables -A INPUT -s 172.16.32.0/24 -p tcp --dport 80 -j REJECT
#
# Default rules for labs
# iptables -A INPUT -s 172.16.31.0/24 -j ACCEPT
# iptables -A INPUT -s 172.16.30.0/24 -j REJECT
