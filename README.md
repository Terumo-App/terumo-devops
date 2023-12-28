# Terumo DevOps Repo Documentation

## Terumo: Contact-Based Image Retrieval Tool for Renal Pathologists

Terumo is a web software that serves as a contact-based image retrieval tool for renal pathologists. It allows users to perform queries using images of renal biopsies of glomeruli and retrieves images with semantic similarities. This documentation provides instructions on setting up and running Terumo using Docker and Docker Compose.



## Prerequisites

Before proceeding with the installation, ensure that you have the following prerequisites installed on your machine:

1. Docker: Visit the [official Docker website](https://docs.docker.com/get-docker/) for instructions on how to install Docker on your specific operating system.
2. Docker Compose: Refer to the [official Docker Compose documentation](https://docs.docker.com/compose/install/) for installation instructions.
    ```
    curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```
3. Cytomine: Cytomine is a collaborative web platform designed for the analysis of extensive biomedical images and semi-automatic processing of large image collections through machine learning algorithms. It operates as an open-source RESTful web platform, utilizing Docker containers to encapsulate multiple services. Terumo Software integrates Cytomine as a foundational component, particularly in the management of image collections. Refer to the [Install Community Edition Legacy Doc](https://doc.cytomine.org/admin-guide/legacy/legacy-install#install-community-edition-legacy) for installation instructions.
4. Clone or download the Terumo DevOps repository, which contains essential files like Docker Compose and .env files required to launch the application.



Terumo's main code repositories are not necessary for running the application but you can find the links bellow for reference or if there is an intention to develop the application further.:
- [Frontend](https://github.com/Terumo-App/terumo-web)
- [Backend](https://github.com/Terumo-App/terumo-core)
- [terumo's docker hub](https://hub.docker.com/u/terumoapp)
## Installation Steps

### 1. Download Terumo DevOps Repository

```
wget https://github.com/Terumo-App/terumo-devops/archive/refs/heads/main.zip
unzip main.zip
rm main.zip
cd terumo-devops-main/
```

### 2. Add environment variables

Modify the production environment variables in the Terumo web repository to reflect the Cytomine server name and Terumo web application name.
```
# Example
# HOST=http://maods.homelab.core
# CYTOMINE_HOST=http://maods.homelab.core
```
To obtain authentication keys for use as a proxy account, create an admin user on Cytomine software. Log in with the new user, retrieve the `PUBLIC_KEY` and `PRIVATE_KEY` from the account menu, and add them to the `.env` file.

```
# Example
# PUBLIC_KEY=2ca859f3-365a-4598-98ff-044e2d2964b7
# PRIVATE_KEY=a02623ce-da40-49c7-8a58-ba5832060f9b
```

To enable Terumo software to interact with image collections on Cytomine, specify the full path to the folder where Cytomine stores images in the application. Follow the example below:
```
#Example
#CYTOMINE_IMAGE_FILE_VOLUME=\\wsl$\Ubuntu\home\maodsunix\cytomine\data\images
```
Adjust the three environment variables in the Terumo web UI container, which are defined before the build process, based on the server configuration and the names used for URL domains of certain application components. Make these changes in the [terumo-web](https://github.com/Terumo-App/terumo-web) repository before building the frontend image for use in the Docker Compose file.  
```
REACT_APP_API_URL=http://terumo-api/v1
REACT_APP_WEB_URL=http://terumo-ui
REACT_APP_CYTOMINE_URL=http://localhost-core-frigga/
```


### 3. Starting the application
Run `start.sh` to start Docker Compose and initialize all terumo components
```
sudo sh start.sh
```

### 4. Modify Cytomine Nginx settings

o enable Terumo web UI access to the Cytomine backend without encountering CORS errors, modify the NGINX CORS configuration.
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

As new servers (terumo app) are introduced to the infrastructure, it is essential to include them in the NGINX reverse proxy configuration.
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
An example with the complete configuragion files can be found on this repo under [`./cytomine_reverse_proxy`](./cytomine_reverse_proxy) folder.


### 5. Map IPs to domains
- To share your installation and make your Cytomine instance accessible from anywhere, create DNS entries and make their HTTP(S) ports (80/443) accessible for these URLs. This operation can often be realised by your network administrator or your IT department.
- To install locally (on a laptop for example), open the file /etc/hosts in a text editor. Append these lines

```
127.0.0.1 terumo-api
127.0.0.1 terumo-ui
```

### 6. Restart Nginx
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


### 7. Shutting down the application
To shut down all Terumo application containers that are running, use the command:
```shell
sh down.sh
```

### 8. Add Nginx IP domain to docker compose
After restarting nginx container, update docker compose with the new ip address that the cytomine nginx container has within the terumo network. Add this configuration to both `core-api` and `celery-index-worker` services. Find a reference template file under [`./cytomine_reverse_proxy`](./cytomine_reverse_proxy) folder.
```
extra_hosts:
 - "localhost-core-frigga:172.21.0.10"
```


### 9. Restart app
Now you added all configuration you can start terumo app again.
```
sudo sh start.sh
```

## Conclusion

You have successfully set up and launched the Terumo application using Docker and Docker Compose. Enjoy using the application and exploring its features as a contact-based image retrieval tool for renal pathologists!



## Usefull Commands And Tools

### Instaling Portainer
Instaling Portainer to manager container in a UI based application
- Create a Docker volume named portainer_data
    ```
    docker volume create portainer_data
    ```

- Run Portainer in a Docker container
    ```
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
    ```
### Debugging commands

- Check the docker gateway IP

    ```
    sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' 836db73df2a2
    ```
- Check the container IP
    ```
    sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 17102837c224
    ```
- Connect container to specific network
    ```
    docker network connect terumo-devops-main_terumo-network nginx
    docker network connect minha_nova_rede meu_container_existente
    ```
- Disconnect from a network
    ```
    docker network disconnect REDE_ORIGINAL NOME_DO_CONTAINER
    ```
- Check the DNS of the container
    ```
    docker exec terumo-devops-main-frontend-1 cat /etc/resolv.conf | grep nameserver | head -n 1 | awk '{print $2}'
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.Aliases}}{{end}}' terumo-devops-main-frontend-1
    ```
- Allow firewall for Docker connections
    ```
    sudo ufw allow from 172.17.0.0/24
    sudo ufw allow from 172.21.0.0/16
    sudo ufw reload
    ```

- Delete a firewall rule
    ```
    sudo ufw delete allow from 172.17.0.0/24
    ```
- Install curl in an Ubuntu-Debian container
    ```
    apt-get update
    apt-get install -y curl
    ```

- Testing terumo urls
    ```
    curl http://frontend
    curl http://core-api:8000/docs#/
    curl http://terumo-api/docs#/
    ```

- Pull and update a single Docker image in the Docker Compose without affecting others
    ```
    docker pull nome_da_imagem:tag
    docker pull terumoapp/terumo-web
    docker-compose up --no-deps -d nome_do_servico
    docker-compose up --no-deps -d frontend
    docker-compose up --no-deps -d core-api
    sudo docker compose up --no-deps core-api
    ```