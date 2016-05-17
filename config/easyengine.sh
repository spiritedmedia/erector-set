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
    sudo ee stack restart
fi
