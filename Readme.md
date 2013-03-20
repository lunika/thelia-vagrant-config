README
======

thelia-vagrant-config
---------------------

Vagrant base config for installing and testing current Thelia CMS development (aka thelia 2)

This config is in beta and maybe can have some issues

Installation
------------

Install Vagrant and virtualbox : http://docs-v1.vagrantup.com/v1/docs/getting-started/index.html

download vagrant ssh key :
``` bash
$ wget https://raw.github.com/mitchellh/vagrant/master/keys/vagrant -O ~/.ssh/insecure_private_key
$ chmod 600 ~/.ssh/insecure_private_key
```

if you don't want to use the private key, comment this lines :

```
  config.ssh.private_key_path = "~/.ssh/insecure_private_key"
  config.ssh.max_tries = 10
```

then :
``` bash
$ git clone --recursive https://github.com/lunika/thelia-vagrant-config.git
$ cd thelia-vagrant-config
$ vagrant up
```
wait while vagrant box is intalling and finish the installation process at the mysql point (https://github.com/thelia/thelia/blob/master/Readme.md).
