#! /bin/bash

cd ../ || exit
vagrant ssh -- -t 'sudo ee log show spiritedmedia.dev --wp --php;'
