#!/bin/sh

cd /vagrant/dev/mysql

data=false

for cname in `docker ps --filter="name=lumen-mysql" --format "{{.Names}}" -q -a`
do
    if [ "$cname" = lumen-mysql ]
    then
        docker stop $cname
        docker rm $cname
    fi

    if [ "$cname" = lumen-mysql-data ]
    then
        data=true
    fi
done

if [ "$data" = false ]
then
    docker run --name lumen-mysql-data -v /var/lib/mysql busybox
fi

docker build -t lumen/mysql .

docker run \
       -d \
       --restart=always \
       -v /etc/localtime:/etc/localtime:ro \
       --name lumen-mysql \
       --hostname lumen-mysql \
       -p 3306:3306 \
       --volumes-from lumen-mysql-data \
       -e MYSQL_DATABASE=lumen \
       -e MYSQL_USER=lumen \
       -e MYSQL_PASSWORD=lumen \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
       lumen/mysql \
       --character-set-server=utf8 \
       --collation-server=utf8_unicode_ci
