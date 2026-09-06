#!/bin/bash

PATH=$PATH:$(pwd)
IGNITION_DIR=$(pwd)/ignition


reset_ignition() {
# Define the VM names array
vms=($(echo "$hostlist" | awk '{print $2}'))

for vm in ${vms[*]}; do
    echo "Reset ignition config for VM $vm"
    rm -f $IGNITION_DIR/$vm.ign
done

if [[ $1 == "--destroy" ]]; then rm -rf $CURRENT_DIR/{certs,butane-autogen,rootca,butane-generated,ignition}; fi
}

source hostlist-id.sh
reset_ignition $1

source hostlist-sg.sh
reset_ignition $1