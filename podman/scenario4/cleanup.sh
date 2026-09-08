#!/bin/bash

### TODO: copy config and deployments via SCP and restart it when necessary.

GRAFANA_SERVER=192.168.100.30

ID_PROMETHEUS1_SERVER=192.168.100.10
ID_PROMETHEUS2_SERVER=192.168.100.20
ID_THANOS_STOREGW_SERVER=192.168.100.40

SG_PROMETHEUS1_SERVER=192.168.101.10
SG_PROMETHEUS2_SERVER=192.168.101.20
SG_THANOS_STOREGW_SERVER=192.168.101.40

# Cleanup Grafana Configs
ssh root@$GRAFANA_SERVER systemctl stop grafana
ssh root@$GRAFANA_SERVER rm -rf /opt/{config,deployment,data}
ssh root@$GRAFANA_SERVER rm -f /etc/containers/systemd/grafana.kube
ssh root@$GRAFANA_SERVER systemctl daemon-reload

# Cleanup Thanos Query Configs
ssh root@$GRAFANA_SERVER systemctl stop thanos_query
ssh root@$GRAFANA_SERVER rm -rf /opt/{config,deployment,data}
ssh root@$GRAFANA_SERVER rm -f /etc/containers/systemd/thanos_query.kube
ssh root@$GRAFANA_SERVER systemctl daemon-reload

cleanup_thanos(){
# Cleanup Thanos Store Gateway and Thanos Compact Configs
ssh root@$THANOS_STOREGW_SERVER systemctl stop thanos_storegw thanos_compact
ssh root@$THANOS_STOREGW_SERVER rm -rf /opt/{config,deployment,data}
ssh root@$THANOS_STOREGW_SERVER rm -rf /etc/containers/systemd/thanos*.kube
ssh root@$THANOS_STOREGW_SERVER systemctl daemon-reload
}

# Cleanup Prometheus Configs
cleanup_prometheus() {
ssh root@$PROMETHEUS_SERVER systemctl stop prometheus
ssh root@$PROMETHEUS_SERVER rm -rf /opt/{config,deployment,data}
ssh root@$PROMETHEUS_SERVER rm -f /etc/containers/systemd/prometheus.kube
ssh root@$PROMETHEUS_SERVER systemctl daemon-reload
}

PROMETHEUS_SERVER=$ID_PROMETHEUS1_SERVER
cleanup_prometheus

PROMETHEUS_SERVER=$ID_PROMETHEUS2_SERVER
cleanup_prometheus

PROMETHEUS_SERVER=$SG_PROMETHEUS1_SERVER
cleanup_prometheus

PROMETHEUS_SERVER=$SG_PROMETHEUS2_SERVER
cleanup_prometheus

THANOS_STOREGW_SERVER=$ID_THANOS_STOREGW_SERVER
cleanup_thanos

THANOS_STOREGW_SERVER=$SG_THANOS_STOREGW_SERVER
cleanup_thanos