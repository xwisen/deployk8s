#!/bin/bash
/usr/sbin/keepalived -P -C -d -D -S 7 -f /etc/keepalived/keepalived.conf --dont-fork --log-console

