#!/bin/bash

echo ".........----------------#################._.-.-UPDATING UBUNTU 22.04 LTS-.-._.#################----------------........."
apt-get update -y
apt-get install ca-certificates curl -y
update-ca-certificates

echo ".........----------------#################._.-.-INSTALLING KUBERNETES (MIKROK8S)-.-._.#################----------------........."
HOME=/home/vagrant
apt-get update -y
snap install microk8s --classic
microk8s status --wait-ready
usermod -a -G microk8s vagrant
mkdir -p $HOME/.kube
chown -f -R vagrant:vagrant $HOME/.kube
newgrp microk8s

snap restart microk8s
microk8s status --wait-ready

# Generate a kubeconfig file for clients authenticating via OIDC
snap install kubectl --classic
microk8s config > $HOME/.kube/config

# Add kubectl alias to .bashrc for persistence
echo "alias helm='microk8s helm3'" >> $HOME/.bashrc
#echo "alias kubectl='microk8s kubectl'" >> $HOME/.bashrc
echo "alias k='kubectl'" >> $HOME/.bashrc

source $HOME/.bashrc

echo ".........----------------#################._.-.-ENABLE HOSTPATH-STORAGE -.-._.#################----------------........."
microk8s enable hostpath-storage

echo ".........----------------#################._.-.-ENABLE INGRESS -.-._.#################----------------........."
microk8s enable ingress

echo ".........----------------#################._.-.-ENABLE METRICS SERVER -.-._.#################----------------........."
microk8s enable metrics-server

echo ".........----------------#################._.-.-ENABLE KUBECTL AUTO-COMPLETION -.-._.#################----------------........."
echo 'source <(kubectl completion bash)' >> $HOME/.bashrc

# Remove unnecessary packages
echo ".........----------------#################._.-.-UNINSTALLING UNNECESSARY DEPENDENCIES-.-._.#################----------------........."
apt-get autoremove -y
