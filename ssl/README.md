# Creating a Self-Signed SSL Certificate for Our Local Development Environment

_Note: This was mostly cribbed from https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/_

**tl;dr** We're going to make ourselves a certificate authority and sign our own certificates so SSL can work locally.

## Installing Pre-Existing Certs

### Installing a Custom Root Certificate
This will tell your computer to trust our self signed certs.

1. Open the macOS Keychain app
2. Go to File > Import Items…
3. Select the `01-certificate-authority/spiritedmediaCA.pem`
4. Search for `Spirited Media` and double click on the certificate to edit the info
5. Twirl down the Trust section
6. Set `When using this certificate` to `Always Trust`
7. Close the window
8. Close the Keychain app

Firefox doesn't use the Keychain app and manages its own certificates on its own.

1. Open Firefox preferences 
2. Select *Privacy & Security* in the left menu
3. Click the *View Certificates...* button
4. Click the *Authorities* tab
5. Import
6. Select `01-certificate-authority/spiritedmediaCA.pem`

### Move files in to place 

1. SSH into your Vagrant box
2. Go to our conf directory: `cd /var/www/spiritedmedia.dev/conf/`
3. Create an ssl directory: `sudo mkdir ssl`
4. Copy `spiritedmedia.dev.crt` to `/var/www/spiritedmedia.dev/conf/ssl/spiritedmedia.dev.crt`
5. Copy `02-ca-signed-certificate/spiritedmedia.dev.key` to `/var/www/spiritedmedia.dev/conf/ssl/spiritedmedia.dev.key`   
6. Copy `ssl.conf` to `/var/www/spiritedmedia.dev/conf/nginx/ssl.conf`
7. Restart nginx: `sudo ee stack restart --nginx`

### Updating URLs

Replace the site URL values in the database with https versions (otherwise you get endless redirects)

Run the following in Sequel Pro:
```
UPDATE `wp_options` SET `option_value` = 'https://spiritedmedia.dev' WHERE `option_value` = 'http://spiritedmedia.dev';
UPDATE `wp_2_options` SET `option_value` = 'https://billypenn.dev' WHERE `option_value` = 'http://billypenn.dev';
UPDATE `wp_3_options` SET `option_value` = 'https://theincline.dev' WHERE `option_value` = 'http://theincline.dev';
``` 
All done!

## Regenerating Certs

If we ever need to regenerate certs here is how you do it. You don't need to do this if you just want to get SSL working with pre-existing keys and certificates mentioned above.

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