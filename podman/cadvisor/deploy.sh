#!/bin/bash

GRAFANA_SERVER=192.168.100.30
PROMETHEUS1_SERVER=192.168.100.10
PROMETHEUS2_SERVER=192.168.100.20
THANOS_STOREGW_SERVER=192.168.100.40

# Deploy cAdvisor

deploy_cadvisor() {
echo -e "Deploying cadvisor configs on $1 ..."
ssh root@$1 mkdir -p /etc/containers/systemd
ssh root@$1 mkdir -p /opt/{config,deployment,data}/grafana
scp systemd/cadvisor.kube root@$1:/etc/containers/systemd/cadvisor.kube
scp deployment/cadvisor.yaml root@$1:/opt/deployment/cadvisor.yaml
ssh root@$1 systemctl daemon-reload
ssh root@$1 systemctl enable --now podman.socket
ssh root@$1 systemctl restart cadvisor
echo -e
}

deploy_cadvisor $GRAFANA_SERVER
deploy_cadvisor $PROMETHEUS1_SERVER
deploy_cadvisor $PROMETHEUS2_SERVER
deploy_cadvisor $THANOS_STOREGW_SERVER
