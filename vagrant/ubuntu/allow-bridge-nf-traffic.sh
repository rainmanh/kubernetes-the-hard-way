#!/bin/bash
modprobe br_netfilter
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl -p /etc/sysctl.conf