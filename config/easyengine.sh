#! /bin/bash

function command_exists () {
    type "$1" &> /dev/null ;
}

function divider() {
    echo -------------------------------------------------------- ;
    if [ "$1" ]; then
        echo "$1"
    fi
}

if ! command_exists ee ; then

    divider "Installing Unattended Upgrades"
    sudo apt install unattended-upgrades

    if ! command_exists git ; then
        divider "Installing Git"
        # We need git installeed before we can set our name and email
        sudo apt-get update
        sudo apt-get --yes install git
    fi

    divider "Setting Global Git Config"
    # EasyEngine needs our name and email for Git reasons, without it the script will fail
    sudo git config --global user.email "product@billypenn.com"
    sudo git config --global user.name "Spirited Media"

    divider "Installing EasyEngine"
    sudo wget -qO ee rt.cx/ee && sudo bash ee || exit 1
    source /etc/bash_completion.d/ee_auto.rc

    divider "Installing Redis"
    sudo ee stack install --redis
    sudo ee stack install --phpredisadmin

    divider "Setting up spiritedmedia.dev multisite"
    sudo ee site create spiritedmedia.dev --wpsubdomain --php7 --user=admin --pass=admin --email=product@billypenn.com --experimental

    # Allow the dev tools from our host IP without requiring auth
    divider "IP Whitelisting for the dev tools on port 22222"
    # Whitelist the entire subnet because... why not?
    sudo ee secure --ip 192.168.33.0/24 --quiet

    divider "Moving nginx confs into place"
    # Move nginx conf files into place for each mapped domain
    cd nginx-configs/
    filenames=(*.dev)
    sudo mv *.dev /etc/nginx/sites-available/
    for filename in "${filenames[@]}"
    do
        sudo ln -s /etc/nginx/sites-available/$filename /etc/nginx/sites-enabled/$filename
    	echo "$filename symlinked";
    done
    cd ../
    sudo rm -rf nginx-configs/


    divider "Modifying wp-config.php"
    cd /var/www/spiritedmedia.dev/
    # define SUNRISE and set to true. via https://tomjn.com/2014/03/01/wordpress-bash-magic/
    sudo sed -i "/define( 'BLOG_ID_CURRENT_SITE', 1 );/a define( 'SUNRISE', true );" wp-config.php
    # define the redis server array for WP Redis plugin
    sudo sed -i "/define( 'SUNRISE', true );/a \$redis_server = array( 'host' => '127.0.0.1', 'port' => 6379 );" wp-config.php

    # include a local wp-config file if it exists...
    # if ( file_exists( dirname(__FILE__) . '/htdocs/wp-config-local.php') ) {
    #   include dirname(__FILE__) . '/htdocs/wp-config-local.php';
    # }
    sudo sed -i "/define( 'SUNRISE', true );/a if ( file_exists( dirname(__FILE__) . '/htdocs/wp-config-local.php') ) { include dirname(__FILE__) . '/htdocs/wp-config-local.php'; }" wp-config.php

    # Remove WP_DEBUG from wp-config.php file
    # Looking for define('WP_DEBUG', false);
    sudo sed -i "s/define('WP_DEBUG', false);//g" wp-config.php

    divider "Setting up additional sites"
    # Use WP-CLI to set-up our default sites
    cd /var/www//spiritedmedia.dev/htdocs/
    sudo -u www-data wp site create --slug="billypenn" --title="Billy Penn" --email="product@billypenn.com"
    sudo -u www-data wp site create --slug="theincline" --title="The Incline" --email="product@billypenn.com"
    sudo su

    divider "All done. Restarting the stack."
    sudo ee stack restart
fi
