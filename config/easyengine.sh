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

    if ! command_exists pecl ; then
        sudo apt-get install --yes php-pear
    fi

    if ! command_exists svn ; then
        sudo apt-get install --yes subversion
    fi

    divider "Setting Global Git Config"
    # EasyEngine needs our name and email for Git reasons, without it the script will fail
    sudo git config --global user.email "systems@spiritedmedia.com"
    sudo git config --global user.name "Spirited Media"

    divider "Installing EasyEngine"
    sudo wget -qO ee rt.cx/ee && sudo bash ee || exit 1
    source /etc/bash_completion.d/ee_auto.rc

    divider "Installing Redis"
    sudo ee stack install --redis
    sudo ee stack install --phpredisadmin

    divider "Setting up spiritedmedia.dev multisite"
    sudo ee site create spiritedmedia.dev --wpsubdomain --php7 --user=admin --pass=admin --email=systems@spiritedmedia.com --experimental

    divider "Fix random memcache warnings when using WP CLI???"
    # See https://github.com/EasyEngine/easyengine/issues/741#issuecomment-229497541
    # PHP Warning:  PHP Startup: Unable to load dynamic library '/usr/lib/php/20151012/memcached.so' - /usr/lib/php/20151012/memcached.so: undefined symbol: php_msgpack_serialize in Unknown on line 0

    #Disable and enable again module igbinary to resolve redis
    sudo phpdismod igbinary && phpenmod igbinary

    # For memcached, disable memcached module, and make sure memcache is enabled
    sudo phpdismod memcached && phpenmod memcache

    # Allow the dev tools from our host IP without requiring auth
    divider "IP Whitelisting for the dev tools on port 22222"
    # Whitelist the entire subnet because... why not?
    sudo ee secure --ip 192.168.33.0/24 --quiet

    divider "Installing phpize and GraphicsMagick"
    sudo apt-get install --yes php7.0-dev graphicsmagick libgraphicsmagick1-dev

    # Install the PHP extension (You can check for the latest version at http://pecl.php.net/package/gmagick)
    sudo pecl install gmagick-2.0.4RC1

    # Create a gmagick specific configuration file to load the PHP extension
    sudo ln -s /etc/php/7.0/mods-available/gmagick.ini /etc/php/7.0/fpm/conf.d/20-gmagick.ini

    # Add our configuration
    sudo cat > /etc/php/7.0/mods-available/gmagick.ini << EOF
; configuration for php graphicsmagick module
; priority=20
extension=gmagick.so
EOF

    divider "Installing image libraries"
    sudo apt-get install --yes optipng pngquant jpegoptim webp
    # Link the tools to /usr/local/bin/* which is what the Photon script expects
    sudo ln -sf /usr/bin/jpegoptim /usr/local/bin/jpegoptim
    sudo ln -sf /usr/bin/optipng /usr/local/bin/optipng
    sudo ln -sf /usr/bin/pngquant /usr/local/bin/pngquant
    sudo ln -sf /usr/bin/cwebp /usr/local/bin/cwebp

    divider "Checking out Local Photon for dynamic image resizing"
    cd /var/www/spiritedmedia.dev/
    sudo svn co http://code.svn.wordpress.org/photon/
    sudo chown -R www-data: photon/

    divider "Setting up photon.spiritedmedia.dev"
    sudo ee site create photon.spiritedmedia.dev --php7 --experimental
    sudo svn co http://code.svn.wordpress.org/photon/ /var/www/photon.spiritedmedia.dev/htdocs/
    sudo chown -R www-data: /var/www/photon.spiritedmedia.dev/htdocs/

    divider "Moving nginx confs into place"
    # Move nginx conf files into place for each mapped domain
    cd /home/ubuntu/nginx-configs/
    filenames=(*.dev)
    sudo mv *.dev /etc/nginx/sites-available/
    for filename in "${filenames[@]}"
    do
        sudo ln -s /etc/nginx/sites-available/$filename /etc/nginx/sites-enabled/$filename
    	echo "$filename symlinked";
    done

    # Move local-photon configs into place
    sudo mv local-photon.nginx.conf /var/www/spiritedmedia.dev/conf/nginx/local-photon.nginx.conf
    sudo cp photon-config.php /var/www/spiritedmedia.dev/photon/config.php
    sudo chown -R www-data: /var/www/spiritedmedia.dev/photon/

    cd ../
    sudo rm -rf nginx-configs/

    divider "Adding a credentials directory"
    # The actual credentials for this file are in our 1Password vault
    cd /var/www/spiritedmedia.dev/
    sudo mkdir credentials/
    touch credentials/google-service-account-credentials.json

    # divider "Setting up additional sites"
    # Use WP-CLI to set-up our default sites
    # cd /var/www//spiritedmedia.dev/htdocs/
    # sudo -u www-data wp site create --slug="billypenn" --title="Billy Penn" --email="systems@spiritedmedia.com"
    # sudo -u www-data wp site create --slug="theincline" --title="The Incline" --email="systems@spiritedmedia.com"
    # sudo su

    divider "Modifying wp-config.php"
    cd /var/www/spiritedmedia.dev/
    # define SUNRISE and set to true. via https://tomjn.com/2014/03/01/wordpress-bash-magic/
    sudo sed -i "/define( 'BLOG_ID_CURRENT_SITE', 1 );/a define( 'SUNRISE', true );" wp-config.php
    # define the redis server array for WP Redis plugin
    # We intentionally break the Redis connection to disable Redis caching locally which is an ugly hack
    # The real port is 6379
    sudo sed -i "/define( 'SUNRISE', true );/a \$redis_server = array( 'host' => '127.0.0.1', 'port' => 6379 );" wp-config.php

    # include a local wp-config file if it exists...
    # if ( file_exists( dirname(__FILE__) . '/htdocs/wp-config-local.php') ) {
    #   include dirname(__FILE__) . '/htdocs/wp-config-local.php';
    # }
    sudo sed -i "/define( 'SUNRISE', true );/a if ( file_exists( dirname(__FILE__) . '/htdocs/wp-config-local.php') ) { include dirname(__FILE__) . '/htdocs/wp-config-local.php'; }" wp-config.php

    # Remove a duplicate define('WP_ALLOW_MULTISITE', true);
    sudo sed -i "s/define('WP_ALLOW_MULTISITE', true);//g" wp-config.php

    # Remove WP_DEBUG from wp-config.php file
    # Looking for define('WP_DEBUG', false);
    sudo sed -i "s/define('WP_DEBUG', false);//g" wp-config.php

    divider "All done. Restarting the stack."
    sudo ee stack restart
fi
