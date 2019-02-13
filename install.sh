#!/bin/bash

set -e

REPO_URL="git@github.com:spiritedmedia/spiritedmedia.git"
PHOTON_REPO_URL="git@github.com:spiritedmedia/local-photon.git"
ROOT_DIR=$(pwd)

function command_exists () {
    type "$1" &> /dev/null ;
}

# By storing the date now, we can calculate the duration of provisioning at the
# end of this script.
start_seconds="$(date +%s)"

if ! command_exists yarn ; then
    echo "Yarn isn't installed. You need that to build the theme."
fi
if ! command_exists composer ; then
    echo "Composer isn't installed. You need that to build the theme."
fi
if ! command_exists grunt ; then
    echo "Grunt isn't installed. You need that to build the theme."
fi

# Check if the /public directory is empty or not
if [ "$(ls -A public/)" ]; then
    echo "The /public directory is not empty."
    while true; do
        read -p "Delete everything in /public and start over? (y/n): " yn
        case $yn in
            [Yy]* )
                rm -rf public/
                mkdir public/
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
else
    echo "The /public directory doesn't exist. Continuing with installation..."
fi

## Make sure the /public directory exists
if [ ! -d "public" ]; then
    mkdir public/
fi

# Destroy the box if it is running
vagrant destroy --force

# Update the box
vagrant box update

# The box will be provisioned with this initial boot
vagrant up

# Remove a .git/ directory if it is already present
if [ -d "public/.git/" ]; then
    echo "-----------------------------"
    echo "Removing previous .git/ directory..."
    rm -rf public/.git/
fi

echo "-----------------------------"
echo "Cloning repo and moving files into place..."

git clone --recursive $REPO_URL tmp/
mv tmp/.git public/
cd public/
git reset --hard origin/master
cd ../
rm -rf tmp/

# Move image-proxy.php into place
git clone --recursive $PHOTON_REPO_URL tmp/
mv tmp/image-proxy.php public/
rm -rf tmp/

# Add a wp-config-local.php file to the root so we can toggle debugging constants and such.
cp config/wp-config-local.php public/

# Run the bin/install.sh script in the root of the Pedestal repo to install dependencies and build the themes
echo "-----------------------------"
echo "Building the themes..."
cd $ROOT_DIR
cd public/
source bin/install.sh
grunt build

# And it's done
end_seconds="$(date +%s)"
echo "-----------------------------"
echo "Installation complete in "$((${end_seconds} - ${start_seconds}))" seconds"
