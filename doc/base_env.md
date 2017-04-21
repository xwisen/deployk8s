# 基础镜像和环境准备
1. 基础镜像(二进制文件)(以1.6.1为例):
  * 可以从[kubernetes release server](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md)获得的(一般需要下载server包即可,解压文件后,使用docker load 命令把tar包load成可用镜像(如有需要打上自己想要的tag)。示例: `docker load -i kube-apiserver.tar`):
```shell
  gcr.io/google_containers/kube-apiserver:6987e76bea391a234a856fbdac637d66-v1.6.1
  gcr.io/google_containers/kube-controller-manager:27b2a3c3a09e6d502e56d7abc69dc8c9-v1.6.1
  gcr.io/google_containers/kube-scheduler:67021c49b24e106a323b398aa7ee95a2-v1.6.
  gcr.io/google_containers/kube-proxy:d9f201c130ce77ce273f486e147f0ee1-v1.6.1
  kubectl/kubelet
```
  * 其他镜像(二进制文件)
```shell  
  docker pull quay.io/coreos/etcd:v3.0.17 && docker tag quay.io/coreos/etcd:v3.0.17 gcr.io/coreos/etcd:v3.0.17
  docker pull gcr.io/google_containers/pause:3.0
```
  * 插件镜像(二进制文件)
  * 网络组件镜像(二进制文件)
2. 日志目录/文件创建/hosts设置
```shell
pssh -i -t 1200 -h /etc/nhosts mkdir -vp /data/logs/base /data/kubernetes/manifests /data/logs/app /data/etcd/data
pssh -i -t 1200 -h /etc/nhosts touch /data/logs/base/{etcd.log,kube-apiserver.log,kube-controller-manager.log,kube-scheduler.log,kube-proxy.log,flannel.log}
```
<!--
pscp.pssh -r -h /etc/nhosts /etc/hosts /etc/hosts
-->
3. 确保所有节点[docker](/base/docker.service)服务正常运行
