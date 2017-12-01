# Spirited Media - Erector Set
This will set-up a local instance of the Spirited Media multisite. Assumes you're using a Mac.

## Install Software

### For Running the Virtual Machine
1. Install [VirtualBox 5.1.x](https://www.virtualbox.org/wiki/Downloads)
1. Install [Vagrant 2.0.x](https://www.vagrantup.com/downloads.html)
    * `vagrant` will now be available as a command in your terminal, try it out.
    * ***Note:*** If Vagrant is already installed, use `vagrant -v` to check the version. You may want to consider upgrading if a much older version is in use.

_Note: You'll need the [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plugin but Vagrant will install it for you automatically :)_

### For building the theme

Pre-processing happens on the host machine (aka your computer)

1. Install [Homebrew](http://brew.sh/): `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
`
1. Install [Node.js & NPM](https://changelog.com/install-node-js-with-homebrew-on-os-x/): `brew install node`
1. Install [Yarn](https://yarnpkg.com/lang/en/docs/install/): `brew install yarn`
1. Install [Grunt](http://gruntjs.com/): `npm install -g grunt-cli`
1. Install [Bower](https://coolestguidesontheplanet.com/installingbower-on-osx/): `npm install -g bower`
1. Install [Composer](https://getcomposer.org/): `brew install homebrew/php/composer`

### For directly connecting to the database

1. Download and install [Sequel Pro](http://www.sequelpro.com/)

## Build the box
1. Clone the repo `git clone https://github.com/spiritedmedia/erector-set.git`
1. Run `./install.sh`
1. Wait 5-10 minutes
1. Visit [spiritedmedia.dev](http://spiritedmedia.dev)
1. Login via [spiritedmedia.dev/wp-admin](http://spiritedmedia.dev/wp-admin/)
	- Username: `admin`
	- Password: `admin`
1. Use photon.spiritedmedia.dev for [dynamic image resizing](http://photon.spiritedmedia.dev/upload.wikimedia.org/wikipedia/commons/0/0e/Erector_Set_Ad_1922.JPG?resize=300,60)

## Connect to the Database
In the directory you cloned Erector Set into...

1. Navigate to the `utilities` directory: `cd utilities/`
1. Get the database credentials: `./get-db-info.sh`
1. Note the `DB_USER`, `DB_PASS` values displayed

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

## wp-config-local.php
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

## Credentials
Post installation you will need to SSH in to the box and add our Google Service account credentials to `/var/www/spiritedmedia.dev/credentials/google-service-account-credentials.json`. The contents of this file should be stored in our 1Password vault.

## Error Logging

### debug.log
If you defined `WP_DEBUG_LOG` to `true` in your `wp-config-local.php` file you can watch `public/wp-content/debug.log` in something like Console.app.

### Direct Access to Error Logs
In the directory you cloned Erector Set into...

1. Navigate to the `utilities` directory: `cd utilities/`
1. Run: `./error-logging.sh` which shows WordPress and PHP error logs


## Domains

The multiste is set-up to use subdomains for each site. We map domain names to a site via the [Mercator plugin](https://github.com/humanmade/Mercator)

| Site ID | Mapped Domain                           | Unmapped Domain                                                     |
|---------|-----------------------------------------|---------------------------------------------------------------------|
| 1       | --                                      | [spiritedmedia.dev](http://spiritedmedia.dev)                       |
| 2       | [billypenn.dev](http://billypenn.dev)   | [billypenn.spiritedmedia.dev](http://billypenn.spiritedmedia.dev)   |
| 3       | [theincline.dev](http://theincline.dev) | [theincline.spiritedmedia.dev](http://theincline.spiritedmedia.dev) |

## Details
- IP: `192.168.33.10`
- Domain: `spiritedmedia.dev`
- Dev tools: `spiritedmedia.dev:22222`
- Path inside VM: `/var/www/spiritedmedia.dev`

## Credits
- [EasyEngine.io](https://easyengine.io/)

Props to the following repos that I borrowed stuff from:

- [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV/)
- [EasyEngine Vagrant](https://github.com/EasyEngine/easyengine-vagrant)
