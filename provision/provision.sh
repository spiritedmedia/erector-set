#! /bin/bash

set -e

# shellcheck source=utilities/shell-utils.sh
source "/home/vagrant/shell-utils.sh"

function update_configs() {
    conf_dir='/var/www/spiritedmedia.dev/conf'

    e_header "Moving nginx confs into place"
        # Move nginx conf files into place for each mapped domain
        cd /home/ubuntu/nginx-configs/ || exit
        filenames=(*.dev)
        sudo cp ./*.dev /etc/nginx/sites-available/
        for filename in "${filenames[@]}"
        do
            link_files "/etc/nginx/sites-available/$filename" "/etc/nginx/sites-enabled/$filename"
        done
    e_success "Done."

    e_header "Moving local-photon configs into place"
        sudo cp local-photon.nginx.conf "$conf_dir/nginx/local-photon.nginx.conf"
        sudo cp photon-config.php /var/www/spiritedmedia.dev/photon/config.php
        sudo chown -R www-data: /var/www/spiritedmedia.dev/photon/
    e_success "Done."

    e_header "Moving PHP extension config files into place"
        cd /home/ubuntu/php-configs/ || exit
        xdebug_ini_path=$(php --ini | grep xdebug | head -1)
        mods_available_path=$(dirname "$(readlink -f "${xdebug_ini_path//,}")")
        sudo cp ./*.ini "$mods_available_path"/
    e_success "Done."

    e_header "Moving SSL files into place"
        cd /home/ubuntu/ssl/ || exit
        ssl_conf_dir="$conf_dir/ssl"
        sudo mkdir $ssl_conf_dir || exit
        sudo cp spiritedmedia.dev.crt $ssl_conf_dir/
        sudo cp 02-ca-signed-certificate/spiritedmedia.dev.key $ssl_conf_dir/
        sudo cp ssl.conf "$conf_dir/nginx/"
    e_success "Done."

    e_header "Cleaning up"
    cd ../ || exit

    e_success "All done. Restarting the stack."
    sudo ee stack restart
}

if command_exists ee ; then
    update_configs
else

    e_header "Installing Unattended Upgrades"
    sudo apt-get install unattended-upgrades
    e_success "Done installing unattended upgrades."

    if ! command_exists git ; then
        e_header "Installing Git"
        # We need git installeed before we can set our name and email
        sudo apt-get update
        sudo apt-get --yes install git
        e_success "Done installing Git."
    fi

    if ! command_exists pecl ; then
        e_header "Installing PEAR"
        sudo apt-get install --yes php-pear
        e_success "Done installing PEAR."
    fi

    if ! command_exists svn ; then
        e_header "Installing Subversion"
        sudo add-apt-repository universe
        sudo apt-get update
        sudo apt-get install --yes subversion
        e_success "Done installing Subversion."
    fi

    e_header "Setting Global Git Config"
    # EasyEngine needs our name and email for Git reasons, without it the script will fail
    sudo git config --global user.email "systems@spiritedmedia.com"
    sudo git config --global user.name "Spirited Media"
    e_success "Done."

    e_header "Installing EasyEngine"
    sudo wget -qO ee rt.cx/ee && sudo bash ee || exit
    # shellcheck disable=SC1091
    source /etc/bash_completion.d/ee_auto.rc
    e_success "Done."

    e_header "Installing Redis"
    sudo ee stack install --redis
    sudo ee stack install --phpredisadmin
    e_success "Done installing Redis."

    e_header "Setting up spiritedmedia.dev multisite"
    sudo ee site create spiritedmedia.dev --wpsubdomain --php7 --user=admin --pass=admin --email=systems@spiritedmedia.com --experimental
    e_success "Done setting up spiritedmedia.dev multisite"

    # See https://github.com/EasyEngine/easyengine/issues/741#issuecomment-229497541
    e_header "Fix random memcache warnings when using WP CLI???"
    # Disable and enable again module igbinary to resolve redis
    sudo phpdismod igbinary && phpenmod igbinary
    # For memcached, disable memcached module, and make sure memcache is enabled
    sudo phpdismod memcached && phpenmod memcache
    e_success "Done."

    # Allow the dev tools from our host IP without requiring auth
    e_header "IP Whitelisting for the dev tools on port 22222"
    # Whitelist the entire subnet because... why not?
    sudo ee secure --ip 192.168.33.0/24 --quiet
    e_success "Done."

    e_header "Installing phpize and GraphicsMagick"
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
    e_success "Done."

    e_header "Installing image libraries"
    sudo apt-get install --yes optipng pngquant jpegoptim webp
    # Link the tools to /usr/local/bin/* which is what the Photon script expects
    sudo ln -sf /usr/bin/jpegoptim /usr/local/bin/jpegoptim
    sudo ln -sf /usr/bin/optipng /usr/local/bin/optipng
    sudo ln -sf /usr/bin/pngquant /usr/local/bin/pngquant
    sudo ln -sf /usr/bin/cwebp /usr/local/bin/cwebp
    e_success "Done."

    e_header "Checking out Local Photon for dynamic image resizing"
    cd /var/www/spiritedmedia.dev/ || exit
    sudo svn co http://code.svn.wordpress.org/photon/
    sudo chown -R www-data: photon/
    e_success "Done."

    e_header "Setting up photon.spiritedmedia.dev"
    sudo ee site create photon.spiritedmedia.dev --php7 --experimental
    sudo svn co http://code.svn.wordpress.org/photon/ /var/www/photon.spiritedmedia.dev/htdocs/
    sudo chown -R www-data: /var/www/photon.spiritedmedia.dev/htdocs/
    e_success "Done."

    # Now that EasyEngine is set up we can update the configuration files
    update_configs

    # Add the vagrant user to the www-data group so that it has better access
    # to PHP and Nginx related files.
    # https://github.com/Varying-Vagrant-Vagrants/VVV/commit/9162a564d4823973aea490610ec4d4d51e00d5e4
    e_header "Adding the \`ubuntu\` user to the www-data group"
    usermod -a -G www-data ubuntu
    e_success "Done."

    e_header "Adding a credentials directory"
    # The actual credentials for this file are in our 1Password vault
    cd /var/www/spiritedmedia.dev/ || exit
    sudo mkdir credentials/
    touch credentials/google-service-account-credentials.json
    e_success "Done."

    e_header "Modifying wp-config.php"
        cd /var/www/spiritedmedia.dev/ || exit
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
        sudo sed -i "s/define('WP_DEBUG', false);//g" wp-config.php
    e_success "Done modifying wp-config.php"

    e_success "All done. Restarting the stack."
    sudo ee stack restart
fi
