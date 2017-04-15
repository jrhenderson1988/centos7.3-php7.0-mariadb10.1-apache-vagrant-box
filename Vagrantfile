# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "bento/centos-7.3"
    config.vm.box_check_update = false
    config.vm.network "private_network", ip: "192.168.33.10"
    config.vm.network :forwarded_port, guest: 80, host: 8080
    config.vm.network :forwarded_port, guest: 443, host: 8282
    config.vm.provision :shell, :path => "install.sh"
    config.vm.hostname = "project.dev"
    config.vm.synced_folder ".", "/home", id: "vagrant", :nfs => false, :mount_options => ["dmode=777","fmode=777"]
    config.ssh.insert_key = false
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"

    config.vm.provider 'virtualbox' do |vb|
      vb.memory = "2048"
      vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
      vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
    end
end
