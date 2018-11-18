#!/bin/bash

# Source file for some variables
# ------------------------------
source .env



# Definition of variables
# -----------------------
# Font colors
RED='\x1B[1;31m'
GREEN='\x1B[1;32m'
YELLOW='\x1B[1;33m'
DEFAULT='\x1B[0;m'

# Font high intensity backgrounds
BG_BLUE='\033[0;104m'

# Default IP adress for hostname
IP="127.0.0.1"

# Hostname to add/remove.
HOSTNAME=${NGINX_HOST}



# Adding a domain to the hosts file
# ---------------------------------
echo -e "${BG_BLUE}---> adding host${DEFAULT}";
HOSTS_LINE="$IP\t$HOSTNAME"
if [ -n "$(grep $HOSTNAME ${HOSTS_FILE_PATH})" ]
    then
        echo -e "${RED}$HOSTNAME already exists : $(grep $HOSTNAME ${HOSTS_FILE_PATH})${DEFAULT}";
    else
        echo -e "${YELLOW}Adding $HOSTNAME to your ${HOSTS_FILE_PATH}${DEFAULT}";
        sudo -- sh -c -e "echo '$HOSTS_LINE' >> '${HOSTS_FILE_PATH}'";

        if [ -n "$(grep $HOSTNAME ${HOSTS_FILE_PATH})" ]
            then
                echo -e "${GREEN}$HOSTNAME was added succesfully \n $(grep $HOSTNAME ${HOSTS_FILE_PATH})${DEFAULT}";
            else
                echo -e "${RED}Failed to Add $HOSTNAME, Try again!${RED}";
        fi
fi



# Downloading the Symfony project
# -------------------------------
echo -e "${BG_BLUE}---> downloading symfony framework and creating project${DEFAULT}";
mkdir www
cd www/
composer create-project symfony/skeleton ${PROJECT_NAME}

echo -e "${BG_BLUE}---> changing few elements in symfony project${DEFAULT}";
rm -f ${PROJECT_NAME}/.env
DOCTRINE_INSTRUCTION="###> doctrine/doctrine-bundle ###
# Format described at http://docs.doctrine-project.org/projects/doctrine-dbal/en/latest/reference/configuration.html#connecting-using-a-url
# For an SQLite database, use: "sqlite:///%kernel.project_dir%/var/data.db"
# Configure your db driver and server_version in config/packages/doctrine.yaml
DATABASE_URL=mysql://\${MYSQL_USER}:\${MYSQL_PASSWORD}@mysql:3306/\${MYSQL_DATABASE}
###< doctrine/doctrine-bundle ###"
sudo -- sh -c -e "echo '\n$DOCTRINE_INSTRUCTION' >> ${PROJECT_NAME}/.env.dist";

echo -e "${BG_BLUE}---> deleting few directory in symfony project${DEFAULT}";
rm -r ${PROJECT_NAME}/vendor
rm -r ${PROJECT_NAME}/var

echo -e "${BG_BLUE}---> copying .env.dist file to .env file in symfony project${DEFAULT}";
cp ${PROJECT_NAME}/.env.dist ${PROJECT_NAME}/.env
cd ..



# Build containers
# ----------------
echo -e "${BG_BLUE}---> building docker containers${DEFAULT}";
docker-compose -f docker-compose.yaml build --no-cache --force-rm

echo -e "${BG_BLUE}---> up docker containers"
docker-compose -f docker-compose.yaml up -d



# Configure permissions on symfony/var folder
# -------------------------------------------
echo -e "${BG_BLUE}---> configure permissions on symfony/var folder${DEFAULT}";
docker-compose exec app chown -R www-data:1000 var



# Configure composer.json to symfony project
# ------------------------------------------
echo -e "${BG_BLUE}---> adds some dependencies to symfony project${DEFAULT}";
docker-compose exec -u www-data app composer require sensio/framework-extra-bundle symfony/console symfony/flex symfony/yaml symfony/twig-bundle symfony/orm-pack doctrine/doctrine-bundle
docker-compose exec -u www-data app composer require symfony/maker-bundle --dev symfony/profiler-pack --dev



# Finished
# --------
clear
echo -e "${GREEN}******************************************************************************"
echo "***                                                                        ***"
echo "***                                                                        ***"
echo "***                        !!! Congratulations !!!                         ***"
echo "***                                                                        ***"
echo "***                                                                        ***"
echo "*** Your ${PROJECT_NAME} project is configured !                           ***"
echo "*** You can access to your application with :                              ***"
echo "*** - http://${NGINX_HOST}/                                                ***"
echo "*** - https://${NGINX_HOST}/                                               ***"
echo "***                                                                        ***"
echo "*** Have dev fun ;-)                                                       ***"
echo "******************************************************************************"
1>&2
exit 1

$@
