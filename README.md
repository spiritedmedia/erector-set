# Spirited Media - Erector Set
This will set-up a local instance of the Spiriated Media multisite.

## Install Software

1. Start with any local operating system such as Mac OS X, Linux, or Windows.
1. Install [VirtualBox 5.0.x](https://www.virtualbox.org/wiki/Downloads)
1. Install [Vagrant 1.8.x](https://www.vagrantup.com/downloads.html)
    * `vagrant` will now be available as a command in your terminal, try it out.
    * ***Note:*** If Vagrant is already installed, use `vagrant -v` to check the version. You may want to consider upgrading if a much older version is in use.
1. Install [Homebrew](http://brew.sh/)
1. Install [Node.js & NPM](https://changelog.com/install-node-js-with-homebrew-on-os-x/)
2. Install [Bower](https://coolestguidesontheplanet.com/installingbower-on-osx/): `npm install -g bower`
3. Install (Bundler)[http://bundler.io/]: `gem install bundler`
4. Install Composer
5. Install [Grunt](http://gruntjs.com/): `npm install -g grunt-cli`
1. Clone the repo `git clone https://github.com/spiritedmedia/erector-set.git`
1. Make install.sh executeable: `chmod +x install.sh`
1. Run it! `./install.sh`
1. Visit [spiritedmedia.dev](http://spiritedmedia.dev)

Note: You'll need the [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plugin but Vagrant will install it for you automatically.

## Details
- WordPress Admin credentials: `admin`/`admin`
- IP: `192.168.33.10`
- Domain: `spirited:media.dev`
- Dev tools: `spiritedmedia.dev:22222`
- Path inside VM: `/var/www/spiritedmedia.dev`

## Documentation
- [EasyEngine.io](https://easyengine.io/)

Props to the following repos that I borrowed stuff from:

- [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV/)
- [EasyEngine Vagrant](https://github.com/EasyEngine/easyengine-vagrant)