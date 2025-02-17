#!/bin/bash

echo ".........----------------#################._.-.-INSTALL HELM CHARTS -.-._.#################----------------........."

# Add helm chart repos for opensearch & fluent-bit
microk8s helm3 repo add opensearch https://opensearch-project.github.io/helm-charts/
microk8s helm3 repo add fluent https://fluent.github.io/helm-charts
microk8s helm3 repo update

# Install opensearch & Create namespace app
microk8s helm3 upgrade --install opensearch opensearch/opensearch -f /vagrant/helm/opensearch-values.yaml --namespace app --create-namespace
microk8s helm3 upgrade --install opensearch-dashboards opensearch/opensearch-dashboards --namespace app

# Install fluent-bit
microk8s helm3 upgrade --install fluent-bit fluent/fluent-bit -f /vagrant/helm/fluent-bit-values.yaml --namespace app

echo ".........----------------#################._.-.-INSTALLING AIOOPS & UNHEALTHY APPS -.-._.#################----------------........."
kubectl apply -f /vagrant/manifests/aiops-nexus-deployment.yaml
kubectl apply -f /vagrant/manifests/unhealthy-app-deployment.yaml
kubectl apply -f /vagrant/manifests/ingress-nginx.yaml

