# SHELL 
# ***********************************************
# 
#       Filename: regC.sh
# 
#         Author: xwisen 1031649164@qq.com
#    Description: ---
#         Create: 2016-11-25 10:24:04
#  Last Modified: 2016-11-25 10:24:04
# ***********************************************

function regc_search() {
	REG_INFO=${REG_INFO:-reg.dnt:5000}
	if [[ -z $1 ]];then
		#curl http://${REG_HOST}:5000/v2/_catalog | jq .
		python -c '
import urllib2,json
try:
	resp=urllib2.urlopen("http://"+"'${REG_INFO}'"+"/v2/_catalog")
except urllib2.HTTPError as e:
	print(e)
	exit(1)
repos=json.loads(resp.read())["repositories"][0:] 
#repos= "\n".join(str(image) for image in data["repositories"][0:])
for repo in repos:
	try:
		resp=urllib2.urlopen("http://"+"'${REG_INFO}'"+"/v2/"+repo+"/tags/list")	
	except urllib2.HTTPError as e:
		print(e)
		exit(1)
	tags=json.loads(resp.read())["tags"]
	for tag in tags:
		print("'${REG_INFO}'"+"/"+repo+":"+tag)
'
	else
		#curl http://${REG_HOST}:5000/v2/$1/tags/list | jq .tags
		REPO=${1:-"busybox"}
		python -c '
import urllib2,json
try:
	resp=urllib2.urlopen("http://"+"'${REG_INFO}'"+"/v2/"+"'${REPO}'"+"/tags/list")	
except urllib2.HTTPError as e:
	print(e)
	exit(1)
tags=json.loads(resp.read())["tags"]
for tag in tags:
	print("'${REG_INFO}'"+"/"+"'${REPO}'"+":"+tag)
'
	fi
}
function regc_del() {
	REG_INFO=${REG_INFO:-reg.dnt:5000}
	if [[ $# -ne 1  ]];then
		echo "Example: "
		echo "regc_del ${REG_HOST}:5000/nginx:1.9"
		return 1
	fi
	#echo "image need delete is : $1"
	reg_info=`echo $1 | cut -d "/" -f 1`
	image_name=`echo $1 | cut -d "/" -f 2- | cut -d ":" -f 1`
	tag_name=`echo $1 | cut -d "/" -f 2- | cut -d ":" -f 2`
	echo "reg info is : $reg_info"
	echo "image name is : $image_name"
	echo "tag name is : $tag_name"
	python -c '
import urllib2,json
try:
	req=urllib2.Request("http://"+"'${reg_info}'"+"/v2/"+"'${image_name}'"+"/manifests/"+"'${tag_name}'")
	req.get_method=lambda: "GET"
	resp=urllib2.urlopen(req)
except urllib2.HTTPError as e:
	print(e)
	exit(1)
print(str(resp.read()))
#print(json.loads(resp.read()))
'
}
