# Creating a Self-Signed SSL Certificate for Our Local Development Environment

_Note: This was mostly cribbed from https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/_

**tl;dr** We're going to make ourselves a certificate authority and sign our own certificates so SSL can work locally.


## Installing Pre-Existing Certs

See the section in [the main README.md](../README.md#installing-ssl-certs).


## Regenerating Certs

If we ever need to regenerate certs here is how you do it. You don't need to do this if you just want to get SSL working with pre-existing keys and certificates mentioned above. Pretty much the only time you'll need to do this is when a new site is being set up.


### 1) Creating a Certificate Authority

Run `01-certificate-authority/generate-certificate-authority.sh`

It will prompt you to answer some questions. Here are the answers I used.

```
Generating RSA private key, 2048 bit long modulus
..............................+++
......+++
e is 65537 (0x10001)
Enter pass phrase for spiritedmediaCA.key:spiritedmedia
Verifying - Enter pass phrase for spiritedmediaCA.key:spiritedmedia
Enter pass phrase for spiritedmediaCA.key:spiritedmedia
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:US
State or Province Name (full name) []:Virginia
Locality Name (eg, city) []:Great Falls
Organization Name (eg, company) []:Spirited Media
Organizational Unit Name (eg, section) []:
Common Name (eg, fully qualified host name) []:Spirited Media
Email Address []:systems@spiritedmedia.com
```

See the "Installing a Custom Root Certificate" section above for installing this certificate on your system.


### 2) Generating CA signed Certificate

Run `02-ca-signed-certificate/generate-ca-signed-certificate.sh`

It will prompt you to answer some questions. Here are the answers I used.

```
Generating RSA private key, 2048 bit long modulus
...............................+++
.......................+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:US
State or Province Name (full name) []:Virginia
Locality Name (eg, city) []:Great Falls
Organization Name (eg, company) []:Spirited Media
Organizational Unit Name (eg, section) []:
Common Name (eg, fully qualified host name) []:Spirited Media
Email Address []:systems@spiritedmedia.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
```


### 3) Generate SSL Certificate

Run `generate-ssl-certificate.sh`

It will ask you for the passphrase for the certificate authority key we generated in step 1. Enter `spiritedmedia`:

```
Signature ok
subject=/C=US/ST=Virginia/L=Great Falls/O=Spirited Media/CN=Spirited Media/emailAddress=systems@spiritedmedia.com
Getting CA Private Key
Enter pass phrase for 01-certificate-authority/spiritedmediaCA.key:spiritedmedia
```


### 4) Install the New Certificates

Run `vagrant provision`
