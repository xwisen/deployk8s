# SHELL 
# ***********************************************
# 
#       Filename: base.sh
# 
#         Author: xwisen 1031649164@qq.com
#    Description: ---
#         Create: 2016-11-03 19:27:01
#  Last Modified: 2016-11-03 19:27:01
# ***********************************************


#usage : ./base.sh 10.78.238.24
#export http_proxy=http://proxy.zj.chinamobile.com:8080 && export https_proxy=http://proxy.zj.chinamobile.com:8080
export http_proxy=http://10.78.238.24:8118 && export https_proxy=http://10.78.238.24:8118
echo "0-------------------set http proxy: \n$http_proxy--------------------\n$https_proxy"

if [[ -n $1 ]];then
	BASE_HOST=$1
fi

BASE_HOST=${BASE_HOST:-"10.78.238.24"}
echo "base host IP is : $BASE_HOST-----------------"

echo "1.-----------rm -rf /etc/yum.repos.d/*"
rm -rf /etc/yum.repos.d/*
if [[ $? -ne 0 ]];then
	echo "1.-----------rm -rf /etc/yum.repos.d/* return code $?"
	return 1
fi

echo "2.-----------scp -r $BASE_HOST:/etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo"
scp -r $BASE_HOST:/etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
if [[ $? -ne 0 ]];then
	echo "2.-----------scp -r $BASE_HOST:/etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo return code $?"
	return 1
fi

echo "3.-----------yum update -y && yum install -y epel-release"
yum update -y && yum install -y epel-release
if [[ $? -ne 0 ]];then
	echo "3.-----------yum update -y && yum install -y epel-release return code $?"
	return 1
fi

echo "4.-----------yum update -y && yum install -y jq tree lrzsz"
yum update -y && yum install -y jq tree lrzsz dstat iotop 
if [[ $? -ne 0 ]];then
	echo "4.-----------yum update -y && yum install -y jq tree lrzsz return code $?"
	return 1
fi

echo "5.-----------curl -sSL https://get.daocloud.io/docker | sh"
curl -sSL https://get.daocloud.io/docker | sh
if [[ $? -ne 0 ]];then
	echo "5.-----------curl -sSL https://get.daocloud.io/docker | sh return code $?"
	return 1
fi

unset http_proxy https_proxy
