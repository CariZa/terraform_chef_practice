# nodes_chef.tf

# /etc/apt/apt.conf.d
#
# needs to be here:
# /etc/apt/sources.list.d/kubernetes.list

# ssh-keygen -f chefpracnew-validator.pub -i -mPKCS8 > testvalid



# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

# Use existing ssh key stored on Digital Ocean
data "digitalocean_ssh_key" "default" {
  name = "${var.ssh_key_name}"
}

data "digitalocean_ssh_key" "chef" {
  name = "${var.ssh_chef_key_name}"
}

# Create a web server

### Masters
resource "digitalocean_droplet" "leaders" {
  count    = "${var.number_of_leaders}"
  image    = "ubuntu-18-04-x64"
  name     = "leader-${count.index}"
  region   = "ams3"
  size     = "s-2vcpu-2gb"
  
  ssh_keys = [
    "${data.digitalocean_ssh_key.default.fingerprint}",
    "${data.digitalocean_ssh_key.chef.fingerprint}"
  ]

  provisioner "chef" {
    connection {
      type = "ssh"
      user = "root"
      agent = true
      private_key = "${file("cariza.pem")}"
      timeout = "2m"
    }
    environment     = "_default"
    # run_list        = []
    run_list        = ["recipe[kubernetes_setup]","recipe[kubernetes_cni]", "recipe[kubernetes_leader]"]
    node_name       = "leader-${count.index}"
    server_url      = "${var.chef_server_url}"
    recreate_client = true
    user_name       = "cariza"
    user_key        = "${file("cariza.pem")}"
    ssl_verify_mode = ":verify_none"
  }

  # provisioner "chef" {
  #   connection {
  #     type = "ssh"
  #     user = "root"
  #     agent = true
  #     private_key = "${file("cariza.pem")}"
  #     timeout = "2m"
  #   }
  #   environment     = "_default"
  #   # run_list        = []
  #   run_list        = ["recipe[kubernetes_cni]"]
  #   node_name       = "leader-${count.index}"
  #   server_url      = "${var.chef_server_url}"
  #   recreate_client = true
  #   user_name       = "cariza"
  #   user_key        = "${file("cariza.pem")}"
  #   ssl_verify_mode = ":verify_none"
  # }

  # provisioner "chef" {
  #   connection {
  #     type = "ssh"
  #     user = "root"
  #     agent = true
  #     private_key = "${file("cariza.pem")}"
  #     timeout = "2m"
  #   }
  #   environment     = "_default"
  #   # run_list        = []
  #   run_list        = ["recipe[kubernetes_leader]"]
  #   node_name       = "leader-${count.index}"
  #   server_url      = "${var.chef_server_url}"
  #   recreate_client = true
  #   user_name       = "cariza"
  #   user_key        = "${file("cariza.pem")}"
  #   ssl_verify_mode = ":verify_none"
  # }
}

### Minions
resource "digitalocean_droplet" "minions" {

  depends_on = ["digitalocean_droplet.leaders"]

  count    = "${var.number_of_minions}"
  image    = "ubuntu-18-04-x64"
  name     = "minion-${count.index}"
  region   = "ams3"
  size     = "s-1vcpu-1gb"
  
  ssh_keys = [
    "${data.digitalocean_ssh_key.default.fingerprint}",
    "${data.digitalocean_ssh_key.chef.fingerprint}"
  ]

  provisioner "chef" {
    connection {
      type = "ssh"
      user = "root"
      agent = true
      private_key = "${file("cariza.pem")}"
      timeout = "2m"
    }
    environment     = "_default"
    run_list        = ["recipe[kubernetes_setup]","recipe[kubernetes_minion]"] # "recipe[kubernetes_minion]", <- this wont work without the kubeadm join command
    # run_list        = []
    node_name       = "minion-${count.index}"
    server_url      = "${var.chef_server_url}"
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


output "controller_ip_address_leaders" {
    value = "${digitalocean_droplet.leaders.*.ipv4_address}"
}

output "controller_ip_address_minions" {
    value = "${digitalocean_droplet.minions.*.ipv4_address}"
}

# Store the digital ocean token as an environment variable called DOTOKEN
# test token by running: $ echo $DOTOKEN

# Run these:
# $ terraform init
# $ terraform plan -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_leaders=1" -var="number_of_minions=2" -var="chef_server_url=$CHEFSERVERURL"
    # - Output will end with: Plan: 1 to add, 0 to change, 0 to destroy.
# $ terraform apply -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_leaders=1" -var="number_of_minions=2" -var="chef_server_url=$CHEFSERVERURL"

# To destroy:
# $ terraform destroy -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_leaders=1" -var="number_of_minions=2" -var="chef_server_url=$CHEFSERVERURL"



# List DO Regions: curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" "https://api.digitalocean.com/v2/regions"


#  cat ~/.ssh/authorized_keys

# Chef practice

# terraform apply -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_nodes=1" -var="name_nodes=chef"

# ssh-keygen -f pub1key.pub -i


# $ terraform apply -var="do_token=$DOTOKEN" -var="ssh_key_name=$SSHKEYNAME" -var="ssh_key_name=$SSHKEYNAME" -var="number_of_leaders=1" -var="number_of_minions=0" -var="chef_server_url=$CHEFSERVERURL"