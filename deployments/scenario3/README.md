# Scenario 3: Applying Object Storage Data Retention with rustFS, Thanos Store Gateway, and Thanos Compact

This folder explains the scenario for deploying Typical Node Exporter - Prometheus - Grafana deployment. We will use two main VMs, one for Prometheus and one for Grafana. It will be deployed in the same network.

## Environments

There are two servers in a virtual network. Edit the subnet, ip and hostnames in files [hostlist.sh](./hostlist.sh). Be sure to also edit [../scripts/hosts-generator.sh](../scripts/hosts-generator.sh) to ensure that all vm lists are reachable by hostname.

hostlist.sh

```
192.168.100.10 gpmidprome1
192.168.100.20 gpmidprome2
192.168.100.30 gpmidgrafana
192.168.100.40 gpmidthanos
```

![scenario3.png](../../assets/scenario3.png)

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