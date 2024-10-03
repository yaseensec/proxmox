terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.11"
    }
  }
}

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
}

provider "proxmox" {
    pm_api_url = var.proxmox_api_url
    pm_api_token_id = var.proxmox_api_token_id
    pm_api_token_secret = var.proxmox_api_token_secret
    # (Optional) Skip TLS Verification
    # pm_tls_insecure = true
}

module Masters{
  source = "./master"
  no_of_vm = 2
  vm_name = "Ubuntu-Master"
  vm_id = "10" 
  target_node = "darkrose" 
  clone_template = "ubuntu-server-jammy"
  cpu_cores = "1"
  cpu_sockets = "1"
  ram = "1024"
  ipaddr = "192.168.0.10"
  cidr = "24"
  gateway = "192.168.0.1"
  dnsserver = "192.168.0.1"
  user = "yaseen"
  password = "1234"
  sshkey = <<EOF
     ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0Mrz/2CXLoD3i5oHsLCEdVQrfGzKUDAgJumLLUKmnx yaseen@Entropy
    EOF
}

module Nodes{
  source = "./node"
  no_of_vm = 3
  vm_name = "Ubuntu-Node"
  vm_id = "11" 
  target_node = "darkrose" 
  clone_template = "ubuntu-server-jammy"
  cpu_cores = "1"
  cpu_sockets = "1"
  ram = "3096"
  ipaddr = "192.168.0.11"
  cidr = "24"
  gateway = "192.168.0.1"
  dnsserver = "192.168.0.1"
   user = "yaseen"
   password = "1234"
   sshkey = <<EOF
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0Mrz/2CXLoD3i5oHsLCEdVQrfGzKUDAgJumLLUKmnx yaseen@Entropy
     EOF
}
