#!/bin/bash

function command_exists () {
    type "$1" &> /dev/null ;
}

if ! command_exists openssl ; then
    echo "OpenSSL isn't installed. You need that to generate SSL certificates."
fi

openssl genrsa -out spiritedmedia.dev.key 2048
openssl req -new -key spiritedmedia.dev.key -out spiritedmedia.dev.csr
