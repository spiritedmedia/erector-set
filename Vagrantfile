# Make sure Vagrant plugins are installed
#
# via http://matthewcooper.net/2015/01/15/automatically-installing-vagrant-plugin-dependencies/
#
# Vagrant Host Manager updates the host file on the host machine so fancy
# hostnames work automagically
required_plugins = %w[vagrant-hostmanager]
required_plugins.each do |plugin|
  if !((Vagrant.has_plugin? plugin) || ARGV[0] == 'plugin')
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(' ')}"
  end
end

vagrant_dir = File.expand_path(__dir__)

Vagrant.configure('2') do |config|
  # Configurations from 1.0.x can be placed in Vagrant 1.1.x specs like the
  # following.
  config.vm.provider :virtualbox do |v|
    v.customize ['modifyvm', :id, '--memory', 1024]
    v.customize ['modifyvm', :id, '--cpus', 1]
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']

    # Set the box name in VirtualBox to match the working directory.
    v.name = File.basename(Dir.pwd)
  end

  # SSH Agent Forwarding
  #
  # Enable agent forwarding on vagrant ssh commands. This allows you to use ssh
  # keys on your host machine inside the guest. See the manual for `ssh-add`.
  config.ssh.forward_agent = true

  # Default Ubuntu Box
  #
  # Box containing the Ubuntu 18.04.1 Bionic Beaver 64 bit LTS release.
  #
  # Once this box is downloaded to your host computer, it is cached for future
  # use under the specified box name.
  config.vm.box = 'ubuntu/bionic64'

  # Set a nice name for the box
  config.vm.define 'spiritedmedia'

  # Private Network (default)
  #
  # A private network is created by default. This is the IP address through
  # which your host machine will communicate to the guest. In this default
  # configuration, the virtual machine will have an IP address of 192.168.33.10
  # and a virtual network adapter will be created on your host machine
  #
  # Access to the guest machine is only available to your local host. To provide
  # access to other devices, a public network should be configured or port
  # forwarding enabled.
  #
  # Note: If your existing network is using the 192.168.33.x subnet, this
  # default IP address should be changed. If more than one VM is running through
  # VirtualBox, including other Vagrant machines, different subnets should be
  # used for each.
  #
  config.vm.network :private_network, id: 'vvv_primary', ip: '192.168.33.10'

  config.vm.provider :hyperv do |_v, override|
    override.vm.network :private_network, id: 'vvv_primary', ip: nil
  end

  config.vm.hostname = 'spiritedmedia.dev'

  # Recursively fetch the paths to all hosts files
  paths = Dir[File.join(vagrant_dir, 'config', '**', 'hosts')]
  # Parse the found hosts files for host names
  hosts = paths.map do |path|
    # Read line from file and remove line breaks
    lines = File.readlines(path).map(&:chomp)
    # Filter out comments starting with '#'
    lines.grep(/\A[^#]/)
  end.flatten.uniq # Remove duplicate entries

  if Vagrant.has_plugin? 'vagrant-hostmanager'
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.aliases = hosts
  else
    fail_with_message
    <<-HEREDOC
"vagrant-hostmanager missing, please install the plugin with this command:\nvagrant plugin install vagrant-hostmanager"
    HEREDOC
  end

  # Sync some files and directories with the VM
  #
  # Note that if these are deleted on the VM, they'll be deleted on the host too!
  config.vm.synced_folder 'config/nginx-configs', '/home/ubuntu/nginx-configs'
  config.vm.synced_folder 'config/php-configs', '/home/ubuntu/php-configs'
  config.vm.synced_folder 'ssl', '/home/ubuntu/ssl'
  config.vm.synced_folder 'public/',
                          '/var/www/spiritedmedia.dev/htdocs',
                          owner: 'www-data',
                          group: 'www-data',
                          mount_options: ['dmode=777', 'fmode=777']
  # @TODO Get logs working
  # config.vm.synced_folder 'logs/', '/var/log/', owner: 'root', group: 'root'
  # # rubocop:disable LineLength
  # config.vm.synced_folder 'logs/', '/var/www/spiritedmedia.dev/logs', :owner => 'www-data', :group => 'www-data', :mount_options => [ 'dmode=775','fmode=774' ]
  # rubocop:enable LineLength

  # Set up shell utility functions
  config.vm.provision 'file',
                      source: 'utilities/shell-utils.sh',
                      destination: 'shell-utils.sh'

  # Run provisioning script
  config.vm.provision 'shell', path: 'provision/provision.sh'

  config.vm.provision 'fix-no-tty', type: 'shell' do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile" # rubocop:disable LineLength
  end
end
