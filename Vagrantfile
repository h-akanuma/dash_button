# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"

  config.vm.network :public_network, bridge: "en0: Wi-Fi (AirPort)"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.provision :shell, path: "provisionings/libs.sh"
  config.vm.provision :shell, path: "provisionings/rbenv.sh"
  config.vm.provision :shell, path: "provisionings/ruby2.3.1.sh"
  config.vm.provision :shell, path: "provisionings/env.sh"
  config.vm.provision :shell, path: "provisionings/gems.sh"
end
