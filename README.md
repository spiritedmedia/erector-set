# Spirited Media - Erector Set
This will set-up a local instance of the Spirited Media multisite. Assumes you're using a Mac.


## Details

- IP: `192.168.33.10`
- Domain: `spiritedmedia.dev`
- Dev tools: `spiritedmedia.dev:22222`
- Path inside VM: `/var/www/spiritedmedia.dev`


## Domains

The multiste is set-up to use subdomains for each site. We map domain names to a site via the [Mercator plugin](https://github.com/humanmade/Mercator)

| Site ID | Mapped Domain                           | Unmapped Domain                                                     |
|---------|-----------------------------------------|---------------------------------------------------------------------|
| 1       | --                                      | [spiritedmedia.dev](http://spiritedmedia.dev)                       |
| 2       | [billypenn.dev](https://billypenn.dev)   | [billypenn.spiritedmedia.dev](https://billypenn.spiritedmedia.dev)   |
| 3       | [theincline.dev](https://theincline.dev) | [theincline.spiritedmedia.dev](https://theincline.spiritedmedia.dev) |
| 4       | [denverite.dev](https://denverite.dev) | [denverite.spiritedmedia.dev](https://denverite.spiritedmedia.dev) |


## Installation + Configuration

You'll need some basic tools on your machine to get started. Run the following commands in your terminal app (either Terminal.app or [iTerm2](https://www.iterm2.com/)):

```sh
# Install Homebrew if it's not installed already
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Clone the repo and move into it
git clone https://github.com/spiritedmedia/erector-set.git spiritedmedia.dev && cd spiritedmedia.dev
```

Install basic host dependencies on your computer. Feel free to skip any
dependencies you know you have already.

```sh
# PHP 7.1 is needed to run PHPCS and set up linting and debugging tools in your editor
brew install php@7.1
brew install composer
brew install node
# OpenSSL is needed to generate new SSL certificates
brew install openssl
```

### Vagrant / VirtualBox

If you don't have [Vagrant](https://www.vagrantup.com/) or
[VirtualBox](https://www.virtualbox.org/) installed you'll need to install them.
VirtualBox is a prequisite of Vagrant so the installation order matters. You can
install them manually or with [Homebrew Cask](https://github.com/Homebrew/homebrew-cask) (included with Homebrew).

```sh
brew cask install virtualbox
brew cask install vagrant
```

If you already have Vagrant installed, make sure your Vagrant version is at
least 2.1.x with `vagrant -v`. If it's lower than 2.1.x, then update it manually
or with `brew cask reinstall vagrant`.

You'll need a couple Vagrant plugins, however they should be installed
automatically:

- [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)
- [vagrant-disksize](https://github.com/sprotheroe/vagrant-disksize)

### Sequel Pro Nightly

Install Sequel Pro for connecting to the database with a GUI. You
should [install the nightly version](https://sequelpro.com/test-builds) because
the current stable version as of 2019-03-04
[has some issues](https://github.com/sequelpro/sequelpro/issues/2932) with importing
`utf8mb4`-encoded databases, which we need to preserve emojis.


### Prepare Database

1. Get a database dump from another developer or [follow the instructions in this document](https://github.com/spiritedmedia/systems/blob/master/database-import/README.md) to get a fresh database dump for local use.
2. If the file is compressed, uncompress it so you have a `.sql` file
3. Rename the file to `spiritedmedia_dev.sql`
4. Move the file to `database/`

During provisioning, this database dump will be imported.


### Install

Run `./install.sh` to kick off the rest of the process. You will be prompted to enter your system's administrator password. Otherwise, please be patient while things install.


### Installing SSL Certs

We need to tell your computer to trust our self-signed SSL certificates.

This should happen automatically during the installation process, but if something doesn't seem to work, you can do this manually following the instructions below.

Either way, Firefox requires an additional step to accept certs from the macOS Keychain.

1. Type `about:config` in the address bar
2. Search for `security.enterprise_roots.enabled`
3. Set it to `true`

[This works in Firefox 63+](https://superuser.com/a/1369035/926865). If you are on an older version… update your browser!

#### Manual Installation

##### Installing a Custom Root Certificate

This will tell your computer to trust our self signed certs.

1. Open the macOS Keychain Access app
2. Go to File > Import Items…
3. Select the `ssl/01-certificate-authority/spiritedmediaCA.pem`
4. Search for `Spirited Media` and double click on the certificate to edit the info
5. Twirl down the Trust section
6. Set `When using this certificate` to `Always Trust`
7. Close the window
8. Close the Keychain app

Follow the instructions in the previous section to tell Firefox to use the system Keychain. Or if for some reason you can't use Firefox 63+, you'll need to take a different approach:

1. Open Firefox preferences
2. Select *Privacy & Security* in the left menu
3. Click the *View Certificates...* button
4. Click the *Authorities* tab
5. Import
6. Select `ssl/01-certificate-authority/spiritedmediaCA.pem`

##### Move files in to place

1. SSH into your Vagrant box
2. Go to our conf directory: `cd /var/www/spiritedmedia.dev/conf/`
3. Create an ssl directory: `sudo mkdir ssl`
4. Copy `ssl/spiritedmedia.dev.crt` to `/var/www/spiritedmedia.dev/conf/ssl/spiritedmedia.dev.crt`
5. Copy `ssl/02-ca-signed-certificate/spiritedmedia.dev.key` to `/var/www/spiritedmedia.dev/conf/ssl/spiritedmedia.dev.key`
6. Copy `ssl.conf` to `/var/www/spiritedmedia.dev/conf/nginx/ssl.conf`
7. Restart nginx: `sudo ee stack restart --nginx`


### Configuring SSH Access

You'll need to make sure SSH is configured correctly in order to connect to the database at `spiritedmedia.dev`.

Run `vagrant ssh-config --host spiritedmedia.dev`, copy the contents, paste it into your `~/.ssh/config` file.

To SSH directly in to the box you can go to the `spiritedmedia.dev` directory (or any subdirectory) and type `vagrant ssh`.


### Connect to the Database

The final output of the installation script should be some information about the site, including the database credentials. Use these to connect to the database.

To run the site info script again, do the following in this repo's root directory:

1. Navigate to the `utilities` directory: `cd utilities/`
2. Get the database credentials: `./get-site-info.sh`
3. Note the `DB_USER`, `DB_PASS` values displayed

![image 2019-02-15 at 12 38 11](https://user-images.githubusercontent.com/1757914/52874299-2968ec00-311f-11e9-8229-8bb24ac3253a.png)

Adding an SSH configuration to your `~/.ssh/config` file should allow you to connect to the database at the SSH host `spiritedmedia.dev`.

1. Open Sequel Pro
2. Switch to the SSH tab to show SSH fields
3. Enter the following details, leaving "Connect using SSL" unchecked

| Name         | Value             |
|--------------|-------------------|
| MySQL Host   |  127.0.0.1        |
| Username     | `DB_USER`         |
| Password     | `DB_PASS`         |
| Database     | spiritedmedia_dev |
| Port         | 3306 (default)    |
| SSH Host     | spiritedmedia.dev |
| SSH User     |                   |
| SSH Password |                   |
| SSH Port     |                   |

![image 2019-02-15 at 12 39 35](https://user-images.githubusercontent.com/1757914/52874281-18b87600-311f-11e9-99fd-dfcadbaf90df.png)

If you skipped the pre-installation step of adding `database/spiritedmedia_dev.sql`, or there was a problem running that step during initial provisioning, you can import the database now.

Get it from another developer, or [follow the instructions in this document](https://github.com/spiritedmedia/systems/blob/master/database-import/README.md)
to get a fresh database dump for local use.

If you need to add yourself as a super-admin user, follow the instructions in
the ["Adding A New Super-Admin Manually"](https://github.com/spiritedmedia/systems/tree/master/database-import#adding-a-new-super-admin-manually)
section in the Systems repo.



### wp-config-local.php

In the root of the `public/` directory there's a file called `wp-config-local.php`. This file contains environment-specific configuration as well as secrets like API keys. This file will get included by `wp-config.php` automagically.

**You'll need to update the `***` values with real credentials in order to get things working properly.** There will be no obvious error messages until you try and use a feature that requires a valid credential because `wp-config-local.php` is filled with dummy values initially. Ask another developer for the real credentials.

An example local config file should exist already. If the file was somehow deleted, ask a developer for their copy and drop it into place.

More constants can be found on the [wp-config.php codex page](https://codex.wordpress.org/Editing_wp-config.php) or https://gist.github.com/MikeNGarrett/e20d77ca8ba4ae62adf5


### Google Service Account Credentials

In addition to setting up `wp-config-local.php` properly, you will need to SSH in to the box and add our Google Service account credentials to `/var/www/spiritedmedia.dev/credentials/google-service-account-credentials.json`. The contents of this file should be stored in our 1Password vault.


## Error Logging

### debug.log

If you defined `WP_DEBUG_LOG` to `true` in your `wp-config-local.php` file you can watch `public/wp-content/debug.log` in something like Console.app.

### Direct Access to WordPress/PHP Error Logs

In the directory you cloned Erector Set into...

1. Navigate to the `utilities` directory: `cd utilities/`
2. Run: `./error-logging.sh` which shows WordPress and PHP error logs

### Other Error Logs

See [EasyEngine log documentation](https://easyengine.io/docs/commands/log).

The `ee log` commands will log errors to the console in real time, meaning that you need to trigger an error to see a new log message. If you don't know what triggered the error, run the desired command and the locations of the monitored log files will show up. You can view the contents of these files directly.

Some helpful commands:

```
# To monitor Nginx, PHP, MySQL, WordPress logs
ee log show

# To reset Nginx, PHP, MySQL, WordPress logs
ee log reset

ee log show --nginx
ee log show --mysql
```


## Setting Up Remote Debugging

Remote debugging allows you to debug PHP on our Vagrant box.

The box is configured for remote debugging already. You'll have to set it up in your editor/IDE. That approach will be different for every editor, but @montchr has tested with Visual Studio Code.

N.B. There may be more steps to this process but we haven't checked because that would require a complete teardown of our editor and browser extensions. We should also test remote debugging with Atom and maybe Sublime Text 3.

### VS Code

Install the [PHP Debug extension](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug)

Next, add a `launch.json` debugging configuration for PHP [as described here](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug#user-content-vs-code-configuration). Make sure you add a `pathMappings` property to map the remote webroot to the webroot on your local machine (aka the `public/` directory). Here's @montchr's `launch.json` as an example:

```json
{
  // Use IntelliSense to learn about possible attributes.
  // Hover to view descriptions of existing attributes.
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for XDebug",
      "type": "php",
      "request": "launch",
      "port": 9000,
      "pathMappings": {
        "/var/www/spiritedmedia.dev/htdocs": "${workspaceRoot}"
      }
    },
    {
      "name": "Launch currently open script",
      "type": "php",
      "request": "launch",
      "program": "${file}",
      "cwd": "${fileDirname}",
      "port": 9000
    }
  ]
}
```


## How to Disable Full Page Caching for Local Environments

Full-page caching is enabled for non-logged in visitors on the local environment. This includes (almost) every request that goes through PHP, including images passing through Photon.

If for some reason you need to disable full-page caching across the board, follow these steps:

 - Edit the nginx conf for spiritedmedia.dev: `sudo ee site edit spiritedmedia.dev`
 - Uncomment the line with `include common/php7.conf;` and comment out the line with `include common/redis-php7-modified.conf;` and save
 - That should automatically restart nginx but if not run `sudo ee stack restart --nginx`


## Subsequent Provisioning

If you need to update some config file it's best to make changes in this repo
and run `vagrant provision` to overwrite the files on the box. See the
`update_configs()` function in
[`provision/provision.sh`](provision/provision.sh) for more information about
what will be overwritten.

Note that `wp-config.php` will not be modified. If you need to make updates to
WP configuration, consider whether those changes would be better off in
`wp-config-local.php`. If they should be permanent, then add them directly to
`/var/www/spiritedmedia.dev/wp-config.php` and also add them to this repo's
`config/wp-config-additions.txt` so they'll be added to new boxes. See #12 for
more information.


## Common Issues

### EasyEngine GPG Keys

During the installation process, you might run into a common error after the log
message `Fixing missing GPG keys, please wait...` and it'll tell you to check
out the error log. It has something to do with a missing GPG key:

```
vagrant@spiritedmedia:~$ sudo tail /var/log/ee/ee.log
Get:7 http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_18.04  Release [1014 B]
Hit:8 http://archive.ubuntu.com/ubuntu bionic-backports InRelease
Hit:9 http://ppa.launchpad.net/ondrej/php/ubuntu bionic InRelease
Get:10 http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_18.04  Release.gpg [481 B]
Ign:10 http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_18.04  Release.gpg
Reading package lists...
W: GPG error: http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_18.04  Release: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 3050AC3CD2AE6F03
E: The repository 'http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_18.04  Release' is not signed.
```

If that happens, try running the script again. Not sure why that works but it
does! Unfortunately, it might take a few tries.

@montchr has tried to find a better way of preventing this from happening but it
seems the GPG key has been removed from all keyservers and any recommended fixes
seem to point to upgrading to EasyEngine 4...

### Test Emails (SES) Not Sending

N.B. As of 2019-03-15 Denverite does not currently have an email set up within
SES. That means test emails cannot be sent (but no error messages will appear
due to the current implementation of the sending process).

First of all, make sure you have the credentials set up properly. If that's not
the problem, you might be seeing an error like this:

```
( ! ) Warning: Sendmail SES Email failed: 0 Error executing "SendEmail" on "https://email.us-east-1.amazonaws.com"; AWS HTTP error: Client error: `POST https://email.us-east-1.amazonaws.com` resulted in a `403 Forbidden` response: <ErrorResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/"> <Error> <Type>Sender</Type> <Code>SignatureDo (truncated...) SignatureDoesNotMatch (client): Signature expired: 20190314T185737Z is now earlier than 20190314T191029Z (20190314T191529Z - 5 min.) - <ErrorResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/"> <Error> <Type>Sender</Type> <Code>SignatureDoesNotMatch</Code> <Message>Signature expired: 20190314T185737Z is now earlier than 20190314T191029Z (20190314T191529Z - 5 min.)</Message> </Error> <RequestId>87b04526-468d-11e9-9dee-b920b0ff31e6</RequestId> </ErrorResponse> in /var/www/spiritedmedia.dev/htdocs/wp-content/plugins/aws-ses-wp-mail/aws-ses-wp-mail.php on line 31
Call Stack
#    Time    Memory    Function    Location
1    0.0020    369456    {main}( )    .../user-new.php:0
2    1.0361    8265480    wpmu_activate_signup( string(16) )    .../user-new.php:162
3    1.0368    8268456    wpmu_create_user( string(11), string(12), string(14) )    .../ms-functions.php:1063
4    1.4326    8445344    do_action( string(13), long )    .../ms-functions.php:1154
5    1.4326    8445720    WP_Hook->do_action( array(1) )    .../plugin.php:453
6    1.4326    8445720    WP_Hook->apply_filters( string(0), array(1) )    .../class-wp-hook.php:310
7    1.4326    8446848    newuser_notify_siteadmin( long )    .../class-wp-hook.php:286
8    1.4343    8513488    wp_mail( string(21), string(34), string(139), ???, ??? )    .../ms-functions.php:1338
9    1.6248    9023984    trigger_error ( string(840), long )    .../aws-ses-wp-mail.php:31
```

With the key message being:

> Signature expired: 20190314T185737Z is now earlier than 20190314T191029Z
> (20190314T191529Z - 5 min.)

To fix this issue: `cd utilities && ./reset-clock.sh`

This happens sometimes when the system clock gets out of sync.

See the Slack archives for more background:

https://spiritedmedia.slack.com/archives/G4KSJLJ67/p1552590978003200
https://spiritedmedia.slack.com/archives/C02KP1SEA/p1480440231001636


## Credits

- [EasyEngine.io](https://easyengine.io/)

Props to the following repos that I borrowed stuff from:

- [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV/)
- [EasyEngine Vagrant](https://github.com/EasyEngine/easyengine-vagrant)
