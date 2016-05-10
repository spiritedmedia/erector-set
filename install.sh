#! /bin/bash

# Clone our /wp-content/ repo into /public/
git clone git@github.com:spiritedmedia/pedestal-beta.git public/

# Build the box
vagrant up

# Clone Pedestal into the wp-contnet directory
