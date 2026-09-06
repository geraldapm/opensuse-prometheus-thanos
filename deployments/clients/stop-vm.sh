#!/bin/bash

CURRENT_DIR=$(pwd)

stop_vm() {
# Define the VM names array
vms=($(echo "$hostlist" | awk '{print $2}'))

for vm in ${vms[*]}; do
    echo "Power Off VM $vm"
    virsh destroy $vm
    virt-xml $vm --edit --sysinfo remove_entry=all
    if [[ $1 == "--destroy" ]];
    then
    echo "Cleanup VM $vm"
    virsh undefine $vm --remove-all-storage

    fi
done
}

source hostlist-id.sh
stop_vm

source hostlist-sg.sh
stop_vm