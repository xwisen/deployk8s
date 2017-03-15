# 注意事项
# master 节点部署(做高可用必须保证master节点为2个及其以上，推荐3个节点)
1. 去github上下载适合自己环境的安装包，地址:[kubernetes release](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md),一般需要下载server包即可
2. 解压文件后,使用docker load 命令把tar包load成可用镜像(如有需要打上自己想要的tag)。示例: `docker load -i kube-apiserver.tar`
3. 下载etcd镜像(推荐使用v3),(如有需要打上自己想要的tag)。示例: `docker pull quay.io/coreos/etcd:v3.0.17`
4. 确保docker/kubelet服务正常，centos7.2 systemd service文件可参考/base目录下service文件
5. 部署etcd集群: 在每个master节点上启动etcd服务，并配置为集群模式。[etcd.yaml](/base/master/etcd.yaml)需要修改字段如下:
	---
	   image:[自己镜像名字]
	   env:[所有字段]
	   volume:
	     - hostPath:
      	        path: /data/etcd/data
    	        name: varetcd
	     - hostPath:
      	        path: /data/logs/base/etcd.log [需要事先在宿主机上创建好]
    	        name: logfile
	---
	* 修改好之后将yaml文件拷贝到kubelet配置`--config=/data/kubernetes/manifests`所在目录下
	* 部署完之后使用`etcdctl member list` 命令确认etcd集群是否就绪。
6. 部署kube-apiserver: 在每个master节点上部署kube-apiserver服务。[kube-apiserver.yaml](/base/master/kube-apiserver.yaml)需要修改字段如下:
	---
	   image:[自己镜像名字]
	   volume:
	   - hostPath:
      	      path: /data/logs/base/kube-apiserver.log [需要事先在宿主机上创建好]
    	      name: logfile
	---
	* 修改好之后将yaml文件拷贝到kubelet配置`--config=/data/kubernetes/manifests`所在目录下
7. 部署kube-controller-manager: 在每个master节点上部署kube-controller-manager服务。[kube-controller-manager.yaml](/base/master/kube-controller-manager.yaml)需要修改字段如下:
	---
	   image:[自己镜像名字]
	   volume:
	   - hostPath:
      	      path: /data/logs/base/kube-controller-manager.log [需要事先在宿主机上创建好]
    	      name: logfile
	---
	* 修改好之后将yaml文件拷贝到kubelet配置`--config=/data/kubernetes/manifests`所在目录下
8. 部署kube-scheduler: 在每个master节点上部署kube-scheduler服务。[kube-scheduler.yaml](/base/master/kube-scheduler.yaml)需要修改字段如下:
	---
	   image:[自己镜像名字]
	   volume:
	   - hostPath:
      	      path: /data/logs/base/kube-scheduler.log [需要事先在宿主机上创建好]
    	      name: logfile
	---
	* 修改好之后将yaml文件拷贝到kubelet配置`--config=/data/kubernetes/manifests`所在目录下
9. 部署haproxy + keepalived: 在每个master节点上部署haproxy + keepalived服务。
* keepalived 部分功能需要内核支持:
```
	modprobe ip_vs
	modprobe ip_vs_rr
	modprobe ip_vs_wrr
	lsmod | grep ip_vs [查看模块是否正确插入]
	sysctl -w net.ipv4.ip_forward=1
	sysctl -w net.ipv4.ip_nonlocal_bind=1
```
* keepalived 配置文件每个都不一样.示例: [主](/base/haka/keepalived/keepalived.conf.master)[备1](/base/haka/keepalived/keepalived.conf.backup1)[备2](/base/haka/keepalived/keepalived.conf.backup2)
[haproxy-keepalived.yaml](/base/haka/haproxy-keepalived.yaml)需要修改字段如下:
	---
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
	---
	* [haproxy.cfg](/base/haka/haproxy/haproxy.cfg)文件中后端实例信息需要修改。示例文件中对kube-apiserver和etcd都做了负载均衡。
	* [haproxy](/base/haka/haproxy/Dockerfile) 和 [keepalived](/base/haka/keepalived/Dockerfile) 镜像制作请参考其Dockerfile,基础镜像根据后缀可在hub上找到。
	* 修改好之后将yaml文件拷贝到kubelet配置`--config=/data/kubernetes/manifests`所在目录下

# agent 节点部署

# 增强插件部署
# 网络方案部署
