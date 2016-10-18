 # description: An example of notify script
#
vip=172.17.7.88
contact='root@localhost'
notify() {
    mailsubject="`hostname` to be $1: $vip floating"
    mailbody="`date '+%F %H:%M:%S'`: vrrp transition, `hostname` changed to be $1"
    echo $mailbody | mail -s "$mailsubject" $contact
}
case "$1" in
    master)
        #notify master
        /etc/rc.d/init.d/haproxy start
        exit 0
    ;;
    backup)
        #notify backup
        /etc/rc.d/init.d/haproxy stop
        exit 0
    ;;
    fault)
        #notify fault
        /etc/rc.d/init.d/haproxy stop
        exit 0
    ;;
    *)
        echo 'Usage: `basename $0` {master|backup|fault}'
        exit 1
    ;;
esac 
