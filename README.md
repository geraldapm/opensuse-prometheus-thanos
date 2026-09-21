# Deployment Demo of Distributed Prometheus with Thanos on OpenSUSE servers

This repository contains tutorial and configuration of ["Distributed Monitoring System using Prometheus and Thanos on openSUSE Servers"](https://events.opensuse.org/conferences/oSAS26/program/proposals/5205) Parallel Session delivered in openSUSE Asia Summit 2026. The distributed system is deployed using two regions, which consists of Indonesia Region and Singapore Region and simulated with KVM.

[Slide Link](https://docs.google.com/presentation/d/1h-dTrSJsNY501irAIZV0tIGXRC3Zmgdgzcs8PaCi57o/edit?usp=sharing)

There are four scenarios to try on:
- Scenario 1: Typical Node Exporter - Prometheus - Grafana deployment
- Scenario 2: Adding another prometheus replica with Thanos Sidecar and Thanos Query
- Scenario 3: Applying Object Storage Data Retention with rustFS, Thanos Store Gateway, and Thanos Compact
- Scenario 4: Adding another region with the same configuration as Scenario 3
- Extra Scenario: Deploy Prometheus and Thanos with Kubernetes and combining it with Scenario 4

## Prerequisites
- Installed any Linux distribution (openSUSE preferred) with KVM availability installed.
- Generate your ssh key. Run `ssh-keygen -t rsa` if you doesn't have it.
- This configuration will consume around 32GB M=memory. In my case, I have 64GB of memory.
- You should deploy the underlying target servers first using this [README.md](deployments/clients/README.md).
- When using *deploy.sh*, ensure that the IP Address are changed if you have different network setup than defined in this repository
- Butane binary executable to convert butane definition into ignition file. Download it from there -> https://github.com/coreos/butane/releases and install with this command:

```bash
wget -c https://github.com/coreos/butane/releases/download/v0.25.1/butane-x86_64-unknown-linux-gnu -O butane
chmod +x butane
```
- Then download the correspoding openSUSE LEAP Micro Image from This URL -> https://download.opensuse.org/distribution/leap-micro/6.2/appliances/openSUSE-Leap-Micro.x86_64-Default-qcow.qcow2 and store in in the ./deployment/images folder
```bash
mkdir -p deployments/images
wget -c https://download.opensuse.org/distribution/leap-micro/6.2/appliances/openSUSE-Leap-Micro.x86_64-Default-qcow.qcow2 -O deployments/images/
```

## Scenario 1: Typical Node Exporter - Prometheus - Grafana deployment
![scenario1.png](assets/scenario1.png)

Refer to the tutorial [README.md](deployments/scenario1/README.md) to provision the VMs, then you can follow the tutorial below.

### Deploying the environment

Go to the deployment [folder](podman/scenario1).
```bash
cd podman/scenario1
```

Simply run the script to deploy the Prometheus and Grafana Environment:
```bash
bash deploy.sh
```

When needs to cleanup the environment, run this script:
```bash
bash cleanup.sh
```

## Scenario 2: Adding another prometheus replica with Thanos Sidecar and Thanos Query
![scenario2.png](assets/scenario2.png)

Refer to the tutorial [README.md](deployments/scenario2/README.md) to provision the VMs, then you can follow the tutorial below.

### Deploying the environment

Go to the deployment [folder](podman/scenario2).
```bash
cd podman/scenario2
```

Simply run the script to deploy the Prometheus with Thanos and Grafana Environment:
```bash
bash deploy.sh
```

When needs to cleanup the environment, run this script:
```bash
bash cleanup.sh
```

### Explanation
You can see the differences between the configs by using this command:
```bash
cd $(git rev-parse --show-toplevel)
diff -y podman/scenario1/config/prometheus/prometheus.yml podman/scenario2/config/prometheus/prometheus.yml
diff -y podman/scenario1/deployment/prometheus.yaml podman/scenario2/deployment/prometheus.yaml
diff -y podman/scenario1/config/grafana/provisioning/datasources/all.yml podman/scenario2/config/grafana/provisioning/datasources/all.yml
```

## Scenario 3: Applying Object Storage Data Retention with rustFS, Thanos Store Gateway, and Thanos Compact
![scenario3.png](assets/scenario3.png)

Refer to the tutorial [README.md](deployments/scenario3/README.md) to provision the VMs, then you can follow the tutorial below.

### Deploying the environment

Go to the deployment [folder](podman/scenario3).
```bash
cd podman/scenario3
```

Deploy the rustfs in your laptop to represent external datacenter in your environment. Feel free to change the access key and secret key there:
```bash
bash deploy-rustfs.sh
```

Ensure that all VMs are able to reach internet. You might want to add extra firewalld policy to allow connection to host services in the network:
```bash
firewall-cmd --policy libvirt-to-host --permanent --add-port=8000-10000/tcp
firewall-cmd --reload
```

Then run the script to deploy the Prometheus with Thanos with Thanos Store Gateway, Thanos Compact and Grafana Environment:
```bash
bash deploy.sh
```

When needs to cleanup the environment, run this script:
```bash
bash cleanup.sh
```

### Explanation
You can see the differences between the configs by using this command:
```bash
cd $(git rev-parse --show-toplevel)
diff -y podman/scenario2/config/prometheus/prometheus.yml podman/scenario3/config/prometheus/prometheus.yml
diff -y podman/scenario2/deployment/prometheus.yaml podman/scenario3/deployment/prometheus.yaml
diff -y podman/scenario2/deployment/thanos_query.yaml podman/scenario3/deployment/thanos_query.yaml
```

## Scenario 4: Adding another region with the same configuration as Scenario 3
![scenario4.png](assets/scenario4.png)

Refer to the tutorial [README.md](deployments/scenario4/README.md) to provision the VMs, then you can follow the tutorial below.

Ensure that the networks are able to reach each other (from virbr1 to virbr2 and vice-versa). Ensure that all VMs are able to reach internet. You might want to add extra firewalld policy to allow connection to host services in the network:
```bash
firewall-cmd --policy libvirt-to-host --permanent --add-port=8000-10000/tcp
firewall-cmd --reload
```

Go to the deployment [folder](podman/scenario3).
```bash
cd podman/scenario4
```

Deploy the rustfs in your laptop to represent external datacenter in your environment. Then create the correspoding buckets. Feel free to change the access key and secret key there:
```bash
bash deploy-rustfs.sh
```

Then run the script to deploy the Prometheus with Thanos with Thanos Store Gateway, Thanos Compact and Grafana Environment:
```bash
bash deploy.sh
```

When needs to cleanup the environment, run this script:
```bash
bash cleanup.sh
```

### Explanation
You can see the differences between the configs by using this command:
```bash
cd $(git rev-parse --show-toplevel)
diff -y podman/scenario3/config/prometheus/prometheus.yml podman/scenario4/config/prometheus/prometheus.yml
diff -y podman/scenario3/deployment/prometheus.yaml podman/scenario4/deployment/prometheus.yaml
diff -y podman/scenario3/deployment/thanos_query.yaml podman/scenario4/deployment/thanos_query.yaml
```

## Extra Scenario: Deploy Prometheus and Thanos with Kubernetes and combining it with Scenario 4

Refer to the tutorial [README.md](deployment-kubernetes/README.md) to Deploy the prometheus and thanos.