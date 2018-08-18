# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "puppet" do |puppet|
    puppet.vm.box = "bento/centos-7.2"
    puppet.vbguest.auto_update = false
    puppet.vm.network "private_network", ip: "192.168.10.21"
    puppet.vm.hostname = "puppet-test"
    puppet.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "4096"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
    end
    puppet.vm.provision "file", source: "./site.pp", destination: "/vagrant/site.pp"
    puppet.vm.provision "file", source: "./puppet.conf", destination: "/vagrant/puppet.conf"
    puppet.vm.provision "file", source: "./init.pp", destination: "/vagrant/init.pp"
    puppet.vm.provision "shell", inline: <<-SHELL
      sudo echo "192.168.10.22 puppetagent-1" | sudo tee -a /etc/hosts
      sudo echo "192.168.10.24 puppetagentwin" | sudo tee -a /etc/hosts
      sudo systemctl enable firewalld
      sudo systemctl start firewalld
      sudo firewall-cmd --permanent --zone=public --add-port=8140/tcp 
      sudo yum -y install ntp
      sudo timedatectl set-timezone America/New_York
      sudo systemctl start ntpd
      sudo firewall-cmd --add-service=ntp --permanent
      sudo rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
      sudo yum -y install puppetserver
      sudo touch /etc/puppetlabs/puppet/autosign.conf
      sudo echo "*" | sudo tee -a /etc/puppetlabs/puppet/autosign.conf
      sudo firewall-cmd --reload
      sudo systemctl enable puppetserver
      sudo cp /vagrant/site.pp /etc/puppetlabs/code/environments/production/manifests
      sudo cp /vagrant/puppet.conf /etc/puppetlabs/puppet
      sudo systemctl start puppetserver    
      sudo /opt/puppetlabs/bin/puppet module install chocolatey-chocolatey_server  
      sudo /opt/puppetlabs/bin/puppet module install puppet-windows_firewall --version 2.0.0    
      sudo /opt/puppetlabs/bin/puppet module install puppetlabs-dsc_lite 
      sudo /opt/puppetlabs/bin/puppet module install chocolatey-chocolatey
      cd /etc/puppetlabs/code/environments/production/modules
      sudo /opt/puppetlabs/bin/puppet module generate --skip-interview my-chocoserver
      sudo cp /vagrant/init.pp /etc/puppetlabs/code/environments/production/modules/chocoserver/manifests 
    SHELL
end

  config.vm.define "puppetagent-1" do |puppetagent1|
    puppetagent1.vm.box = "bento/centos-7.2"
    puppetagent1.vbguest.auto_update = false
    puppetagent1.vm.network "private_network", ip: "192.168.10.22"
    puppetagent1.vm.hostname = "puppetagent-1"
    puppetagent1.vm.provision "shell", inline: <<-SHELL
       sudo echo "192.168.10.21 puppet-test" | sudo tee -a /etc/hosts
       sudo timedatectl set-timezone America/New_York
       sudo rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
       sudo yum -y install puppet-agent
    SHELL
    puppetagent1.vm.provision "puppet_server" do |puppetagentnode|
      puppetagentnode.puppet_node = "puppetagent-1"
      puppetagentnode.puppet_server = "puppet-test"
      puppetagentnode.options = "--verbose --waitforcert 10"
    end
    end
     config.vm.define "puppetagentwin" do |puppetagentwin|
     puppetagentwin.vm.box = "eratiner/w2016x64vmX"
      puppetagentwin.vm.network "private_network", ip: "192.168.10.24"
      puppetagentwin.vm.network "forwarded_port", guest: 3389, host: 33399
      puppetagentwin.vm.hostname = "puppetagentwin"
      puppetagentwin.vm.provision "shell", inline: <<-SHELL
       Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
       Set-TimeZone 'Eastern Standard Time' 
       choco install puppet-agent -y -installArgs '"PUPPET_AGENT_STARTUP_MODE=Disabled" "PUPPET_MASTER_SERVER=puppet-test"'
       Add-Content -Value '192.168.10.21 puppet-test' -Path 'C:\\windows\\System32\\drivers\\etc\\hosts'
        Set-ItemProperty -Path "HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server" -Name "fDenyTSConnections" -Value 0
       Netsh advfirewall firewall set rule group='remote desktop' new enable=yes
       refreshenv
       SHELL
       puppetagentwin.vm.provision "shell", inline: <<-SHELL
      # puppet agent --verbose --waitforcert 10 --certname puppetagent-win
       SHELL
 
 end

end


