# Docker Symfony 4 (PHP7-FPM - NGINX - MySQL)
Docker-symfony-4 gives you a complete stack you need for developing Symfony application.

## Requirements
*  [Docker](https://docs.docker.com/engine/installation/) installed
*  [Docker Compose](https://docs.docker.com/compose/install/) installed

## Services
*  PHP-FPM 7.2
*  Nginx 1.13
*  MySQL 5.7

## Installation
1. Clone this repository
```
$ git clone https://github.com/Beef-Bridge/docker-symfony-4.git
```
2. Update the Docker `.env` file according to your needs.
3. Enjoy :-)

## Usage
Just run `build.sh` file
```
$ ./build.sh
```
And that's it!

## Access the application
You can access the application both in HTTP and HTTPS by the hostname you defined (in `.env` file), using the dev mode (with `app_dev.php`) or not.

## How it works?
This script adds the hostname you defined to your hosts file, then creates the `www` directory at the root.
It continues by downloading the Symfony framework inside and creating your Symfony project.
Then it builds and executes the containers:
* `db` : this is the container for MySQL databases,
* `nginx` : this is the container of the Nginx web server,
* `app` : this is the PHP-FPM container.

It ends by adding some Symfony dependencies to the project (using Composer):
* sensio/framework-extra-bundle
* symfony/console
* symfony/flex
* symfony/yaml
* symfony/twig-bundle
* symfony/orm-pack
* doctrine/doctrine-bundle
* symfony/maker-bundle --dev
* symfony/profiler-pack --dev

## Useful commands
```
# bash commands
$ docker-compose exec app /bin/bash

# Symfony console
$ docker-compose exec -u www-data app bin/console

# Composer console
$ docker-compose exec -u www-data app composer

# configure permissions, e.g on var/log folder
$ docker-compose exec app chown -R www-data:1000 var/log

# Stop all containers
$ docker stop $(docker ps -aq)

# Delete all containers
$ docker rm $(docker ps -aq)

# Delete all images
$ docker rmi ($docker images -q)
```

## FAQ
* How I can add PHPMyAdmin?
Simply add this in docker-compose.yaml:
```
services:
    ...
    phpmyadmin:
        image: phpmyadmin/phpmyadmin
        container_name: ${PROJECT_NAME}_phpmyadmin
        ports:
            - 8080:80
        links:
            - mysql
        environment:
            PMA_HOST: mysql
```
And launches the build and run to this container:
```
$ docker-compose -f docker-compose.yaml build
$ docker-compose -f docker-compose.yaml up
```
Now you can access to PhpMyAdmin by [your-hostname:8080](your-hostname:8080).

## Credits
* [guham/symfony-docker](https://github.com/guham/symfony-docker): Big credit goes to Guham. His docker symfony multi databases setup was base for this fork. I removed stuff that I didn't need and added some extra stuff that I required.

## Contributing
Create Pull Request with changes/updates you feel are needed OR just fort this repo and hack away.
