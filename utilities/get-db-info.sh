#! /bin/bash

cd ../ || exit
vagrant ssh -- -t 'sudo ee site info spiritedmedia.dev; exit;'
