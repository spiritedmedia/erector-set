#! /bin/bash

function command_exists () {
    type "$1" &> /dev/null ;
}

function divider() {
    echo -------------------------------------------------------- ;
    if [ "$1" ]; then
        echo "$1"
    fi
}

php_codesniff() {
  # PHP_CodeSniffer (for running WordPress-Coding-Standards)
  if [[ ! -d "/srv/www/phpcs" ]]; then
    echo -e "\nDownloading PHP_CodeSniffer (phpcs), see https://github.com/squizlabs/PHP_CodeSniffer"
    git clone -b master "https://github.com/squizlabs/PHP_CodeSniffer.git" "/srv/www/phpcs"
  else
    cd /srv/www/phpcs
    if [[ $(git rev-parse --abbrev-ref HEAD) == 'master' ]]; then
      echo -e "\nUpdating PHP_CodeSniffer (phpcs)..."
      git pull --no-edit origin master
    else
      echo -e "\nSkipped updating PHP_CodeSniffer since not on master branch"
    fi
  fi

  # Sniffs WordPress Coding Standards
  if [[ ! -d "/srv/www/phpcs/CodeSniffer/Standards/WordPress" ]]; then
    echo -e "\nDownloading WordPress-Coding-Standards, sniffs for PHP_CodeSniffer, see https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards"
    git clone -b master "https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git" "/srv/www/phpcs/CodeSniffer/Standards/WordPress"
  else
    cd /srv/www/phpcs/CodeSniffer/Standards/WordPress
    if [[ $(git rev-parse --abbrev-ref HEAD) == 'master' ]]; then
      echo -e "\nUpdating PHP_CodeSniffer WordPress Coding Standards..."
      git pull --no-edit origin master
    else
      echo -e "\nSkipped updating PHPCS WordPress Coding Standards since not on master branch"
    fi
  fi

  # Install the standards in PHPCS
  /srv/www/phpcs/scripts/phpcs --config-set installed_paths ./CodeSniffer/Standards/WordPress/
  /srv/www/phpcs/scripts/phpcs --config-set default_standard WordPress-Core
  /srv/www/phpcs/scripts/phpcs -i
}

tools_install() {
  # npm
  #
  # Make sure we have the latest npm version and the update checker module
  npm install -g npm
  npm install -g npm-check-updates

  # Xdebug
  #
  # The version of Xdebug 2.4.0 that is available for our Ubuntu installation
  # is not compatible with PHP 7.0. We instead retrieve the source package and
  # go through the manual installation steps.
  if [[ -f /usr/lib/php/20151012/xdebug.so ]]; then
      echo "Xdebug already installed"
  else
      echo "Installing Xdebug"
      # Download and extract Xdebug.
      curl -L -O --silent https://xdebug.org/files/xdebug-2.4.0.tgz
      tar -xf xdebug-2.4.0.tgz
      cd xdebug-2.4.0
      # Create a build environment for Xdebug based on our PHP configuration.
      phpize
      # Complete configuration of the Xdebug build.
      ./configure -q
      # Build the Xdebug module for use with PHP.
      make -s > /dev/null
      # Install the module.
      cp modules/xdebug.so /usr/lib/php/20151012/xdebug.so
      # Clean up.
      cd ..
      rm -rf xdebug-2.4.0*
      echo "Xdebug installed"
  fi

  # ack-grep
  #
  # Install ack-rep directory from the version hosted at beyondgrep.com as the
  # PPAs for Ubuntu Precise are not available yet.
  if [[ -f /usr/bin/ack ]]; then
    echo "ack-grep already installed"
  else
    echo "Installing ack-grep as ack"
    curl -s http://beyondgrep.com/ack-2.14-single-file > "/usr/bin/ack" && chmod +x "/usr/bin/ack"
  fi

  # COMPOSER
  #
  # Install Composer if it is not yet available.
  if [[ ! -n "$(composer --version --no-ansi | grep 'Composer version')" ]]; then
    echo "Installing Composer..."
    curl -sS "https://getcomposer.org/installer" | php
    chmod +x "composer.phar"
    mv "composer.phar" "/usr/local/bin/composer"
  fi

  if [[ -f /vagrant/provision/github.token ]]; then
    ghtoken=`cat /vagrant/provision/github.token`
    composer config --global github-oauth.github.com $ghtoken
    echo "Your personal GitHub token is set for Composer."
  fi

  # Update both Composer and any global packages. Updates to Composer are direct from
  # the master branch on its GitHub repository.
  if [[ -n "$(composer --version --no-ansi | grep 'Composer version')" ]]; then
    echo "Updating Composer..."
    COMPOSER_HOME=/usr/local/src/composer composer self-update
    COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update phpunit/phpunit:4.8.*
    COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update phpunit/php-invoker:1.1.*
    COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update mockery/mockery:0.9.*
    COMPOSER_HOME=/usr/local/src/composer composer -q global require --no-update d11wtq/boris:v1.0.8
    COMPOSER_HOME=/usr/local/src/composer composer -q global config bin-dir /usr/local/bin
    COMPOSER_HOME=/usr/local/src/composer composer global update
  fi

  # Grunt
  #
  # Install or Update Grunt based on current state.  Updates are direct
  # from NPM
  if [[ "$(grunt --version)" ]]; then
    echo "Updating Grunt CLI"
    npm update -g grunt-cli &>/dev/null
    npm update -g grunt-sass &>/dev/null
    npm update -g grunt-cssjanus &>/dev/null
    npm update -g grunt-rtlcss &>/dev/null
  else
    echo "Installing Grunt CLI"
    npm install -g grunt-cli &>/dev/null
    npm install -g grunt-sass &>/dev/null
    npm install -g grunt-cssjanus &>/dev/null
    npm install -g grunt-rtlcss &>/dev/null
  fi

  # Graphviz
  #
  # Set up a symlink between the Graphviz path defined in the default Webgrind
  # config and actual path.
  echo "Adding graphviz symlink for Webgrind..."
  ln -sf "/usr/bin/dot" "/usr/local/bin/dot"
}

# By storing the date now, we can calculate the duration of provisioning at the
# end of this script.
start_seconds="$(date +%s)"

divider "Starting build-tools.sh script"

### Install Build Tool Dependencies ###
#divider "Installing dependencies for build tools"
# Install the official PPA for Node
# curl -sL https://deb.nodesource.com/setup | sudo bash -
# sudo apt-get --yes install nodejs
#  For some npm packages to work (such as those that require building from source), you will need to install the build-essentials package
# sudo apt-get --yes install build-essential
# Install Composer
# curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
# Install PHPCS
# sudo apt-get --yes install php-codesniffer
# Install WordPress coding standards
# sudo yes | sudo composer create-project wp-coding-standards/wpcs:dev-master --no-dev
# Install RVM (Ruby Version Manager) ???
# sudo apt-add-repository -y ppa:rael-gc/rvm
# sudo apt-get update
# sudo apt-get install rvm

### Build Dependencies ###
#divider "Building Pedestal"
# cd /var/www/spiritedmedia.dev/htdos/wp-content/themes/pedestal/
# sudo npm install -g node-sass
# sudo npm install -g grunt-cli
# sudo npm install
# sudo grunt build
# composer update -o

tools_install
php_codesniff

# And it's done
end_seconds="$(date +%s)"
echo "-----------------------------"
echo "Provisioning complete in "$((${end_seconds} - ${start_seconds}))" seconds"
