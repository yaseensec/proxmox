terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc4"
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
    pm_tls_insecure = true
}

module Controllers{
  source = "./VM-Template"
  no_of_vm = 3
  vm_name = "K8s-Controller"
  vm_id = "11" 
  target_node = "proxmox" 
  clone_template = "RHEL9-Template"
  cpu_cores = "1"
  cpu_sockets = "1"
  ram = "1024"
  ipaddr = "192.168.29.11"
  cidr = "24"
  gateway = "192.168.29.1"
  dnsserver = "192.168.29.1"
  user = "darkrose"
  password = "1234"
  sshkey = <<EOF
     ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0Mrz/2CXLoD3i5oHsLCEdVQrfGzKUDAgJumLLUKmnx darkrose@proxmox
    EOF
}

module ETCD{
  source = "./VM-Template"
  no_of_vm = 3
  vm_name = "K8s-ETCD"
  vm_id = "12" 
  target_node = "proxmox" 
  clone_template = "RHEL9-Template"
  cpu_cores = "1"
  cpu_sockets = "1"
  ram = "1024"
  ipaddr = "192.168.29.12"
  cidr = "24"
  gateway = "192.168.29.1"
  dnsserver = "192.168.29.1"
  user = "darkrose"
  password = "1234"
  sshkey = <<EOF
     ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0Mrz/2CXLoD3i5oHsLCEdVQrfGzKUDAgJumLLUKmnx darkrose@proxmox
    EOF
}

module Nodes{
  source = "./VM-Template"
  no_of_vm = 3
  vm_name = "K8s-Node"
  vm_id = "13" 
  target_node = "proxmox" 
  clone_template = "RHEL9-Template"
  cpu_cores = "2"
  cpu_sockets = "1"
  ram = "3096"
  ipaddr = "192.168.29.13"
  cidr = "24"
  gateway = "192.168.29.1"
  dnsserver = "192.168.29.1"
   user = "darkrose"
   password = "1234"
   sshkey = <<EOF
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0Mrz/2CXLoD3i5oHsLCEdVQrfGzKUDAgJumLLUKmnx darkrose@proxmox
     EOF
}
