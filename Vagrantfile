# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.hostname = "vpnbox"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "384"
  end

  config.vm.network "private_network", ip: "192.168.213.200"

  # prevent compromised vm overwriting vagrant files...
  config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__exclude: [ ".git", "shared" ]

  config.vm.provision "shell", path: "provision/scripts/provision.sh"
end
