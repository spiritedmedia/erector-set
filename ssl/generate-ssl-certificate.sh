#!/bin/bash

function command_exists () {
    type "$1" &> /dev/null ;
}

if ! command_exists openssl ; then
    echo "OpenSSL isn't installed. You need that to generate SSL certificates."
fi

openssl x509 -req -in 02-ca-signed-certificate/spiritedmedia.dev.csr -CA 01-certificate-authority/spiritedmediaCA.pem -CAkey 01-certificate-authority/spiritedmediaCA.key -CAcreateserial -out spiritedmedia.dev.crt -days 1825 -sha256 -extfile spiritedmedia.dev.ext
