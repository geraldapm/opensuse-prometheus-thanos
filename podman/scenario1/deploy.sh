#!/bin/bash

### TODO: copy config and deployments via SCP and restart it when necessary.

GRAFANA_SERVER=192.168.100.30
PROMETHEUS_SERVER=192.168.100.10

# Deploy Grafana Configs
echo -e "Deploying grafana configs on $GRAFANA_SERVER..."
ssh root@$GRAFANA_SERVER mkdir -p /etc/containers/systemd
ssh root@$GRAFANA_SERVER mkdir -p /opt/{config,deployment,data}/grafana
scp systemd/grafana.kube root@$GRAFANA_SERVER:/etc/containers/systemd/grafana.kube
scp deployment/grafana.yaml root@$GRAFANA_SERVER:/opt/deployment/grafana.yaml
scp -r config/grafana root@$GRAFANA_SERVER:/opt/config/
ssh root@$GRAFANA_SERVER systemctl daemon-reload
ssh root@$GRAFANA_SERVER systemctl restart grafana
echo -e

# Deploy Prometheus Configs
echo -e "Deploying prometheus configs on $PROMETHEUS_SERVER..."
ssh root@$PROMETHEUS_SERVER mkdir -p /etc/containers/systemd
ssh root@$PROMETHEUS_SERVER mkdir -p /opt/{config,deployment,data}/prometheus
scp systemd/prometheus.kube root@$PROMETHEUS_SERVER:/etc/containers/systemd/prometheus.kube
scp deployment/prometheus.yaml root@$PROMETHEUS_SERVER:/opt/deployment/prometheus.yaml
scp -r config/prometheus root@$PROMETHEUS_SERVER:/opt/config/
ssh root@$PROMETHEUS_SERVER "mkdir -p /opt/data/prometheus && chmod 777 /opt/data/prometheus"
ssh root@$PROMETHEUS_SERVER "chown -R 1000:2000 /opt/data/prometheus/*"
ssh root@$PROMETHEUS_SERVER 'semanage fcontext -at container_file_t "/opt/data/prometheus(/.*)?"; restorecon -Rv /opt/data/prometheus'
ssh root@$PROMETHEUS_SERVER systemctl daemon-reload
ssh root@$PROMETHEUS_SERVER systemctl restart prometheus
echo -e