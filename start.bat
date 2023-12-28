
@echo off
setlocal
rmdir /s /q .\milvus\volumes
docker-compose stop
docker-compose rm -f
docker-compose pull   
docker-compose up 
endlocal

