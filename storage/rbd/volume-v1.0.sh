# SHELL 
# ***********************************************
# 
#       Filename: volume-v1.0.sh
# 
#         Author: xwisen 1031649164@qq.com
#    Description: ---
#         Create: 2016-11-03 19:25:58
#  Last Modified: 2016-11-03 19:25:58
# ***********************************************



# usage: checkcmd cmd_name
function checkcmd() {
	if [[ -z $1 ]];then
		#echo "1:::please provide cmd need check ------"
		return 1
	fi
	if [[ -z `type $1` ]];then
		#echo "1:::command $1 is no in $PATH"
		return 1
	fi
	#echo "0:::"
}
# usage: checkcmdrbd
function checkcmdrbd() {
	if [[ -z `type rbd` ]];then
		#echo "1:::rbd command is no in $PATH"
		return 1
	fi
	
	debug=`rbd ls 2>&1`
	if [[ $? -ne 0 ]];then
		#echo "1:::command 'rbd ls' echo $debug, please check ceph.conf !"
		return 1
	fi
	#echo 0
	#echo "0:::"
}
#usage: rbd_create name size fs
#name 卷名
#size 卷大小(单位M)
#fs 文件系统类型
#返回值:0成功，1失败

function rbd_create {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 3 ]];then
		echo "1:::len(args) is not 3 ! please check ! "
		#echo "1:::usage: rbd_create name size fs"
		return 1
	fi
	#echo "start create a block device with command rbd ------"
	NAME=${1:-"xwisen"}
	SIZE=${2:-1024}
	FS=${3:-ext4}
	
	debug=`rbd create --pool k8s --image $NAME --size $SIZE 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::command 'rbd --pool k8s create --image $NAME --size $SIZE' echo '$debug', please check !"
		return 1
	fi
	dev=`rbd --pool k8s map $NAME 2>&1`
	if [[ -z `echo $dev | grep "dev"` ]];then
		echo "1:::command 'rbd --pool k8s map $NAME echo error : $dev'"	
		return 1
	fi
	if [[ -z `type mkfs.$FS` ]];then
		echo "1:::command 'mkfs.$FS'  is no in $PATH, please check"
		return 1
	fi
	debug=`mkfs.$FS $dev 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::command 'mkfs.$FS $dev' echo code $debug, please check !"
		return 1
	fi
	debug=`rbd --pool k8s unmap $dev 2>&1`
	if [[ $? != 0 ]];then
		echo "1:::command 'rbd --pool k8s unmap $dev' echo code $debug, please check !"
		return 1
	fi
	debug=`rbd --pool k8s status $NAME 2>&1`
	if [[ -n `echo $debug | grep "client"` ]];then
		echo "1:::device is still watching ,info is : $debug"
		return 1
	fi
	#echo "create a block device $NAME succeed, size is : $SIZE, filesystem is : $FS"
	echo "0:::create a block device : $NAME succeed, size is : $SIZE, filesystem is : $FS"
}

#usage: rbd_delete name
#name 需要删除的卷名
#返回值:0成功，1失败
function rbd_delete {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 1 ]];then
		echo "1:::len(args) is not 1 ! please check ! "
		#echo "1:usage: rbd_delete name"
		return 1
	fi	
	debug=`rbd --pool k8s status $1 2>&1`
	#echo $debug
	if [[ -n `echo $debug | grep "client"` ]];then
		echo "1:::device is still watching ,info is : $debug"
		return 1
	fi
	debug=`rbd --pool k8s rm --image $1 2>&1`
	if [[ $? != 0 ]];then
		echo "1:::command 'rbd --pool k8s rm --image $1' echo code $debug, please check !"
		return 1
	fi
	echo "0:::delete ablock device $1 succeed ------"
}

