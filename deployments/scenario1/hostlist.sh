#!/bin/bash

### it is required that you create another virt network called "virbr1" and "virbr2" to accomodate the requirements

### Define IP Subnet for CIDR assignment including floating IP and gateway IP

IP_SUBNET=192.168.100.0/24

### Set IP Subnet Gateway
IP_GATEWAY="$(echo $IP_SUBNET | cut -d. -f1-3).1"

### Define the Virtual IP or Floating IP
IP_FLOATING="$(echo $IP_SUBNET | cut -d. -f1-3).99"

### Define cluster member list
### Ensure that the hostname has "wontrol" and "worker" inside for node role filtering
hostlist=$(cat <<EOF
192.168.100.10 gpmidprome1
192.168.100.30 gpmidgrafana
EOF
)
