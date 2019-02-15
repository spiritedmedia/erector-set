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

_Note: You'll need the [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plugin but Vagrant will install it for you automatically :)_

```sh
# Install Homebrew if it's not installed already
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Clone the repo and move into it
git clone https://github.com/spiritedmedia/erector-set.git spiritedmedia.dev && cd spiritedmedia.dev

# Install basic host dependencies on your computer
#
# This will take a while.
#
# Or instead of running this command you can open `Brewfile` and install each of
# the listed dependencies manually e.g. `brew install coreutils`
#
# If Vagrant and VirtualBox aren't installed already, they'll be installed now
brew bundle

# Make sure your Vagrant version is at least 2.1.x
vagrant -v
# If it's lower than 2.1.x, then update it
brew cask reinstall vagrant

# Optionally install Sequel Pro for connecting to the database with a GUI
brew cask install sequel-pro

# Install Grunt globally -- every other Node dependency will be installed
# within the project
npm install -g grunt-cli
```

After all that's done, run `./install.sh` to kick off the rest of the process. You will be prompted to enter your system's administrator password. Otherwise, please be patient while things install.


### Connect to the Database

In your working directory:

1. Navigate to the `utilities` directory: `cd utilities/`
2. Get the database credentials: `./get-db-info.sh`
3. Note the `DB_USER`, `DB_PASS` values displayed

<img width="682" alt="db-info-output" src="https://cloud.githubusercontent.com/assets/867430/15404473/b0626ad4-1dcb-11e6-8cbd-a3038663d7df.png">

1. Open [Sequel Pro](http://www.sequelpro.com/)
2. Switch to the SSH tab to show SSH fields
3. Enter the following details

| Name         | Value             |
|--------------|-------------------|
| MySQL Host   |  127.0.0.1        |
| Username     | `DB_USER`         |
| Password     | `DB_PASS`         |
| Database     | spiritedmedia_dev |
| Port         | 3306 (default)    |
| SSH Host     | spiritedmedia.dev |
| SSH User     | ubuntu            |
| SSH Password | ubuntu            |
| SSH Port     | <leave blank>     |

<img width="912" alt="screen shot 2016-05-20 at 12 19 02 pm" src="https://cloud.githubusercontent.com/assets/867430/15434500/217ce97e-1e85-11e6-8acf-6efa3c757b29.png">


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


### wp-config-local.php

If you want to customize values in `wp-config.php` add a file called `wp-config-local.php` in the root of the `public/` directory. This file will get included by `wp-config.php` automagically.

Recommended items to add to your `wp-config-local.php` file:

```
<?php
define( 'WP_DEBUG', true );
if ( WP_DEBUG ) {
    // For analyzing database queries i.e. the Debug Bar plugin
    define( 'SAVEQUERIES', true );

    // Enable debug logging to the /wp-content/debug.log file
    define( 'WP_DEBUG_LOG', true );

    // Disable the 'trash', posts will be deleted immediately
    define( 'EMPTY_TRASH_DAYS', 0 );

    // define( 'PEDESTAL_DEBUG_EMAIL_CSS', true );
}

define( 'WP_ENV', 'development' );

// ActiveCampaign API Credentials
define( 'ACTIVECAMPAIGN_URL', '***' );
define( 'ACTIVECAMPAIGN_API_KEY', '***' );

// AWS API Keys for AWS SES wp_mail() drop-in
define( 'AWS_SES_WP_MAIL_REGION', '***' );
define( 'AWS_SES_WP_MAIL_KEY', '***' );
define( 'AWS_SES_WP_MAIL_SECRET', '***' );

define( 'YOUTUBE_DATA_API_KEY', '***' );
```

For values that are `***` ask a dev for the real credentails.

More constants can be found on the [wp-config.php codex page](https://codex.wordpress.org/Editing_wp-config.php) or https://gist.github.com/MikeNGarrett/e20d77ca8ba4ae62adf5


### SSHing into the box

To SSH directly in to the box you can go to the `spiritedmedia.dev` folder and type `vagrant ssh`.

If you want an SSH config to your `.ssh/config` file then type `vagrant ssh-config`, copy the contents, paste it into your `.ssh/config` file.


### Credentials

Post installation you will need to SSH in to the box and add our Google Service account credentials to `/var/www/spiritedmedia.dev/credentials/google-service-account-credentials.json`. The contents of this file should be stored in our 1Password vault.


## Error Logging

### debug.log

If you defined `WP_DEBUG_LOG` to `true` in your `wp-config-local.php` file you can watch `public/wp-content/debug.log` in something like Console.app.

### Direct Access to WordPress/PHP Error Logs

In the directory you cloned Erector Set into...

1. Navigate to the `utilities` directory: `cd utilities/`
1. Run: `./error-logging.sh` which shows WordPress and PHP error logs

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


## How to Disable Full Page Caching for Local Environments

Full-page caching is enabled for non-logged in visitors on the local environment. This includes (almost) every request that goes through PHP, including images passing through Photon.

If for some reason you need to disable full-page caching across the board, follow these steps:

 - Edit the nginx conf for spiritedmedia.dev: `sudo ee site edit spiritedmedia.dev`
 - Uncomment the line with `include common/php7.conf;` and comment out the line with `include common/redis-php7-modified.conf;` and save
 - That should automatically restart nginx but if not run `sudo ee stack restart --nginx`


## Credits
- [EasyEngine.io](https://easyengine.io/)

Props to the following repos that I borrowed stuff from:

- [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV/)
- [EasyEngine Vagrant](https://github.com/EasyEngine/easyengine-vagrant)
