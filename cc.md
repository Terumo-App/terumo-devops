mkdir terumo

cd terumo/

wget https://github.com/Terumo-App/terumo-devops/archive/refs/heads/main.zip

unzip main.zip
rm main.zip
cd terumo-devops-main/

https://docs.docker.com/compose/install/
install docker compose
curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose;

Crie um usuario adm no cytomine para gerenciar os collections do terumo
adicione public key e private key no .env file
altere o host cytomine no .env file

insert cytomine volumume map in celery worker and flower

sh reset para iniciar o docker compose ou inciar ele

Altere as veriaveis de ambientes de prod no terumo web repo para reflletir o nome do servidor do cytomine e nome da aplicaçao web do terumo


alterar cors ngnix do servidir pata permitir cors


        add_header 'Access-Control-Allow-Origin' 'http://terumo-ui';
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range';
        add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS,PUT,DELETE,PATCH';
        

adicionar no hosts files a api do terumo
127.0.0.1 terumo-api
127.0.0.1 terumo-ui
127.0.0.1 terumo-portainer

127.0.0.1  

10.131.10.83 terumo-api
10.131.10.83 terumo-ui
10.131.10.83 terumo-portainer
adicionar ui e api do terumo no proxy reverso 
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


        add_header 'Access-Control-Allow-Origin' 'http://terumo-ui';
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range';
        add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS,PUT,DELETE,PATCH';


       location / {
            add_header Access-Control-Allow-Origin *;
            proxy_set_header Host $host;
            proxy_pass http://core-api:8000;
        }
    }  

docker volume create portainer_data

docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

verificar IP do gatway
sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' 836db73df2a2
verificar IP do container
sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 17102837c224

Conectar em rede
docker network connect minha_nova_rede meu_container_existente
docker network connect terumo-devops-main_terumo-network nginx

Desconectar de rede
docker network disconnect REDE_ORIGINAL NOME_DO_CONTAINER

docker exec terumo-devops-main-frontend-1 cat /etc/resolv.conf | grep nameserver | head -n 1 | awk '{print $2}'

descobrir dns do container
docker inspect -f '{{range .NetworkSettings.Networks}}{{.Aliases}}{{end}}' terumo-devops-main-frontend-1

Liberar firewall para docker connection
sudo ufw allow from 172.17.0.0/24
sudo ufw allow from 172.21.0.0/16
sudo ufw reload

Delttar regra de firewall
sudo ufw delete allow from 172.17.0.0/24



## Para instalar curl num container ubunto-debian
apt-get update
apt-get install -y curl
## Para imagens baseadas em Red Hat/CentOS:
yum install -y curl


apk add --no-cache curl  # Instala o curl se ainda não estiver instalado
curl http://exemplo.com


curl http://frontend

## Fazer pull de uma unica imagem e atualizar ela no docker compose sem derrubar os outros
docker pull nome_da_imagem:tag
docker pull terumoapp/terumo-web
docker-compose up --no-deps -d nome_do_servico
docker-compose up --no-deps -d frontend


extra_hosts:
 - "localhost-core-frigga:172.21.0.10"

172.21.0.10 -> é o ip do nginx proxy reverso cytomine container dentro da rede terumo-network do docker compose


docker network connect terumo-devops-main_terumo-network nginx

definir variaveis de ambiente anntes de buildar container do teerumo frontend
REACT_APP_API_URL=http://terumo-api/v1
REACT_APP_WEB_URL=http://terumo-ui
REACT_APP_CYTOMINE_URL=http://localhost-core-frigga/