FROM reg.dnt:5000/haproxy:1.6.9-alpine
MAINTAINER xwisen <1031649164@qq.com>

ADD ./confd /usr/local/sbin/
ADD ./docker-entrypoint.sh /
RUN chmod +x /usr/local/sbin/confd && chmod +x /docker-entrypoint.sh && touch /var/run/haproxy.pid
COPY ./etc/ /etc/

CMD ["confd"] 
