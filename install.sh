#! /bin/bash

# Check if the /public directory is empty or not
if [ "$(ls -A public/)" ]; then
    echo "The /public directory is not empty."
    while true; do
    read -p "Delete everything in /public? (y/n): " yn
    case $yn in
        [Yy]* ) rm -rf public/; break;;
        [Nn]* ) echo "Aborting install"; exit;; # TODO: Don't exit but instead just skip the step of cloning the repo. 
        * ) echo "Please answer yes or no.";;
    esac
done
fi

# Clone our /wp-content/ repo into /public/
git clone --recursive git@github.com:spiritedmedia/pedestal-beta.git public/

# Update the box
vagrant box update

# Build the box
vagrant up
