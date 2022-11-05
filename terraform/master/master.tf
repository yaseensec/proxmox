terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.11"
    }
  }
}

resource "proxmox_vm_qemu" "packer-template" {
    count = var.no_of_vm
    vmid = "${var.vm_id}${count.index + 1}"
    name = "${var.vm_name}${count.index + 1}"
    desc = "Ubuntu-Server-Jammy ${var.vm_name}${count.index + 1} for K8's"
    target_node = var.target_node

    # VM Advanced General Settings
    onboot = false

    # VM OS Settings
    clone = var.clone_template
    full_clone = true
  #pool = "local"
    
  #disk {
  #     type = "scsi"
  #     storage = "local"
  #     size = "20G"
  #  }

    # VM System Settings
    agent = 1

    # VM CPU Settings
    cores = var.cpu_cores
    sockets = var.cpu_sockets
    cpu = "host"

    # VM Memory Settings
    memory = var.ram

    # VM Network Settings
    network {
        bridge = "vmbr0"
        model  = "virtio"
    }
    lifecycle {
      ignore_changes = [
        network,
      ]
    }
    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # (Optional) IP Address and Gateway
    ipconfig0 = "ip=${var.ipaddr}${count.index + 1}/${var.cidr},gw=${var.gateway}"
    nameserver = var.dnsserver

    # (Optional) Default User
    ciuser = var.user
    cipassword = var.password
    cloudinit_cdrom_storage = "local"

    # (Optional) Add your SSH KEY
    sshkeys = var.sshkey
}
