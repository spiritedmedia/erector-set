#!/bin/bash

openssl genrsa -out spiritedmedia.dev.key 2048
openssl req -new -key spiritedmedia.dev.key -out spiritedmedia.dev.csr
