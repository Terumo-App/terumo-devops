#!/bin/bash

docker stop nginx
docker rm -v nginx

docker create --name nginx \
     --link ims:ims \
     --link iipCyto:iipCyto \
     --link core:core \
     --link iipOff:iipOff \
     --link web_UI:web_UI \
     -v /home/cytomine/images/buffer:/tmp/uploaded \
     -p 80:80 \
     --restart=unless-stopped \
     cytomine/nginx:v1.3.1 > /dev/null

docker cp $PWD/configs/nginx/nginx.conf nginx:/usr/local/nginx/conf/nginx.conf


docker network connect terumo-devops-main_terumo-network nginx
docker start nginx
