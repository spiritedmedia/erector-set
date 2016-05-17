#! /bin/bash

cd ../
vagrant ssh -- -t 'sudo ee site info spiritedmedia.dev; exit;'
