#!/usr/bin/env bash

if [[ -n "${1}" ]]; then
  KUBECONFIG=$KUBECONFIG:$1 kubectl config view --flatten > /tmp/new_config
  echo "New kube config created on /tmp/new_config"
else
  echo "You need to pass the new kubeconf that you want to merge with the current one"
fi
