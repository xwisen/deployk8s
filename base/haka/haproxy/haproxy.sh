docker rm -f haproxy &&
docker run -itd --name haproxy --net host -v /root/wz/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg reg.dnt:5000/haproxy:1.6.9-alpine  /usr/local/sbin/haproxy -p /run/haproxy.pid -f /usr/local/etc/haproxy/haproxy.cfg -d
