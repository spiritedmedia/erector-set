#!/bin/bash

openssl genrsa -des3 -out spiritedmediaCA.key 2048
openssl req -x509 -new -nodes -key spiritedmediaCA.key -sha256 -days 1825 -out spiritedmediaCA.pem
