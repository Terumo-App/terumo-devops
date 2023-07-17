# Terumo DevOps Repo Documentation

## Terumo: Contact-Based Image Retrieval Tool for Renal Pathologists

Terumo is a web software that serves as a contact-based image retrieval tool for renal pathologists. It allows users to perform queries using images of renal biopsies of glomeruli and retrieves images with semantic similarities. This documentation provides instructions on setting up and running Terumo using Docker and Docker Compose.



## Prerequisites

Before proceeding with the installation, ensure that you have the following prerequisites installed on your machine:

1. Docker: Visit the [official Docker website](https://docs.docker.com/get-docker/) for instructions on how to install Docker on your specific operating system.
2. Docker Compose: Refer to the [official Docker Compose documentation](https://docs.docker.com/compose/install/) for installation instructions.
3. Clone or download the Terumo DevOps repository (The commands must be run within this repository).


Terumo's main code repositories are not necessary to run the application, but they are here in case you want to have them as a reference:
- [Frontend](https://github.com/Terumo-App/terumo-web)
- [Backend](https://github.com/Terumo-App/terumo-service-search-monolith)

## Installation Steps

### 1. Install Docker

To install Docker on your machine, follow the instructions specific to your operating system provided on the [official Docker website](https://docs.docker.com/get-docker/).

### 2. Install Docker Compose

Docker Compose is required to manage the multi-container application. Follow the installation instructions for Docker Compose provided in the [official Docker Compose documentation](https://docs.docker.com/compose/install/).

### 3. Pull Terumo Frontend and Backend Container Images

Before running the Terumo application, you need to pull the container images for both the frontend and backend components. Execute the following commands in your terminal:

```shell
docker pull terumoapp/terumo-web
docker pull terumoapp/terumo-service-search-monolith
```


### 4. Download Image Dataset and Extract the Zip File

Download the image dataset required by the Terumo application. Once downloaded, extract the contents of the zip file to a directory of your choice
<i>( The image dataset used in the indexing database is located on the PattoSpother share drive)<i>.

### 5. Replace Dataset Directory Location in Docker Compose File

In the Docker Compose file, you need to specify the directory location of the image dataset as a volume for the backend container. Open the `docker-compose.yml` file in a text editor and locate the following line:

```yaml
service-search-monolith:
    volumes:
        - /path/to/dataset:/src/db
```

Replace `/path/to/dataset` with the actual directory path where you extracted the image dataset in the previous step. Save the changes to the `docker-compose.yml` file.

### 6. Run the Application

Once you have completed the above steps, you can now run the Terumo application using Docker Compose. Execute the following command in your terminal:

```shell
docker-compose up -d
```

The application will start running, and you can access the frontend by opening your browser and navigating to `http://localhost:3000`. The backend app will be running at  `http://localhost:5000`

Note: If the frontend is not accessible immediately, wait for a few moments for the containers to initialize properly.

### 7. Updating the application
If a new version of the application is launched on [terumo's docker hub](https://hub.docker.com/u/terumoapp), you can use the `relaod_app.sh` script to download the new versions and restart the application.

```shell
sh reload_app.sh
```

### 8. Shutting down the application
To shut down all Terumo application containers that are running, use the command:
```shell
sh shutdown_app.sh
```

## Conclusion

You have successfully set up and launched the Terumo application using Docker and Docker Compose. Enjoy using the application and exploring its features as a contact-based image retrieval tool for renal pathologists!