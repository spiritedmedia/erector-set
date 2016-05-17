#! /bin/bash

function command_exists () {
    type "$1" &> /dev/null ;
}

# By storing the date now, we can calculate the duration of provisioning at the
# end of this script.
start_seconds="$(date +%s)"

if ! command_exists npm ; then
    echo "NPM isn't installed. You need that to build the theme."
fi
if ! command_exists bower ; then
    echo "Bower isn't installed. You need that to build the theme."
fi
if ! command_exists bundle ; then
    echo "Bundle isn't installed. You need that to build the theme."
fi
if ! command_exists composer ; then
    echo "Composer isn't installed. You need that to build the theme."
fi
if ! command_exists grunt ; then
    echo "Grunt isn't installed. You need that to build the theme."
fi

# Make our utility helper scripts executeable
chmod +x utilities/error-logging.sh
chmod +x utilities/get-db-info.sh

# Check if the /public directory is empty or not
if [ "$(ls -A public/)" ]; then
    echo "The /public directory is not empty."
    while true; do
    read -p "Delete everything in /public and start over? (y/n): " yn
    case $yn in
        [Yy]* )
            rm -rf public/
            # Clone our /wp-content/ repo into /public/
            git clone --recursive git@github.com:spiritedmedia/pedestal-beta.git public/
            break
            ;;
        [Nn]* )
            echo "Skipping...";
            break
            ;;
        * ) echo
            "Please answer yes or no."
            ;;
    esac
done
fi

# Update the box
vagrant box update

# Build the box
vagrant up

# Add a debug.log file for when define('debuglog') is set to true
cd public/wp-content/
touch debug.log

# Go to pedestal directory and build the theme
cd themes/pedestal/
npm install
bower install
bundle install
composer update -o
grunt build

# And it's done
end_seconds="$(date +%s)"
echo "-----------------------------"
echo "Installation complete in "$((${end_seconds} - ${start_seconds}))" seconds"
