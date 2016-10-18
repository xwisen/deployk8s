FROM reg.dnt:5000/haproxy:1.6.9-alpine

MAINTAINER xwisen <1031649164@qq.com>

ADD ./haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

CMD ['haproxy','-f','/usr/local/etc/haproxy/haproxy.cfg']
