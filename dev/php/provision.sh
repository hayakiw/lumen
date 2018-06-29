#!/bin/sh

cd /vagrant/dev/php


for cname in `docker ps --filter="name=lumen-php" --format "{{.Names}}" -q -a`
do
    if [ "$cname" = lumen-php ]
    then
        docker stop $cname
        docker rm $cname
    fi
done

docker build -t lumen/php .

docker run \
       -d \
       --restart=always \
       -v /etc/localtime:/etc/localtime:ro \
       --name lumen-php \
       --hostname lumen-php \
       -p 80:80 \
       -v /vagrant:/vagrant \
       --link lumen-mysql:lumen-mysql \
       -e DESKTOP_NOTIFIER_SERVER_URL=http://192.168.88.1:12345 \
       lumen/php

docker cp \
       /vagrant/dev/php/desktop-notifier-client \
       lumen-php:/usr/bin/notify-send

docker exec lumen-php /vagrant/dev/php/init-env.sh
