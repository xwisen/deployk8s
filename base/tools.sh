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

#eg: regc_search
#eg: regc_search nginx
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
	if tags:
		for tag in tags:
			print("'${REG_INFO}'"+"/"+repo+":"+tag)
	else:
		print("'${REG_INFO}'"+"/"+repo+":"+"deleted")
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
if tags:
	for tag in tags:
		print("'${REG_INFO}'"+"/"+repo+":"+tag)
else:
	print("'${REG_INFO}'"+"/"+repo+":"+"deleted")
'
	fi
}

#eg: regc_del reg.dnt:5000/nginx:1.9
function regc_del() {
	REG_INFO=${REG_INFO:-reg.dnt:5000}
	if [[ $# -ne 1  ]];then
		echo "Example: "
		echo "regc_del ${REG_INFO}/nginx:1.9"
		return 1
	fi
	#echo "image need delete is : $1"
	reg_info=`echo $1 | cut -d "/" -f 1`
	image_name=`echo $1 | cut -d "/" -f 2- | cut -d ":" -f 1`
	tag_name=`echo $1 | cut -d "/" -f 2- | cut -d ":" -f 2`
	#echo "reg info is : $reg_info"
	#echo "image name is : $image_name"
	#echo "tag name is : $tag_name"
	python -c '
import urllib2,json
try:
	req=urllib2.Request("http://"+"'${reg_info}'"+"/v2/"+"'${image_name}'"+"/manifests/"+"'${tag_name}'")
	req.add_header("Accept","application/vnd.docker.distribution.manifest.v2+json")
	req.get_method=lambda: "GET"
	resp=urllib2.urlopen(req)
except urllib2.HTTPError as e:
	print(e)
	exit(1)
#print(str(resp.read()))
try:
	digest=resp.info()["Docker-Content-Digest"]
	req=urllib2.Request("http://"+"'${reg_info}'"+"/v2/"+"'${image_name}'"+"/manifests/"+digest)
	req.add_header("Accept","application/vnd.docker.distribution.manifest.v2+json")
	req.get_method=lambda: "DELETE"
	resp=urllib2.urlopen(req)
except urllib2.HTTPError as e:
	print(e)
	exit(1)
print("delete image : "+"'${1}'" + " succeed !")
#print(str(resp.read()))
# other useful note
#print(resp.info()["Docker-Content-Digest"])
#headers=resp.info()
#print(headers.getheaders("Docker-Content-Digest"))
#print(json.loads(resp.read()))
'
}

#eg: yamltojson test.yaml test.json
function yamltojson () {
	python -c '
import sys, yaml, json;
json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)
'< $1 > $2
	if [[ $? -ne 0  ]];then
		echo ">>>>>>convert failed !"
	else
		echo ">>>>>>convert succeed ! input is : $1, output is : $2"
	fi
}

#eg: jsontoyaml test.json test.yaml
function jsontoyaml () {
	python -c '
import sys, yaml, json;
yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)
'< $1 > $2
	if [[ $? -ne 0  ]];then
		echo ">>>>>>convert failed !"
	else
		echo ">>>>>>convert succeed ! input is : $1, output is : $2"
	fi
}
