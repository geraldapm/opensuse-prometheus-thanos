# Extra tutorial for Kubernetes

## Prerequisites
- Active Kubernetes Cluster. You can follow the tutorial below to create your desired Kubernetes Distribution
[RKE2](https://github.com/geraldapm/microos-rke2)
[K3S](https://github.com/geraldapm/microos-k3s)

- If you are using cilium, ensure that this configuration is applied to be able to reach nodePort services from floating IP -> https://github.com/cilium/cilium/issues/37691#issuecomment-4253175437
```bash
kubectl -n kube-system edit configmap cilium-config
```
```
...omitted
  nodeport-addresses: 192.168.103.0/24
...omitted
```
```bash
kubectl rollout restart ds -n kube-system cilium
```

## Setup rustfs as Object Storage provider

Deploy the rustfs in your laptop to represent external datacenter in your environment. Then create the correspoding buckets. Feel free to change the access key and secret key there:
```bash
bash deploy-rustfs.sh
```

## Deploying Node Exporter
- Ensure you have the storage provider. Use local-path-provisioner if you have no storage provider for testing
```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
```

- Ensure that you deploy the Node Exporter DaemonSet using this URL:
```bash
kubectl create namespace monitoring
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/heads/main/manifests/nodeExporter-serviceAccount.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/heads/main/manifests/nodeExporter-clusterRole.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/heads/main/manifests/nodeExporter-clusterRoleBinding.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/heads/main/manifests/nodeExporter-daemonset.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/heads/main/manifests/nodeExporter-service.yaml
```

## Deploying Prometheus Operator
- Then install the Prometheus Operator for managing the prometheus instances
```bash
wget https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.94.0/bundle.yaml
sed -i 's+namespace: default+namespace: monitoring+g' bundle.yaml
kubectl apply --server-side -f bundle.yaml
```

- Apply the Node Exporter serviceMonitor to dynamically scrape the Node Exporter Metrics from [node_exporter-servicemonitor.yaml](manifests/node_exporter-servicemonitor.yaml)
```bash
kubectl apply -f manifests/node_exporter-servicemonitor.yaml
```

## Setup secret for S3 access
- Create the config file
```bash
vi bucket-config.yaml
```
```yaml
type: s3
config:
  bucket: gpmbucketeu
  endpoint: "192.168.103.1:9000"
  insecure: true
  access_key: gpmrustfs
  secret_key: 0255ec0a-72ee-448c-8823-2c652fc11a13
```
- Create secret from config file
```bash
kubectl -n monitoring create secret generic thanos-bucket-config --from-file=bucket-config.yaml=bucket-config.yaml
```

## Deploying Prometheus (prometheus-eu instance)
- Setup the Prometheus Instance (2 replicas) by applying [prometheus-eu.yaml](manifests/prometheus-eu.yaml) manifest:
```bash
kubectl apply -f manifests/prometheus-eu.yaml
```

## Deploying Thanos Query
Apply the [thanos-query.yaml](manifests/thanos-query.yaml) manifest:
```bash
kubectl apply -f manifests/thanos-query.yaml
```

## Deploying Thanos Store Gateway
The thanos store gateway will be deployed with two shards, each shards takes half of all block stored inside the block storage with hashmod algorithm (divide by two).

### Shard 0/2
Apply the [thanos-store-shard-0.yaml](manifests/thanos-store-shard-0.yaml) manifest:
```bash
kubectl apply -f manifests/thanos-store-shard-0.yaml
```
### Shard 1/2
Apply the [thanos-store-shard-1.yaml](manifests/thanos-store-shard-1.yaml) manifest:
```bash
kubectl apply -f manifests/thanos-store-shard-1.yaml
```

## Deploying Thanos Compactor
Apply the [thanos-compact.yaml](manifests/compact.yaml) with manifest:
```bash
kubectl apply -f manifests/thanos-compact.yaml
```

## Modifying the Central Thanos Query config on gpmidgrafana (Scenario 4)
- ssh to the server and edit the /opt/deployment/thanos_query.yaml
```bash
vi /opt/deployment/thanos_query.yaml
```
- Add the additional endpoint (192.168.103.99:32110) for reaching the Kubernetes Thanos Query grpc port
```
...omitted
        - "--endpoint=gpmsgprome1:10900"
        - "--endpoint=gpmsgprome2:10900"
        - "--endpoint=gpmsgthanos:10902"
        - "--endpoint=192.168.103.99:32110"
```
```
...omitted
        - "--query.replica-label=prometheus_replica"
```
- Then Restart the Thanos Query
```bash
systemctl restart thanos_query
```
- Verify on Grafana dashboard