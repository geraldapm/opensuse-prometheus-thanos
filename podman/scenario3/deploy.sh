#!/bin/bash

### TODO: copy config and deployments via SCP and restart it when necessary.

GRAFANA_SERVER=192.168.100.30
PROMETHEUS1_SERVER=192.168.100.10
PROMETHEUS2_SERVER=192.168.100.20
THANOS_STOREGW_SERVER=192.168.100.40

# Deploy Grafana Configs
ssh root@$GRAFANA_SERVER mkdir -p /etc/containers/systemd
ssh root@$GRAFANA_SERVER mkdir -p /opt/{config,deployment,data}/grafana
scp systemd/grafana.kube root@$GRAFANA_SERVER:/etc/containers/systemd/grafana.kube
scp deployment/grafana.yaml root@$GRAFANA_SERVER:/opt/deployment/grafana.yaml
scp -r config/grafana root@$GRAFANA_SERVER:/opt/config/
ssh root@$GRAFANA_SERVER systemctl daemon-reload
ssh root@$GRAFANA_SERVER systemctl restart grafana

# Deploy Thanos Query Configs
ssh root@$GRAFANA_SERVER mkdir -p /etc/containers/systemd
scp systemd/thanos_query.kube root@$GRAFANA_SERVER:/etc/containers/systemd/thanos_query.kube
scp deployment/thanos_query.yaml root@$GRAFANA_SERVER:/opt/deployment/thanos_query.yaml
ssh root@$GRAFANA_SERVER systemctl daemon-reload
ssh root@$GRAFANA_SERVER systemctl restart thanos_query


# Deploy Thanos Store Gateway and Thanos Compact Configs
ssh root@$THANOS_STOREGW_SERVER mkdir -p /etc/containers/systemd

ssh root@$THANOS_STOREGW_SERVER mkdir -p /opt/{config,deployment,data}/thanos

ssh root@$THANOS_STOREGW_SERVER "mkdir -p /opt/data/thanos/{storedata,compactdata} && chmod 777 /opt/data/thanos/{storedata,compactdata}"
ssh root@$THANOS_STOREGW_SERVER 'semanage fcontext -at container_file_t "/opt/data/thanos/storedata(/.*)?"; restorecon -Rv /opt/data/thanos/storedata'
ssh root@$THANOS_STOREGW_SERVER 'semanage fcontext -at container_file_t "/opt/data/thanos/compactdata(/.*)?"; restorecon -Rv /opt/data/thanos/compactdata'

scp -r config/thanos root@$THANOS_STOREGW_SERVER:/opt/config/

scp systemd/thanos_storegw.kube root@$THANOS_STOREGW_SERVER:/etc/containers/systemd/thanos_storegw.kube
scp deployment/thanos_storegw.yaml root@$THANOS_STOREGW_SERVER:/opt/deployment/thanos_storegw.yaml
ssh root@$THANOS_STOREGW_SERVER systemctl daemon-reload
ssh root@$THANOS_STOREGW_SERVER systemctl restart thanos_storegw

scp systemd/thanos_compact.kube root@$THANOS_STOREGW_SERVER:/etc/containers/systemd/thanos_compact.kube
scp deployment/thanos_compact.yaml root@$THANOS_STOREGW_SERVER:/opt/deployment/thanos_compact.yaml
ssh root@$THANOS_STOREGW_SERVER systemctl daemon-reload
ssh root@$THANOS_STOREGW_SERVER systemctl restart thanos_compact


# Deploy Prometheus Configs
deploy_prometheus() {
ssh root@$PROMETHEUS_SERVER mkdir -p /etc/containers/systemd
ssh root@$PROMETHEUS_SERVER mkdir -p /opt/{config,deployment,data}/prometheus

scp systemd/prometheus.kube root@$PROMETHEUS_SERVER:/etc/containers/systemd/prometheus.kube

sed -i "s/promereplica/$1/g" config/prometheus/prometheus.yml

scp deployment/prometheus.yaml root@$PROMETHEUS_SERVER:/opt/deployment/prometheus.yaml
scp -r config/prometheus root@$PROMETHEUS_SERVER:/opt/config/
scp -r config/thanos root@$PROMETHEUS_SERVER:/opt/config/

sed -i "s/ $1/ promereplica/g" config/prometheus/prometheus.yml

ssh root@$PROMETHEUS_SERVER "mkdir -p /opt/data/prometheus && chmod 777 /opt/data/prometheus"
ssh root@$PROMETHEUS_SERVER 'semanage fcontext -at container_file_t "/opt/data/prometheus(/.*)?"; restorecon -Rv /opt/data/prometheus'

ssh root@$PROMETHEUS_SERVER systemctl daemon-reload
ssh root@$PROMETHEUS_SERVER systemctl restart prometheus
}

PROMETHEUS_SERVER=$PROMETHEUS1_SERVER
deploy_prometheus "prome1"

PROMETHEUS_SERVER=$PROMETHEUS2_SERVER
deploy_prometheus "prome2"
