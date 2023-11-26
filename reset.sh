#!/bin/bash


rm -rf ./milvus/volumes

docker-compose stop
docker-compose rm -f
docker-compose pull   
docker-compose up 
