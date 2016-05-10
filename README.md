# Spirited Media - Erector Set
This will set-up a local instance of the Spiriated Media multisite.

1. Start with any local operating system such as Mac OS X, Linux, or Windows.
1. Install [VirtualBox 5.0.x](https://www.virtualbox.org/wiki/Downloads)
1. Install [Vagrant 1.8.x](https://www.vagrantup.com/downloads.html)
    * `vagrant` will now be available as a command in your terminal, try it out.
    * ***Note:*** If Vagrant is already installed, use `vagrant -v` to check the version. You may want to consider upgrading if a much older version is in use.
1. Install the [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plugin with `vagrant plugin install vagrant-hostsupdater`
1. Clone the repo `git clone https://github.com/spiritedmedia/erector-set.git`
1. Make install.sh executeable: `chmod +x install.sh`
1. Run it! `./install.sh`
1. Visit [spiritedmedia.dev](http://spiritedmedia.dev)

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