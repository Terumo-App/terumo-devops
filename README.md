# terumo-devops



## To update Docker Compose with new versions of images

You can use the docker-compose pull command. This command will pull the latest versions of the images defined in your docker-compose.yml file.

 To use the docker-compose pull command, follow these steps:

Navigate to the directory where your docker-compose.yml file is located.

Run the following command to pull the latest versions of the images:

```
docker-compose pull
```
This command will pull the latest versions of the images defined in your docker-compose.yml file.

Once the images have been pulled, you can start your containers by running the following command:

```

docker-compose up -d
```
