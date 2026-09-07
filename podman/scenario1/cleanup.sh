#!/bin/bash

### TODO: copy config and deployments via SCP and restart it when necessary.

GRAFANA_SERVER=192.168.100.30
PROMETHEUS_SERVER=192.168.100.10

# Cleanup Grafana Configs
ssh root@$GRAFANA_SERVER systemctl stop grafana
ssh root@$GRAFANA_SERVER rm -rf /opt/{config,deployment,data}
ssh root@$GRAFANA_SERVER rm -f /etc/containers/systemd/grafana.kube

# Deploy Prometheus Configs
ssh root@$PROMETHEUS_SERVER systemctl stop prometheus
ssh root@$PROMETHEUS_SERVER rm -rf /opt/{config,deployment,data}
ssh root@$PROMETHEUS_SERVER rm -f /etc/containers/systemd/prometheus.kube

