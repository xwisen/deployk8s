#!/bin/sh
set -e
echo "start confd ++++++++++++++++++++"
confd -interval 10 -backend "etcd" -confdir "/etc/confd" -watch -log-level debug -node http://$ETCD_HOST:14001 -config-file /etc/confd/conf.d/haproxy.toml
