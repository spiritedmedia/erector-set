# -*- mode: ruby -*-
# vi: set ft=ruby :

# Make sure Vagrant plugins are installed
# via http://matthewcooper.net/2015/01/15/automatically-installing-vagrant-plugin-dependencies/
required_plugins = %w( vagrant-hostsupdater )
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

# Store the vagrant directory as a variable
vagrant_dir = File.expand_path(File.dirname(__FILE__))

Vagrant.configure("2") do |config|

    # Store the current version of Vagrant for use in conditionals when dealing
    # with possible backward compatible issues.
    vagrant_version = Vagrant::VERSION.sub(/^v/, '')

    # Configurations from 1.0.x can be placed in Vagrant 1.1.x specs like the following.
    config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--cpus", 1]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    # Set the box name in VirtualBox to match the working directory.
    vvv_pwd = Dir.pwd
    v.name = File.basename(vvv_pwd)
    end

    # Configuration options for the Parallels provider.
    config.vm.provider :parallels do |v|
    v.update_guest_tools = true
    v.customize ["set", :id, "--longer-battery-life", "off"]
    v.memory = 1024
    v.cpus = 1
    end

    # Configuration options for the VMware Fusion provider.
    config.vm.provider :vmware_fusion do |v|
    v.vmx["memsize"] = "1024"
    v.vmx["numvcpus"] = "1"
    end

    # Configuration options for Hyper-V provider.
    config.vm.provider :hyperv do |v, override|
    v.memory = 1024
    v.cpus = 1
    end

    # SSH Agent Forwarding
    #
    # Enable agent forwarding on vagrant ssh commands. This allows you to use ssh keys
    # on your host machine inside the guest. See the manual for `ssh-add`.
    config.ssh.forward_agent = true

    # Default Ubuntu Box
    #
    # This box is provided by Ubuntu vagrantcloud.com and is a nicely sized (332MB)
    # box containing the Ubuntu 14.04 Trusty 64 bit release. Once this box is downloaded
    # to your host computer, it is cached for future use under the specified box name.
    config.vm.box = "ubuntu/trusty64"

    # The Parallels Provider uses a different naming scheme.
    config.vm.provider :parallels do |v, override|
    override.vm.box = "parallels/ubuntu-14.04"
    end

    # The VMware Fusion Provider uses a different naming scheme.
    config.vm.provider :vmware_fusion do |v, override|
    override.vm.box = "netsensia/ubuntu-trusty64"
    end

    # VMWare Workstation can use the same package as Fusion
    config.vm.provider :vmware_workstation do |v, override|
    override.vm.box = "netsensia/ubuntu-trusty64"
    end

    # Hyper-V uses a different base box.
    config.vm.provider :hyperv do |v, override|
    override.vm.box = "ericmann/trusty64"
    end

    # Local Machine Hosts
  #
  # If the Vagrant plugin hostsupdater (https://github.com/cogitatio/vagrant-hostsupdater) is
  # installed, the following will automatically configure your local machine's hosts file to
  # be aware of the domains specified below. Watch the provisioning script as you may need to
  # enter a password for Vagrant to access your hosts file.
  #
  # By default, we'll include the domains set up by VVV through the vvv-hosts file
  # located in the www/ directory.
  #
  # Other domains can be automatically added by including a vvv-hosts file containing
  # individual domains separated by whitespace in subdirectories of www/.
  if defined?(VagrantPlugins::HostsUpdater)
    # Recursively fetch the paths to all vvv-hosts files under the www/ directory.
    paths = Dir[File.join(vagrant_dir, 'config', '**', 'hosts')]

    # Parse the found vvv-hosts files for host names.
    hosts = paths.map do |path|
      # Read line from file and remove line breaks
      lines = File.readlines(path).map(&:chomp)
      # Filter out comments starting with "#"
      lines.grep(/\A[^#]/)
    end.flatten.uniq # Remove duplicate entries

    # Pass the found host names to the hostsupdater plugin so it can perform magic.
    config.hostsupdater.aliases = hosts
    config.hostsupdater.remove_on_suspend = true
  end

  # Private Network (default)
  #
  # A private network is created by default. This is the IP address through which your
  # host machine will communicate to the guest. In this default configuration, the virtual
  # machine will have an IP address of 192.168.50.4 and a virtual network adapter will be
  # created on your host machine with the IP of 192.168.50.1 as a gateway.
  #
  # Access to the guest machine is only available to your local host. To provide access to
  # other devices, a public network should be configured or port forwarding enabled.
  #
  # Note: If your existing network is using the 192.168.50.x subnet, this default IP address
  # should be changed. If more than one VM is running through VirtualBox, including other
  # Vagrant machines, different subnets should be used for each.
  #
  config.vm.network :private_network, id: "vvv_primary", ip: "192.168.33.10"

  config.vm.provider :hyperv do |v, override|
    override.vm.network :private_network, id: "vvv_primary", ip: nil
  end

    config.vm.hostname = "spiritedmedia.dev"
    # Copy the easyengine conf file to the VM
    # config.vm.provision "file", source: "config/ee.conf", destination: "~/ee.conf"
    config.vm.provision "shell", path: "config/easyengine.sh"
    # config.vm.synced_folder "logs/", "/var/log/easyengine", owner: "root", group: "root"

    #
    # /srv/www/
      #
      # If a www directory exists in the same directory as your Vagrantfile, a mapped directory
      # inside the VM will be created that acts as the default location for nginx sites. Put all
      # of your project files here that you want to access through the web server
      if vagrant_version >= "1.3.0"
        config.vm.synced_folder "public/", "/var/www/spiritedmedia.dev/htdocs", :owner => "www-data", :group => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]
      else
        config.vm.synced_folder "public/", "/var/www/spiritedmedia.dev/htdocs", :owner => "www-data", :group => "www-data", :extra => 'dmode=775,fmode=774'
      end

      config.vm.provision "fix-no-tty", type: "shell" do |s|
        s.privileged = false
        s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
      end

      # The Parallels Provider does not understand "dmode"/"fmode" in the "mount_options" as
      # those are specific to Virtualbox. The folder is therefore overridden with one that
      # uses corresponding Parallels mount options.
      config.vm.provider :parallels do |v, override|
        override.vm.synced_folder "public/", "/var/www/spiritedmedia.dev/htdocs", :owner => "www-data", :group => "www-data", :mount_options => []
      end

      # The Hyper-V Provider does not understand "dmode"/"fmode" in the "mount_options" as
      # those are specific to Virtualbox. Furthermore, the normal shared folders need to be
      # replaced with SMB shares. Here we switch all the shared folders to us SMB and then
      # override the www folder with options that make it Hyper-V compatible.
      config.vm.provider :hyperv do |v, override|
        override.vm.synced_folder "public/", "/var/www/spiritedmedia.dev/htdocs", :owner => "www-data", :group => "www-data", :mount_options => ["dir_mode=0775","file_mode=0774","forceuid","noperm","nobrl","mfsymlinks"]
        # Change all the folder to use SMB instead of Virtual Box shares
        override.vm.synced_folders.each do |id, options|
          if ! options[:type]
            options[:type] = "smb"
          end
        end
      end

    # Always start MySQL on boot, even when not running the full provisioner
    # (run: "always" support added in 1.6.0)
    if vagrant_version >= "1.6.0"
    ## config.vm.provision :shell, inline: "sudo ee stack reload", run: "always"
    end

    # Vagrant Triggers
    #
    # If the vagrant-triggers plugin is installed, we can run various scripts on Vagrant
    # state changes like `vagrant up`, `vagrant halt`, `vagrant suspend`, and `vagrant destroy`
    #
    # These scripts are run on the host machine, so we use `vagrant ssh` to tunnel back
    # into the VM and execute things. By default, each of these scripts calls db_backup
    # to create backups of all current databases. This can be overridden with custom
    # scripting. See the individual files in config/homebin/ for details.
    # if defined? VagrantPlugins::Triggers
    #  config.trigger.after :up, :stdout => true do
    #    run "vagrant ssh -c 'vagrant_up'"
    #  end
    #  config.trigger.before :reload, :stdout => true do
    #    run "vagrant ssh -c 'vagrant_halt'"
    #  end
    #  config.trigger.after :reload, :stdout => true do
    #    run "vagrant ssh -c 'vagrant_up'"
    #  end
    #  config.trigger.before :halt, :stdout => true do
    #    run "vagrant ssh -c 'vagrant_halt'"
    #  end
    #  config.trigger.before :suspend, :stdout => true do
    #    run "vagrant ssh -c 'vagrant_suspend'"
    #  end
    #  config.trigger.before :destroy, :stdout => true do
    #    run "vagrant ssh -c 'vagrant_destroy'"
    #  end
#    end
    end
