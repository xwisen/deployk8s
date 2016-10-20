#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# create a flannel network in etcd
while ! [ -f /flannel_network.lock ]; do
    if curl http://20.26.2.110:4001/v2/keys/kubernetes/network/config | grep -q action; then
        touch /flannel_network.lock
    else
        curl -X PUT -d value='{ "Network": "172.17.0.0/16", "Backend": { "Type": "vxlan", "VNI": 1 } }' http://20.26.2.110:4001/v2/keys/kubernetes/network/config
    fi
    sleep 5
done

# make this as a daemon
while true; do
  sleep 3600
done
