# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Load sensitive AWS credentials from external file
if File.exist?("config/aws.yml")
  aws_config  = YAML.load_file("config/aws.yml")["aws"]
end

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.define "instance-0", primary: true

  (1..9).each do |i|
    config.vm.define "instance-#{i}", autostart: false
  end

  config.vm.provider "virtualbox" do |vb, override|
    vb.cpus = 2
    vb.memory = 4096
    override.vm.synced_folder "./data", "/vagrant_data"
  end

  config.vm.provider "aws" do |aws, override|
    override.vm.box           = "dummy"
    override.vm.box_url       = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    aws.access_key_id         = aws_config["access_key_id"]
    aws.secret_access_key     = aws_config["secret_access_key"]
    aws.security_groups       = aws_config["security_groups"]
    aws.region                = aws_config["region"]
    aws.ami                   = aws_config["ami"]
    aws.keypair_name          = aws_config["keypair_name"]
    aws.instance_type         = aws_config["instance_type"]
    aws.terminate_on_shutdown = true

    override.ssh.username     = "ubuntu"
    override.ssh.private_key_path = aws_config["pemfile"]
    override.vm.synced_folder ".", "/vagrant", disabled: true
  end

  config.vm.provision "shell", path: "bootstrap.sh"
end
