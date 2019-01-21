# nodes_chef.tf


# ssh-keygen -f chefpracnew-validator.pub -i -mPKCS8 > testvalid

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}
variable "name_nodes" {}
variable "ssh_key_name" {}
variable "number_of_nodes" {}
variable "chef_server_url" {}

variable "ssh_chef_key_name" {
  type = "string"
  default = "Chef"
}

# resource "digitalocean_ssh_key" "testcariza" {
#    name = "SSH Key Credential"
#    public_key = "${file("testcari.pub")}"
# }

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

# Use existing ssh key stored on Digital Ocea
data "digitalocean_ssh_key" "default" {
  name = "${var.ssh_key_name}"
}

data "digitalocean_ssh_key" "chef" {
  name = "${var.ssh_chef_key_name}"
}

# Create a web server
resource "digitalocean_droplet" "nodes" {
  count    = "${var.number_of_nodes}"
  image    = "ubuntu-18-04-x64"
  name     = "${var.name_nodes}-${count.index}"
  region   = "ams3"
  size     = "s-1vcpu-3gb"
  
  ssh_keys = [
    "${data.digitalocean_ssh_key.default.fingerprint}",
    "${data.digitalocean_ssh_key.chef.fingerprint}"
    #"${digitalocean_ssh_key.testcariza.id}"
  ]
  # user_data = "${var.user_data}"

  provisioner "chef" {
    connection {
      type = "ssh"
      user = "root"
      agent = true
      private_key = "${file("cariza.pem")}"
      timeout = "2m"
    }
    environment     = "_default"
    run_list        = ["recipe[workstation]", "recipe[apache]"]
    node_name       = "web-${count.index}"
    server_url      = ""
    recreate_client = true
    user_name       = "cariza"
    user_key        = "${file("cariza.pem")}"
    ssl_verify_mode = ":verify_none"
  }
}

# resource "digitalocean_loadbalancer" "public" {
#  name = "loadbalancer-1"
#  region = "ams3"

#  forwarding_rule {
#    entry_port = 80
#    entry_protocol = "http"

#    target_port = 80
#    target_protocol = "http"
#  }

#  forwarding_rule {
#    entry_port = 8080
#    entry_protocol = "http"

#    target_port = 8080
#    target_protocol = "http"
#  }

#  healthcheck {
#    port = 22
#    protocol = "tcp"
#  }

#  droplet_ids = ["${digitalocean_droplet.nodes.*.id}"]
#}


output "controller_ip_address" {
    value = "${digitalocean_droplet.nodes.*.ipv4_address}"
}

# Store the digital ocean token as an environment variable called DOTOKEN
# test token by running: $ echo $DOTOKEN

# Run these:
# $ terraform init
# $ terraform plan -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_nodes=3" -var="name_nodes=web" -var="chef_server_url=$CHEFSERVERURL"
    # - Output will end with: Plan: 1 to add, 0 to change, 0 to destroy.
# $ terraform apply -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_nodes=3" -var="name_nodes=web" -var="chef_server_url=$CHEFSERVERURL"

# To destroy:
# $ terraform destroy -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_nodes=3" -var="name_nodes=web" -var="chef_server_url=$CHEFSERVERURL"



# List DO Regions: curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" "https://api.digitalocean.com/v2/regions"


#  cat ~/.ssh/authorized_keys

# Chef practice

# terraform apply -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_nodes=1" -var="name_nodes=chef"

# ssh-keygen -f pub1key.pub -i