# Deployment Demo of Distributed Prometheus with Thanos on OpenSUSE servers

The distributed system is deployed using two regions, which consists of Indonesia Region and Singapore Region and simulated with KVM.

Prerequisites:

You should deploy the underlying target servers first using this [README.md](deployments/clients/README.md).

There are four scenarios to try on:

## Scenario 1: Typical Node Exporter - Prometheus - Grafana deployment
![scenario1.png](assets/scenario1.png)

Refer to the tutorial [README.md](deployments/scenario1/README.md) to provision the VMs, then you can follow the tutorial below.

## Scenario 2: Adding another prometheus replica with Thanos Sidecar and Thanos Query
![scenario2.png](assets/scenario2.png)

Refer to the tutorial [README.md](deployments/scenario2/README.md) to provision the VMs, then you can follow the tutorial below.

## Scenario 3: Applying Object Storage Data Retention with rustFS, Thanos Store Gateway, and Thanos Compact
![scenario3.png](assets/scenario3.png)

Refer to the tutorial [README.md](deployments/scenario3/README.md) to provision the VMs, then you can follow the tutorial below.


## Scenario 4: Applying Object Storage Data Retention with rustFS, Thanos Store Gateway, and Thanos Compact
![scenario4.png](assets/scenario4.png)

Refer to the tutorial [README.md](deployments/scenario4/README.md) to provision the VMs, then you can follow the tutorial below.
