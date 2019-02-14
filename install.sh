#!/bin/bash

set -e

source "utilities/shell-utils.sh"

REPO_URL="git@github.com:spiritedmedia/spiritedmedia.git"
PHOTON_REPO_URL="git@github.com:spiritedmedia/local-photon.git"
ROOT_DIR=$(pwd)

# By storing the date now, we can calculate the duration of provisioning at the
# end of this script.
start_seconds="$(date +%s)"

if ! command_exists yarn ; then
    e_error "Yarn isn't installed. You need that to build the theme."
fi
if ! command_exists composer ; then
    e_error "Composer isn't installed. You need that to build the theme."
fi
if ! command_exists grunt ; then
    e_error "Grunt isn't installed. You need that to build the theme."
fi

# Check if the /public directory is empty or not
if [ "$(ls -A public/)" ]; then
    e_warning "The /public directory is not empty."
    while true; do
        seek_confirmation "Delete everything in /public and start over?"
        if is_confirmed; then
            rm -rf public/
            mkdir public/
            break
        else
            e_warning "Skipping..."
        fi
    done
else
    e_header "The /public directory doesn't exist. Continuing with installation..."
fi

# Make sure the /public directory exists
if [ ! -d "public" ]; then
    mkdir public/
fi

e_header 'Adding SSL certificates to host macOS Keychain'
if command_exists security ; then
    # Delete any existing certificates
    # via https://unix.stackexchange.com/a/227014
    sudo security find-certificate -c 'Spirited Media' -a -Z | sudo awk '/SHA-1/{system("security delete-certificate -Z "$NF)}'

    # Trust the Root Certificate cert
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain 'ssl/01-certificate-authority/spiritedmediaCA.pem'
fi
e_success "Done."

# Destroy the box if it is running
vagrant destroy --force

# Update the box
vagrant box update

# The box will be provisioned with this initial boot
vagrant up

# Remove a .git/ directory if it is already present
if [ -d "public/.git/" ]; then
    e_header "Removing previous .git/ directory..."
    rm -rf public/.git/
    e_success "Done."
fi

e_header "Cloning repo and moving files into place..."

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

e_success "Done."

# Run the bin/install.sh script in the root of the Pedestal repo to install dependencies and build the themes
e_header "Building the themes..."
cd "$ROOT_DIR"
cd public/
# shellcheck disable=SC1091
source bin/install.sh
grunt build
e_success "Done."

# And it's done
end_seconds="$(date +%s)"
e_success "Installation complete in "$((end_seconds - start_seconds))" seconds"
