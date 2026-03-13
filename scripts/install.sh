#!/bin/bash

apt update -y

curl -sfL https://get.k3s.io | sh -s - \
  --disable traefik \
  --disable servicelb \
  --disable metrics-server

sleep 20

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

sleep 30

kubectl apply -f /home/ubuntu/cloud-sec-lab/k8s/web.yaml
kubectl apply -f /home/ubuntu/cloud-sec-lab/k8s/ingress.yaml
