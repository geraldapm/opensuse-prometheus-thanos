#!/bin/bash

PATH=$PATH:$(pwd)


### it is required that you create another virt network called "virbr1" and "virbr2" to accomodate the requirements

IMAGE_DIR=../images
TEMPLATE_DISK_FILE="$IMAGE_DIR/openSUSE-Leap-Micro.x86_64-Default-qcow.qcow2"
IGNITION_DIR=$(pwd)/ignition

### VM Specs
VCPU=1
MEMORY_MB=1024


vm_provisioning(){
# Define the VM names array
vms=($(echo "$hostlist" | awk '{print $2}'))


for vm in ${vms[*]}; do 
    IP_ADDR="$(echo "$hostlist" | grep $vm | awk '{print $1}')"
    CIDR="$(echo $IP_SUBNET | cut -d'/' -f2)"

    echo "Starting VM $vm with IP Address $IP_ADDR/$CIDR gateway $IP_GATEWAY"

if [[ $1 == "--provision" ]];
then
    cp -f $TEMPLATE_DISK_FILE $IMAGE_DIR/$vm.qcow2
    qemu-img resize $IMAGE_DIR/$vm.qcow2 +20G
    # qemu-img create -f qcow2 -F qcow2 -b $TEMPLATE_DISK_FILE $IMAGE_DIR/$vm.qcow2 20G

    virt-install \
    --name=$vm \
    --ram=$MEMORY_MB \
    --vcpus=$VCPU \
    --import \
    --disk path=$IMAGE_DIR/$vm.qcow2,device=disk,bus=scsi \
    --os-variant opensuse-unknown \
    --network bridge=$NETWORK_IFACE,model=virtio \
    --graphics vnc,listen=0.0.0.0 --noautoconsole \
    --sysinfo type=fwcfg,entry0.name="opt/com.coreos/config",entry0.file="$IGNITION_DIR/$vm.ign"

else
    virsh start $vm
fi

done
}

### id server provisioning

source hostlist-id.sh
NETWORK_IFACE=virbr1
vm_provisioning $1

source hostlist-sg.sh
NETWORK_IFACE=virbr2
vm_provisioning $1

> $HOME/.ssh/known_hosts
