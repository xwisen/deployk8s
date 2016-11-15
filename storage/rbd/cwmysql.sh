MYSQL_HOST=${MYSQL_HOST:-"127.0.0.1"}
MYSQL_PORT=${MYSQL_PORT:-"3306"}
if [[ -n $1 ]];then
	MYSQL_HOST=$1
fi
if [[ -n $2 ]];then
	MYSQL_PORT=$2
fi

i=0
while true
do
	i=$i+1
	echo "
	CREATE DATABASE IF NOT EXISTS dcos CHARACTER SET UTF8;
	USE dcos;
	CREATE TABLE IF NOT EXISTS dnt (
	\`id\`  int NOT NULL PRIMARY KEY,
	\`name\` VARCHAR(255) NOT NULL DEFAULT 'aaa'
	)
	;
	INSERT INTO dnt(id,name) VALUES($i,'aaa');
	" > /tmp/tmp.sql
	echo "mysql -h$MYSQL_HOST -P$MYSQL_PORT -uroot -p123456 < /tmp/tmp.sql"
	mysql -h$MYSQL_HOST -P$MYSQL_PORT -uroot -p123456 < /tmp/tmp.sql
	sleep 5
done
