#!/bin/bash

apt update -y

curl -sfL https://get.k3s.io | sh -s - \
  --disable traefik \
  --disable servicelb \
  --disable metrics-server