#usage: rbd_list
#列出所有卷
#返回值:0成功，一组卷名;1失败
function rbd_list {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 0 ]];then
		echo "1:::len(args) is not 0 ! please check ! "
		#echo "usage: rbd_list"
		return 1
	fi	
	debug=`rbd --pool k8s ls 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::rbd --pool k8s ls echo $debug, please check !"
		return 1
	fi
	echo "0:::$debug"
}
#usage: rbd_size name
#查询卷大小
#name 卷名
#返回值:卷大小(单位M)，其他值失败
#返回值:0成功，1失败
function rbd_size {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 1 ]];then
		echo "1:::len(args) is not 1 ! please check ! "
		#echo "usage: rbd_size name"
		return 1
	fi	
	debug=`rbd --pool k8s info $1 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::rbd --pool k8s info $1 echo $debug, please check !"
		return 1
	fi
	if [[ -z `echo $debug | grep "size" | awk '{print $2}'` ]];then
		echo "1:::$1 volume is not exists !"
		return 1
	fi
	#echo $debug
	debug=`echo $debug | grep "size" | awk '{print $5}' 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::awk rbd info echo $debug, please check !"
		return 1
	fi
	echo "0:::$debug"
}

#usage: rbd_resize image_name size
#卷扩容
#image_name 卷名
#size 扩容后大小
#返回值:0成功，1失败
function rbd_resize {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 2 ]];then
		echo "1:::len(args) is not 2 ! please check ! "
		#echo "1:::usage: rbd_resize image_name size"
		return 1
	fi
	debug=`rbd --pool k8s status $1 2>&1`
	if [[ -n `echo $debug | grep "client"` ]];then
		echo "1:::device is still watching ,info is : $debug"
		return 1
	fi
	debug=`rbd --pool k8s resize --image=$1 --size=$2 2>&1`
	if [[ $? -ne 0 ]]; then
		echo "1:::'rbd --pool k8s resize --image=$1 --size=$2' echo $debug, please check !\n"
		return 1
	fi
	dev=`rbd --pool k8s map $1 2>&1`
	if [[ $? -ne 0 ]]; then
		echo "1:::'rbd --pool k8s map $1' echo $dev, please check !\n"
		return 1
	fi
	debug=`resize2fs $dev 2>&1`
	if [[ $? -ne 0 ]]; then
		echo "1:::'resizefs' echo $debug, please check !\n"
		return 1
	fi
	debug=`rbd --pool k8s unmap $dev 2>&1`
	if [[ $? -ne 0 ]]; then
		echo "1:::'rbd --pool k8s unmap $dev' echo $debug, please check !\n"
		return 1
	fi	
	debug=`rbd --pool k8s status $1 2>&1`
	if [[ -n `echo $debug | grep "client"` ]];then
		echo "1:::device is still watching ,info is : $debug"
		return 1
	fi
	echo "0:::resize succeed"
}

#usage: rbd_mount rc_name rbd_name
#一个卷同时只能被一个容器挂载
#rc_name 容器名
#rbd_name 卷名
#返回值:0成功，1失败
function rbd_mount {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 2 ]];then
		echo "1:::len(args) is not 2 ! please check ! "
		#echo "usage: rbd_mount rc_name rbd_name mount_path"
		return 1
	fi
	debug=`rbd status $2 2>&1`
	if [[ -n `echo $debug | grep "client"` ]];then
		echo "1:::device is already watching ,info is : $debug"
		return 1
	fi
	#echo "setting env -------------"
	#PV_NAME
	PV_NAME=${2:-"pvtest"}
	#SIZE
	SIZE=${SIZE:-"100"}
	#RBD_IMAGE_NAME
	RBD_IMAGE_NAME=${2:-"rbdimagenametest"}
	#PVC_NAME
	PVC_NAME=${2:-"pvcnametest"}
	#RC_NAME
	RC_NAME=${1:-"rctest"}
	#CONTAINER_NAME
	CONTAINER_NAME=${1:-"containertest"}
	#IMAGE_NAME
	IMAGE_NAME=${IMAGE_NAME:-"reg.dnt:5000/nginx:1.10.0-alpine"}
	#MOUNT_PATH
	MOUNT_PATH=${MOUNT_PATH:-"/mnt"}
	
	#echo "creating /tmp/mount.yaml -------------"
	debug=`kubectl delete rc $1 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::kubectl delete rc $1 echo $?, please check !"
		return 1
	fi
	debug=`cat > /tmp/mount.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
data:
  key: T0dFME9UVTNaV1kwWVdVeE9UTTJPR014T1RrMVl6WTBaVGM1WkdJeQo= 
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: PV_NAME
  labels: 
    name: PV_NAME
spec:
    capacity:
        storage: SIZEGi
    accessModes:
        - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    rbd:
      monitors:
      - 20.26.28.13:6789
      - 20.26.28.14:6789
      - 20.26.28.15:6789
      user: admin
      pool: k8s
      image: RBD_IMAGE_NAME
      fsType: ext4,
      readOnly: true
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: PVC_NAME
  namespace: default
  labels: 
    name: PVC_NAME
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: SIZEGi
  selector:
    matchLabels:
      name: "PV_NAME"
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: RC_NAME
  namespace: default
  labels:
    kubernetes.io/cluster-service: "true"
spec:
  replicas: 1
  template:
    metadata:
      labels:
        kubernetes.io/cluster-service: "true"
    spec:
      nodeSelector:
        kubernetes.io/hostname: agent2
      containers:
      - name: CONTAINER_NAME
        image: IMAGE_NAME
        ports:
        - containerPort: 80
        volumeMounts:
          - name: t
            mountPath: MOUNT_PATH
      volumes:
        - name: t
          persistentVolumeClaim:
            claimName: PVC_NAME
EOF
2>&1
`
	if [[ $? -ne 0 ]];then
		echo "1:::create mount.yaml print: $debug, please check !"
		return 1
	fi

	#sed -i \ s/SIZE/$SIZE/g \/tmp/mount.yaml
	#echo "modify /tmp/mount.yaml -------------"
	debug=`sed -i \ s/PV_NAME/$PV_NAME/g \/tmp/mount.yaml && \
	sed -i \ s/SIZE/$SIZE/g \/tmp/mount.yaml && \
	sed -i \ s/RBD_IMAGE_NAME/$RBD_IMAGE_NAME/g \/tmp/mount.yaml && \
	sed -i \ s/PVC_NAME/$PVC_NAME/g \/tmp/mount.yaml && \
	sed -i \ s/RC_NAME/$RC_NAME/g \/tmp/mount.yaml && \
	sed -i \ s/CONTAINER_NAME/$CONTAINER_NAME/g \/tmp/mount.yaml && \
	sed -i \ s#IMAGE_NAME#$IMAGE_NAME#g \/tmp/mount.yaml && \
	sed -i \ s#MOUNT_PATH#$MOUNT_PATH#g \/tmp/mount.yaml 2>&1`

	if [[ $? -ne 0 ]];then
		echo "1:::modify mount.yaml print:\n $debug, please check !\n"
		return 1
	fi
	
	debug=`checkcmd kubectl 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmd kubectl print: $debug, please check !"
		return 1
	fi
	debug=`kubectl apply -f /tmp/mount.yaml`
	if [[ $? -ne 0 ]];then
		echo "1:::kubectl apply -f /tmp/mount.yaml print: $debug, please check !"
		return 1
	fi

	echo "0:::rbd_mount commmand send succeed !"
}

#usage: rbd_umount rc_name rbd_name
#rc_name 容器名
#rbd_name 卷名
#返回值:0成功，1失败
function rbd_umount {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 2 ]];then
		echo "1:::len(args) is not 2 ! please check ! "
		#echo "usage: rbd_umount rc_name rbd_name"
		return 1
	fi
	#echo "setting env -------------"
	#PV_NAME
	PV_NAME=${2:-"pvtest"}
	#SIZE
	SIZE=${SIZE:-"10"}
	#RBD_IMAGE_NAME
	RBD_IMAGE_NAME=${2:-"rbdimagenametest"}
	#PVC_NAME
	PVC_NAME=${2:-"pvcnametest"}
	#RC_NAME
	RC_NAME=${1:-"rctest"}
	#CONTAINER_NAME
	CONTAINER_NAME=${1:-"containertest"}
	#IMAGE_NAME
	IMAGE_NAME=${3:-"reg.dnt:5000/nginx:1.10.0-alpine"}
	#MOUNT_PATH
	MOUNT_PATH=${MOUNT_PATH:-"/mnt"}
	
	#echo "creating /tmp/umount.yaml -------------"
	debug=`kubectl delete rc $1 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::kubectl delete rc $1 echo $?, please check !"
		return 1
	fi
	debug=`cat > /tmp/umount.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
data:
  key: T0dFME9UVTNaV1kwWVdVeE9UTTJPR014T1RrMVl6WTBaVGM1WkdJeQo=
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: PV_NAME
  labels: 
    name: PV_NAME
spec:
    capacity:
        storage: SIZEGi
    accessModes:
        - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    rbd:
      monitors:
      - 20.26.28.13:6789
      - 20.26.28.14:6789
      - 20.26.28.15:6789
      user: admin
      pool: rbd
      image: RBD_IMAGE_NAME
      fsType: ext4,
      readOnly: true
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: PVC_NAME
  namespace: default
  labels: 
    name: PVC_NAME
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: SIZEGi
  selector:
    matchLabels:
      name: "PV_NAME"
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: RC_NAME
  namespace: default
  labels:
    kubernetes.io/cluster-service: "true"
spec:
  replicas: 1
  template:
    metadata:
      labels:
        kubernetes.io/cluster-service: "true"
    spec:
      nodeSelector:
        kubernetes.io/hostname: agent2
      containers:
      - name: CONTAINER_NAME
        image: IMAGE_NAME
        ports:
        - containerPort: 80
EOF
2>&1
`
	if [[ $? != 0 ]];then
		echo "1:::create umount.yaml print: $debug, please check !"
		return 1
	fi

	#echo "modify /tmp/umount.yaml -------------"
	debug=`sed -i \ s/PV_NAME/$PV_NAME/g \/tmp/umount.yaml && \
	sed -i \ s/SIZE/$SIZE/g \/tmp/umount.yaml && \
	sed -i \ s/RBD_IMAGE_NAME/$RBD_IMAGE_NAME/g \/tmp/umount.yaml && \
	sed -i \ s/PVC_NAME/$PVC_NAME/g \/tmp/umount.yaml && \
	sed -i \ s/RC_NAME/$RC_NAME/g \/tmp/umount.yaml && \
	sed -i \ s/CONTAINER_NAME/$CONTAINER_NAME/g \/tmp/umount.yaml && \
	sed -i \ s#IMAGE_NAME#$IMAGE_NAME#g \/tmp/umount.yaml && \
	sed -i \ s#MOUNT_PATH#$MOUNT_PATH#g \/tmp/umount.yaml 2>&1`

	if [[ $? -ne 0 ]];then
		echo "1:::modify umount.yaml print:\n $debug, please check !\n"
		return 1
	fi
	
	debug=`checkcmd kubectl 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmd kubectl print: $debug, please check !"
		return 1
	fi
	debug=`kubectl apply -f /tmp/umount.yaml`
	if [[ $? -ne 0 ]];then
		echo "1:::kubectl apply -f /tmp/umount.yaml print: $debug, please check !"
		return 1
	fi

	echo "0:::rbd_umount commmand send succeed !"
}
#usage: rbd_container_create rc_name
#rc_name 容器名
#返回值:0成功，1失败

function rbd_container_create {
	debug=`checkcmd kubectl 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmd kubectl print: $debug, please check !"
		return 1
	fi
	if [[ $# -ne 1 ]];then
		echo "1:::len(args) is not 1 ! please check ! "
		#echo "usage: rbd_container_create rc_name container_image_name"
		return 1
	fi
	#echo "setting env -------------"
	RC_NAME=${1:-"rctest"}
	#CONTAINER_NAME
	CONTAINER_NAME=${1:-"containertest"}
	#IMAGE_NAME
	IMAGE_NAME=${2:-"reg.dnt:5000/nginx:1.10.0-alpine"}
	
	#echo "creating /tmp/container.yaml -------------"
	debug=`cat > /tmp/container.yaml << EOF
apiVersion: v1
kind: ReplicationController
metadata:
  name: RC_NAME
  namespace: default
  labels:
    kubernetes.io/cluster-service: "true"
spec:
  replicas: 1
  template:
    metadata:
      labels:
        kubernetes.io/cluster-service: "true"
    spec:
      nodeSelector:
        kubernetes.io/hostname: agent3
      containers:
      - name: CONTAINER_NAME
        image: IMAGE_NAME
        ports:
        - containerPort: 80
EOF
2>&1
`
	if [[ $? -ne 0 ]];then
		echo "1:::create container.yaml print: $debug, please check !"
		return 1
	fi

	#echo "modify /tmp/container.yaml -------------"
	debug=`sed -i \ s/RC_NAME/$RC_NAME/g \/tmp/container.yaml && \
	sed -i \ s/CONTAINER_NAME/$CONTAINER_NAME/g \/tmp/container.yaml && \
	sed -i \ s#IMAGE_NAME#$IMAGE_NAME#g \/tmp/container.yaml 2>&1`

	if [[ $? -ne 0 ]];then
		echo "1:::modify container.yaml print:\n $debug, please check !\n"
		return 1
	fi
	
	debug=`checkcmd kubectl 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmd kubectl print: $debug, please check !"
		return 1
	fi
	debug=`kubectl apply -f /tmp/container.yaml`
	if [[ $? -ne 0 ]];then
		echo "1:::kubectl apply -f /tmp/container.yaml print: $debug, please check !"
		return 1
	fi

	echo "0:::rbd_container_create commmand send succeed !"
}
#usage: rbd_container_delete rc_name
#rc_name 容器名
#返回值:0成功，1失败
function rbd_container_delete {
	debug=`checkcmd kubectl 2>&1`
	if [[ $? -ne 0 ]];then
		echo "checkcmd kubectl print: $debug, please check !"
		return 1
	fi
	if [[ $# -ne 1 ]];then
		echo "len(args) is not 1 ! please check ! "
		#echo "usage: rbd_container_delete rc_name container_image_name"
		return 1
	fi
	#echo "setting env -------------"
	#RC_NAME
	RC_NAME=${1:-"rctest"}
	#CONTAINER_NAME
	CONTAINER_NAME=${1:-"containertest"}
	#IMAGE_NAME
	IMAGE_NAME=${3:-"reg.dnt:5000/nginx:1.10.0-alpine"}
	
	#echo "creating /tmp/container.yaml -------------"
	debug=`cat > /tmp/container.yaml << EOF
apiVersion: v1
kind: ReplicationController
metadata:
  name: RC_NAME
  namespace: default
  labels:
    kubernetes.io/cluster-service: "true"
spec:
  replicas: 1
  template:
    metadata:
      labels:
        kubernetes.io/cluster-service: "true"
    spec:
      nodeSelector:
        kubernetes.io/hostname: agent3
      containers:
      - name: CONTAINER_NAME
        image: IMAGE_NAME
        ports:
        - containerPort: 80
EOF
2>&1
`
	if [[ $? -ne 0 ]];then
		echo "1:::create container.yaml print: $debug, please check !"
		return 1
	fi

	#echo "modify /tmp/container.yaml -------------"
	debug=`sed -i \ s/RC_NAME/$RC_NAME/g \/tmp/container.yaml && \
	sed -i \ s/CONTAINER_NAME/$CONTAINER_NAME/g \/tmp/container.yaml && \
	sed -i \ s#IMAGE_NAME#$IMAGE_NAME#g \/tmp/container.yaml 2>&1`

	if [[ $? -ne 0 ]];then
		echo "1:::modify container.yaml print:\n $debug, please check !\n"
		return 1
	fi
	
	debug=`checkcmd kubectl 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmd kubectl print: $debug, please check !"
		return 1
	fi
	debug=`kubectl delete -f /tmp/container.yaml 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::kubectl delete -f /tmp/container.yaml print: $debug, please check !"
		return 1
	fi

	echo "0:::rbd_container_delete commmand send succeed !"
}
#usage: rbd_container_list
#列出所有容器(rc)
#返回值:0成功，1失败
function rbd_container_list {
	if [[ $# -ne 0 ]];then
		echo "1:::len(args) is not 1 ! please check ! "
		#echo "usage: rbd_container_list"
		return 1
	fi
	debug=`checkcmd kubectl 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmd kubectl print: $debug, please check !"
		return 1
	fi
	debug=`kubectl get rc --namespace=default | grep -v NAME |awk '{print $1}' 2>&1`
	#echo $debug
	if [[ $? -ne 0 ]];then
		echo "1:::kubectl get rc print: $debug, please check !"
		return 1
	fi
	#echo $debug
	#debug=`echo $debug |grep -v NAME |awk '{print $1}'`
	#if [[ $? -ne 0 ]];then
	#	echo "1:::awk rc name print: $debug, please check !"
	#	return 1
	#fi
	echo "0:::$debug"
}

#usage: rbd_snap_create image_name snap_name
#创建卷快照
#image_name 卷名
#snap_name 镜像名
#返回值:0成功，1失败

function rbd_snap_create {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 2 ]];then
		echo "1:::len(args) is not 2 ! please check ! "
		#echo "usage: rbd_snap_create image_name snap_name"
		return 1
	fi
	debug=`rbd --pool k8s snap create --image $1 --snap $2 2>&1`
	if [[ $? != 0 ]];then
		#echo "1:::command 'rbd --pool k8s snap create --image $1 --snap $2' echo code $debug, please check !"
		return 1
	fi
	echo "0:::"
}
#usage: rbd_snap_delete image_name snap_name
#删除卷快照
#image_name 卷名
#snap_name 镜像名
#返回值:0成功，1失败

function rbd_snap_delete {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 2 ]];then
		echo "1:::len(args) is not 2 ! please check ! "
		#echo "usage: rbd_snap_delete image_name snap_name"
		return 1
	fi
	debug=`rbd --pool k8s snap rm --image $1 --snap $2 2>&1`
	if [[ $? != 0 ]];then
		echo "1:::command 'rbd --pool k8s snap rm --image $1 --snap $2' echo code $debug, please check !"
		return 1
	fi
	echo "0:::"
}
#usage: rbd_snap_list image_name
#列出卷所有快照
#image_name 卷名
#返回值:0成功，1失败

function rbd_snap_list {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 1 ]];then
		echo "1:::len(args) is not 1 ! please check ! "
		#echo "usage: rbd_snap_list image_name"
		return 1
	fi
	debug=`rbd --pool k8s snap list --image $1 | grep -v "NAME" | awk '{print $2}' 2>&1`
	if [[ $? -ne 0 ]];then
		echo "1:::command 'rbd --pool k8s snap list --image $1' echo code $debug, please check !"
		return 1
	fi
	echo "0:::$debug"
}
#usage: rbd_snap_rollback image_name snap_name
#卷回滚到快照
#image_name 卷名
#snap_name 快照名
#返回值:0成功，1失败
function rbd_snap_rollback {
	checkcmdrbd
	if [[ $? -ne 0 ]];then
		echo "1:::checkcmdrbd echo $?, please check !"
		return 1
	fi
	if [[ $# -ne 2 ]];then
		echo "1:::len(args) is not 2 ! please check ! "
		#echo "usage: rbd_snap_rollback image_name snap_name"
		return 1
	fi
	debug=`rbd --pool k8s status $1 2>&1`
	if [[ -n `echo $debug | grep "client"` ]];then
		echo "1:::device is still watching ,info is : $debug"
		return 1
	fi
	debug=`rbd --pool k8s snap rollback --image $1 --snap $2 2>&1`
	if [[ $? != 0 ]];then
		echo "1:::command 'rbd --pool k8s snap rollback --image $1 --snap $2' echo code $debug, please check !"
		return 1
	fi
	echo "0:::"
}
