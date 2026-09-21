# Extra tutorial for Kubernetes

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

- Apply the Node Exporter serviceMonitor to dynamically scrape the Node Exporter Metrics from the Node Exporter Daemonsets
```bash
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/heads/main/manifests/nodeExporter-serviceMonitor.yaml
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
- Setup the Prometheus Instance (2 replicas)
```bash
vi prometheus-eu.yaml
```
```yaml
---
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  namespace: monitoring
  name: prometheus-eu
  labels:
    prometheus: prometheus-eu
spec:
  replicas: 2
  serviceAccountName: prometheus
  serviceMonitorNamespaceSelector: {}
  serviceMonitorSelector:
    matchLabels:
      app.kubernetes.io/part-of: kube-prometheus
  thanos:
    image: docker.io/thanosio/thanos:v0.42.4
    objectStorageConfig:
      key: bucket-config.yaml
      name: thanos-bucket-config
  securityContext:
    fsGroup: 2000
    runAsGroup: 2000
    runAsNonRoot: true
    runAsUser: 2000
  storage:
    volumeClaimTemplate:
      spec:
        accessModes:
          - ReadWriteOnce
        storageClassName: local-path
        resources:
          requests:
            storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  labels:
    prometheus: prometheus-eu
  name: prometheus-eu
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - name: web
    port: 9090
    targetPort: web
    nodePort: 32113
  selector:
    prometheus: prometheus-eu
---
apiVersion: v1
automountServiceAccountToken: false
kind: ServiceAccount
metadata:
  labels:
    prometheus: prometheus-eu
  name: prometheus
  namespace: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/metrics
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources:
  - configmaps
  verbs: ["get"]
- apiGroups:
  - discovery.k8s.io
  resources:
  - endpointslices
  verbs: ["get", "list", "watch"]
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    prometheus: prometheus-eu
  name: prometheus-k8s
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
```
- Then apply the manifest
```bash
kubectl apply -f prometheus-eu.yaml
```

## Deploying Thanos Query
TODO