# main.tf

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}
variable "name_nodes" {}
variable "ssh_key_name" {}
variable "number_of_nodes" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

# Use existing ssh key stored on Digital Ocea
data "digitalocean_ssh_key" "default" {
  name = "${var.ssh_key_name}"
}

# Create a web server
resource "digitalocean_droplet" "nodes" {
  count    = "${var.number_of_nodes}"
  image    = "ubuntu-18-04-x64"
  name     = "${var.name_nodes}-${count.index}"
  region   = "ams3"
  size     = "s-1vcpu-3gb"
  
  ssh_keys = [
    "${data.digitalocean_ssh_key.default.fingerprint}"
  ]

}

output "controller_ip_address" {
    value = "${digitalocean_droplet.nodes.*.ipv4_address}"
}

# Store the digital ocean token as an environment variable called DOTOKEN
# test token by running: $ echo $DOTOKEN

# Run these:
# $ terraform init
# $ terraform plan -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_nodes=3" -var="name_nodes=web"
    # - Output will end with: Plan: 1 to add, 0 to change, 0 to destroy.
# $ terraform apply -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_nodes=3" -var="name_nodes=web"

# To destroy:
# $ terraform destroy -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_nodes=3" -var="name_nodes=web"



# List DO Regions: curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" "https://api.digitalocean.com/v2/regions"


#  cat ~/.ssh/authorized_keys

# Chef practice

# terraform apply -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_nodes=1" -var="name_nodes=chef"

# ssh-keygen -f pub1key.pub -i