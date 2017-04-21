# master节点部署
1. 运行kubelet服务。centos7.2 systemd service文件可参考[master kubelet.service](/base/master/kubelet.service)
> [kubelet.service](/base/master/kubelet.service)需要修改:

```
/usr/local/bin/kubelet //二进制路径
--pod-infra-container-image= //自己的基础镜像
```
<!--
pscp.pssh -r -h /etc/nhosts ./kubelet /usr/local/bin/
pscp.pssh -r -h /etc/nhosts ./kubelet.service /usr/lib/systemd/system/
pssh -i -h /etc/nhosts "systemctl daemon-reload && systemctl enable kubelet && systemctl start kubelet"
-->
> **再次确保docker/kubelet服务处于running状态，下面开始安装etcd以及kubernetes master服务组件**<br>
2. 部署etcd集群: 在每个master节点上启动etcd服务，并配置为集群模式。[etcd.yaml](/base/master/etcd.yaml)需要修改字段如下:
```yaml
image: gcr.io/coreos/etcd:v3.0.17//自己镜像名字
env:
- name: NAME
  value: master3 //本etcd名字
- name: ADDR
  value: 20.26.28.85//本etcd ip
- name: MASTER1
  value: 20.26.28.83//etcd1 ip
- name: MASTER2
  value: 20.26.28.84//etcd2 ip
- name: MASTER3
  value: 20.26.28.85//etcd3 ip
volume:
- hostPath:
  path: /data/etcd/data //etcd数据
  name: varetcd
- hostPath:
  path: /data/logs/base/etcd.log //日志外挂路径，需确认宿主机是否存在该文件
  name: logfile
```
  * 修改好之后将yaml文件拷贝到kubelet配置`--pod-manifest-path=/data/kubernetes/manifests`所在目录下
  * 部署完之后使用`etcdctl member list` 命令确认etcd集群是否就绪。
3. 部署kube-apiserver: 在每个master节点上部署kube-apiserver服务。[kube-apiserver.yaml](/base/master/kube-apiserver.yaml)需要修改字段如下:
```yaml
image: gcr.io/google_containers/kube-apiserver:6987e76bea391a234a856fbdac637d66-v1.6.1//自己镜像名字
volume:
- hostPath:
  path: /data/logs/base/kube-apiserver.log //日志外挂路径，需确认宿主机是否存在该文件
  name: logfile
```
  * 修改好之后将yaml文件拷贝到kubelet配置`--pod-manifest-path=/data/kubernetes/manifests`所在目录下
4. 部署kube-controller-manager: 在每个master节点上部署kube-controller-manager服务。[kube-controller-manager.yaml](/base/master/kube-controller-manager.yaml)需要修改字段如下:
```yaml
image: gcr.io/google_containers/kube-controller-manager:27b2a3c3a09e6d502e56d7abc69dc8c9-v1.6.1//自己镜像名字
volume:
- hostPath:
  path: /data/logs/base/kube-controller-manager.log //日志外挂路径，需确认宿主机是否存在该文件
  name: logfile
```
  * 修改好之后将yaml文件拷贝到kubelet配置`--pod-manifest-path=/data/kubernetes/manifests`所在目录下
5. 部署kube-scheduler: 在每个master节点上部署kube-scheduler服务。[kube-scheduler.yaml](/base/master/kube-scheduler.yaml)需要修改字段如下:
```yaml
image: gcr.io/google_containers/kube-scheduler:67021c49b24e106a323b398aa7ee95a2-v1.6.1//自己镜像名字
volume:
- hostPath:
  path: /data/logs/base/kube-scheduler.log //日志外挂路径，需确认宿主机是否存在该文件
  name: logfile
```
  * 修改好之后将yaml文件拷贝到kubelet配置`--pod-manifest-path=/data/kubernetes/manifests`所在目录下
> 到这里，kubernetes相关组件都已经安装完毕,执行如下命令确认集群状态是否正确。如有错请至`/data/logs/base/`目录下查看日志:
```shell
[root@csv-xzcs01 master]# kubectl get cs
NAME                 STATUS    MESSAGE              ERROR
scheduler            Healthy   ok                   
controller-manager   Healthy   ok                   
etcd-0               Healthy   {"health": "true"}   
[root@csv-xzcs01 master]# kubectl get pod --namespace=system
NAME                                 READY     STATUS    RESTARTS   AGE
etcd-server-csv-xzcs01               1/1       Running   0          11m
etcd-server-csv-xzcs02               1/1       Running   0          8m
etcd-server-csv-xzcs03               1/1       Running   0          8m
kube-apiserver-csv-xzcs01            1/1       Running   0          12m
kube-apiserver-csv-xzcs02            1/1       Running   0          8m
kube-apiserver-csv-xzcs03            1/1       Running   0          8m
kube-controller-manager-csv-xzcs01   1/1       Running   1          5m
kube-controller-manager-csv-xzcs02   1/1       Running   2          5m
kube-controller-manager-csv-xzcs03   1/1       Running   0          5m
kube-scheduler-csv-xzcs01            1/1       Running   0          1m
kube-scheduler-csv-xzcs02            1/1       Running   0          1m
kube-scheduler-csv-xzcs03            1/1       Running   1          3m
```
