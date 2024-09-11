# -*- mode: ruby -*-
# vi: set ft=ruby :
MACHINES = {
  :"pam" => {
              :box_name => "ubuntu-22.04",
              :cpus => 2,
              :memory => 1024,
              :ip => "192.168.56.110",
            }
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.network "private_network", ip: boxconfig[:ip]
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.box_version = boxconfig[:box_version]
      box.vm.host_name = boxname.to_s

      box.vm.provider "virtualbox" do |v|
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
      end
      box.vm.provision "shell", inline: <<-SHELL
          systemctl restart sshd.service
          timedatectl set-local-rtc 0
          sudo timedatectl set-ntp 1
          sudo hwclock --systohc
          sudo timedatectl set-ntp 0
          SHELL
      box.vm.provision "shell", path: "./adduser.sh"
      box.vm.provision "shell", path: "./change-config.sh"
      box.vm.provision "file", source: "./prov", destination: "/tmp/prov"
      box.vm.provision "shell",inline: "sudo -s"
      box.vm.provision "shell",inline: "cp /tmp/prov/is-admin.sh /usr/local/bin/is-admin.sh"
      box.vm.provision "shell",inline: "chmod +x /usr/local/bin/is-admin.sh"
      box.vm.provision "shell",inline: "/usr/local/bin/is-admin.sh"
      box.vm.provision "shell",inline: "sudo systemctl restart sshd.service"
    end
  end
end

