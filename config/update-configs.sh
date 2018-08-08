#!/bin/bash

function command_exists () {
    type "$1" &> /dev/null ;
}

function divider() {
    echo -------------------------------------------------------- ;
    if [ "$1" ]; then
        echo "$1"
    fi
}

if command_exists ee ; then

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

  divider "Moving PHP extension config files into place"
  xdebug_ini_path=$(php --ini | grep xdebug | head -1)
  mods_available_path=$(dirname $(readlink -f "${xdebug_ini_path//,}"))
  cd /home/ubuntu/php-configs/
  sudo mv *.ini "$mods_available_path"/

  divider "Moving local-photon configs into place"
  sudo mv local-photon.nginx.conf /var/www/spiritedmedia.dev/conf/nginx/local-photon.nginx.conf
  sudo cp photon-config.php /var/www/spiritedmedia.dev/photon/config.php
  sudo chown -R www-data: /var/www/spiritedmedia.dev/photon/

  divider "Cleaning up"
  cd ../
  sudo rm -rf nginx-configs/
  sudo rm -rf php-configs/

  divider "All done. Restarting the stack."
  sudo ee stack restart

fi
