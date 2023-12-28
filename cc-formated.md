### Create a directory named terumo
```
mkdir terumo
```

### Change into the terumo directory
```
cd terumo/
```

### Download the main.zip file from the Terumo GitHub repository
```
wget https://github.com/Terumo-App/terumo-devops/archive/refs/heads/main.zip
```

### Unzip the downloaded main.zip file
```
unzip main.zip
```
### Remove the downloaded main.zip file
```
rm main.zip
```
### Change into the terumo-devops-main/ directory
```
cd terumo-devops-main/
```

### Install Docker Compose (follow the instructions at https://docs.docker.com/compose/install/)
```
curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Modify the production environment variables in the Terumo web repository to reflect the Cytomine server name and Terumo web application name
### Create an 'adm' user in Cytomine to manage Terumo collections

### Add public key and private key to the .env file
```
# Example
# PUBLIC_KEY=2ca859f3-365a-4598-98ff-044e2d2964b7
# PRIVATE_KEY=a02623ce-da40-49c7-8a58-ba5832060f9b
```
### Change the Cytomine host in the .env file
```
# Example
# HOST=http://maods.homelab.core
# CYTOMINE_HOST=http://maods.homelab.core
```
### Insert Cytomine volume mapping in Celery worker and Flower
```
# Example
# CYTOMINE_IMAGE_FILE_VOLUME=\\wsl$\Ubuntu\home\maodsunix\cytomine\data\images
```

### Run 'sh reset' to start Docker Compose or initialize it
```
sudo sh reset.sh
```


### Change the Nginx CORS settings to allow CORS
### Add the following headers to the Nginx server configuration:

```
server {
        client_max_body_size 0;
        listen       80;
        server_name  localhost-core-frigga;


        add_header 'Access-Control-Allow-Origin' 'http://terumo-ui';
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range';
        add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS,PUT,DELETE,PATCH';
        ...
```



### Add the following entries to the hosts file:
```
127.0.0.1 terumo-api
127.0.0.1 terumo-ui
127.0.0.1 terumo-portainer
10.131.10.83 terumo-api
10.131.10.83 terumo-ui
10.131.10.83 terumo-portainer
```

### Add Terumo UI and API to the reverse proxy
### Configure Nginx server blocks for terumo-ui and terumo-api

```
    server {
        client_max_body_size 0;

        listen       80;
        server_name  terumo-ui;

        location / {
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_pass http://frontend;
        }
    }
    server {
        client_max_body_size 0;
        listen       80;
        server_name  terumo-api;


       location / {
            proxy_set_header Host $host;
            proxy_pass http://core-api:8000;
        }
    }  
```
### After updating the `nginx.conf` file you should restart cytomine nginx container in order to apply the changes. 
Run `maods_update_nginx_cors.sh` script to restart the container with the new configuration and also to add nginx into terumo network so that terumo application can reach cytomine services.
```
#maods_update_nginx_cors.sh

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

```



### Add Nginx IP domain to docker compose
Update docker compose with the new ip address that the cytomine nginx container has within the terumo network
```
extra_hosts:
 - "localhost-core-frigga:172.21.0.10"
```



### Set Frontend environment variables before building the Terumo frontend container
When using the terumo application on a new server, it is necessary to rebuild the [terumo-ui](https://github.com/Terumo-App/terumo-web) container by updating the following environment variables in the `.env.prod` file according to the terumo-ui, terumo-api and crytomine domains were defined on that given server
```
REACT_APP_API_URL=http://terumo-api/v1
REACT_APP_WEB_URL=http://terumo-ui
REACT_APP_CYTOMINE_URL=http://localhost-core-frigga/
```

## Instaling Portainer to manager container in a UI based application
### Create a Docker volume named portainer_data
```
docker volume create portainer_data
```

### Run Portainer in a Docker container
```
docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
```

## Debugging commands
### Check the gateway IP
```
sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' 836db73df2a2
```

### Check the container IP
```
sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 17102837c224
```

### Connect container to specific network
```
docker network connect terumo-devops-main_terumo-network nginx
docker network connect minha_nova_rede meu_container_existente
```

### Disconnect from a network
```
docker network disconnect REDE_ORIGINAL NOME_DO_CONTAINER
```

### Check the DNS of the container
```
docker exec terumo-devops-main-frontend-1 cat /etc/resolv.conf | grep nameserver | head -n 1 | awk '{print $2}'
docker inspect -f '{{range .NetworkSettings.Networks}}{{.Aliases}}{{end}}' terumo-devops-main-frontend-1
```

### Allow firewall for Docker connections
```
sudo ufw allow from 172.17.0.0/24
sudo ufw allow from 172.21.0.0/16
sudo ufw reload
```

### Delete a firewall rule
```
sudo ufw delete allow from 172.17.0.0/24
```
### Install curl in an Ubuntu-Debian container
```
apt-get update
apt-get install -y curl
```

### Testing terumo urls
```
curl http://frontend
curl http://core-api:8000/docs#/
curl http://terumo-api/docs#/
```

### Pull and update a single Docker image in the Docker Compose without affecting others
```
docker pull nome_da_imagem:tag
docker pull terumoapp/terumo-web
docker-compose up --no-deps -d nome_do_servico
docker-compose up --no-deps -d frontend
docker-compose up --no-deps -d core-api
sudo docker compose up --no-deps core-api
```

