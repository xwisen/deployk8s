FROM reg.dnt:5000/alterway/keepalived:1.2

MAINTAINER xwisen <1031649164@qq.com>

ADD ./* /etc/keepalived/
ADD ./entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
