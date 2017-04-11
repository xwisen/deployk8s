<!--haproxy_keepalived.md-->
# 使用haproxy负载减轻单个kube-apiserver压力，并使用keepalived保证高可用
在每个master节点上部署haproxy + keepalived服务。
* keepalived 部分功能需要内核支持:
```shell
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
lsmod | grep ip_vs
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.ip_nonlocal_bind=1
```
* keepalived 配置文件每个节点都不一样.示例: [主](/base/haka/keepalived/keepalived.conf.master)--[备1](/base/haka/keepalived/keepalived.conf.backup1)--[备2](/base/haka/keepalived/keepalived.conf.backup2)
* [haproxy-keepalived.yaml](/base/haka/haproxy-keepalived.yaml)需要修改字段如下:
```yaml
image:[自己镜像名字,haproxy 和 keepalived都需要修改]
volumes:
- hostPath:
    path: /etc/haproxy/haproxy.cfg [haproxy 配置文件位置]
  name: haproxy-cfg
  - hostPath:
    path: /etc/keepalived [keepalived 配置文件位置]
  name: keepalived-cfg
  - hostPath:
    path: /etc/keepalived/entrypoint.sh [entrypoint.sh 文件位置]
  name: entrypoint
```
  * [haproxy.cfg](/base/haka/haproxy/haproxy.cfg)文件中后端实例信息需要修改。示例文件中对kube-apiserver和etcd都做了负载均衡。
  * [haproxy](/base/haka/haproxy/Dockerfile) 和 [keepalived](/base/haka/keepalived/Dockerfile) 镜像制作请参考其Dockerfile,基础镜像根据后缀可在hub上找到。
  * 修改好之后将yaml文件拷贝到kubelet配置`--config=/data/kubernetes/manifests`所在目录下
