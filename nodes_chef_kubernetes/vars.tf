# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}
# variable "name_nodes" {}
variable "ssh_key_name" {}
variable "number_of_leaders" {}

variable "number_of_minions" {}
variable "chef_server_url" {}

variable "ssh_chef_key_name" {
  type = "string"
  default = "Chef"
}

# variable "chef_server_username" {}