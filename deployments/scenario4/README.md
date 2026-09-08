# Scenario 4: Adding another region with the same configuration as Scenario 3

This folder explains how to provision Node Exporter clients for the Demo in using Prometheus and Thanos with openSUSE Servers.

## Environments

There are two servers in each virtual networks. Each virtual network represents different region for demo purpose. Edit the subnet, ip and hostnames in files [hostlist-id.sh](./hostlist-id.sh) and [hostlist-sg.sh](./hostlist-sg.sh).

hostlist-id.sh

```
192.168.100.10 gpmidprome1
192.168.100.20 gpmidprome2
192.168.100.30 gpmidgrafana
192.168.100.40 gpmidthanos
192.168.100.201 gpmidservera
192.168.100.202 gpmidserverb
```

hostlist-sg.sh

```
192.168.101.10 gpmsgprome1
192.168.101.20 gpmsgprome2
192.168.101.40 gpmsgthanos
192.168.101.201 gpmsgservera
192.168.101.202 gpmsgserverb
```

![scenario4.png](../../assets/scenario4.png)

## Pre-provisioning

1. Ensure that the latest image is downloaded and inside into the Linux Hypervisor. Ensure that the qcow2 image file is present at the /deployments/images folder.

2. Generate ignition scripts and other resources with this command:

```shell
bash generate-ignition.sh
```

3. When needed, you can delete all ignition scripts and other resources with this command:

```shell
bash reset-ignition.sh --destroy
```

## Provisioning

Provision the VMs with this command:

```shell
bash start-vm.sh --provision
```

When needed, you can stop the VM with this command:

```shell
bash stop-vm.sh
```

and starting it once again with this command:

```shell
bash start-vm.sh
```

## Cleanup

If you need to stop the VMs and deleting all provisioned VMs, use this command

```shell
bash stop-vm.sh --destroy
```