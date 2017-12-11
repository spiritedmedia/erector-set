#!/bin/bash

function command_exists () {
    type "$1" &> /dev/null ;
}

if ! command_exists openssl ; then
    echo "OpenSSL isn't installed. You need that to generate SSL certificates."
fi

openssl genrsa -des3 -out spiritedmediaCA.key 2048
openssl req -x509 -new -nodes -key spiritedmediaCA.key -sha256 -days 1825 -out spiritedmediaCA.pem
