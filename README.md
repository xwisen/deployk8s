# deployk8s
> - 有问题请上[dockone.io](http://dockone.io/people/xwisen)找我
> - 本人从事容器编排方面工作，本项目算是一些小笔记。内容包括热门的kubernetes、mesos编排工具及其周边的网络、存储、监控等方案(ps: 仅供参考，示例`yaml`文件优先).
## 部署说明文档
> [正在写---](/doc/install.md)
## 目录结构说明
> #####Attentions: 
* 版本说明: 操作系统为centos 7.2,docker 版本为1.10+(目前1.12.6)，kubernetes原本为1.4.6，后kubernetes核心组件升级到1.5.1,但是插件没有更新。
* 对于kubernetes及其周边组件，我的原则是: `能容器化的一定不直接跑宿主机，能通过应用方式部署的绝对不跑static pod`
* - [x] 表示需要关注
* - [ ] 表示不需要关注

- [ ] [/addons](/addons) `包含kubernetes一些插件，大都以deployment/replication方式部署`
  - [x] [/dashboard](/addons/dashboard) `kubernetes官方提供的dashboard`
  - [x] [/dns](/addons/dns) `kubernetes官方提供的dns插件`
  - [x] [/haconfd](/addons/haconfd) `haproxy + confd 用来做应用外部访问，原理类似ingress，目前只能通过static pod方式部署，路由规则模板需要手工配置`
  - [ ] [/ingress](/addons/ingress) `kubernetes 中应用外部访问的另一种方式，具体请参考官方文档`
  - [x] [/prometheus](/addons/prometheus) `prometheus 是一个流行的监控告警工具，与kubernetes同属CNCF基金会`
- [x] [/base](/base) `base 目录包含kubernetes及其高可用方案核心组件，搭建集群青葱这里开始`
  - [x] [/agent](/base/agent) `kubernetes agent节点服务,包含kubelet(systemd service)和kube-proxy(static pod)`
  - [x] [/haka](/base/haka) `haproxy + keepalived(systemd service) kube-apiserver高可用关键组件`
  - [x] [/master](/base/master) `kubernetes master 节点服务,包含kubelet(systemd service)和etcd/kube-apiserver/kube-controller-manager/kube-scheduler(static pod)`
  - [ ] [/config.yaml](/base/config.yaml) `需要镜像删除时，registry配置文件`
  - [x] [/docker.service](/base/docker.service) `docker(systemd service)公共基础服务配置示例`
  - [x] [/k8s-log.cron](/base/k8s-log.cron) `日志处理定时脚本`
  - [ ] [/tools.sh](/base/tools.sh) `镜像仓库操作脚本`
- [ ] [/doc](/doc)
- [ ] [/images](/images)
- [ ] [/network](/network) `kubernetes中可选的容器网络方案`
  - [x] [/calico](/network/calico)  `calico 网络方案,部署方式为daemonset，默认ippool开启了IPIP[ps: 推荐使用]`
  - [x] [/flannel](/network/flannel) `flannel网络方案，部署方式为static pod(部署成功后请使用restart_docker.sh脚本重启docker)(ps: 正考虑用daemonset部署)`
- [ ] [/storage](/storage) `kubernetes中可选的容器存储方案`
  - [x] [/rbd](/storage/rbd) `kubernetes 与ceph rbd对接示例文件(ps: yaml文件优先)`
## 生产高可用kubernetes组件架构图
![Architecture](images/Architecture.png)
