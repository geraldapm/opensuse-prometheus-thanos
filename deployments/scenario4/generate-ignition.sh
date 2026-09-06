#!/bin/bash

PATH=$PATH:$(pwd)

BUTANE_AUTOGEN_DIR=../butane-autogen
BUTANE_STATIC_DIR=../butane-config
BUTANE_GENERATED_DIR=../butane-generated
IGNITION_DIR=$(pwd)/ignition

# create the generated butane directory
mkdir -p $BUTANE_GENERATED_DIR $IGNITION_DIR

bash ../scripts/ssh-generator.sh



ignition_generator(){
# Define the VM names array
vms=($(echo "$hostlist" | awk '{print $2}'))

for vm in ${vms[*]}; do 
    IP_ADDR="$(echo "$hostlist" | grep $vm | awk '{print $1}')"
    CIDR="$(echo $IP_SUBNET | cut -d'/' -f2)"

    echo "Generating ignition config for VM $vm with IP Address $IP_ADDR/$CIDR gateway $IP_GATEWAY"

    cat << EOF > $BUTANE_GENERATED_DIR/butane-$vm.yaml
    variant: fcos
    version: 1.5.0
    ignition:
        config:
            merge:
            - inline: |-
                $(cat $BUTANE_STATIC_DIR/butane-common.yaml \
                    | sed "s+###IP_GATEWAY###+$IP_GATEWAY+g" \
                    | sed "s+/###CIDR###+/$CIDR+g" \
                    | sed "s+###HOSTNAME###+$vm+g" \
                    | sed "s+###IP_ADDRESS###+$IP_ADDR+g" \
                    | butane)
            - inline: |-
                $(cat $BUTANE_AUTOGEN_DIR/butane-hosts.yaml \
                    | sed "s+###IP_GATEWAY###+$IP_GATEWAY+g" \
                    | sed "s+/###CIDR###+/$CIDR+g" \
                    | sed "s+###HOSTNAME###+$vm+g" \
                    | sed "s+###IP_ADDRESS###+$IP_ADDR+g" \
                    | butane)
            - inline: |-
                $(cat $BUTANE_STATIC_DIR/butane-node-exporter.yaml \
                    | butane)
            - inline: |-
                $(cat $BUTANE_AUTOGEN_DIR/butane-ssh.yaml \
                    | butane)

EOF


    # Generate ignition file from compiled butane files
    butane --pretty $BUTANE_GENERATED_DIR/butane-$vm.yaml > $IGNITION_DIR/$vm.ign

    #Remove unused butane generated file
    rm -f $BUTANE_GENERATED_DIR/butane-$vm.yaml
done
}


source hostlist-id.sh
ignition_generator

source hostlist-sg.sh
ignition_generator