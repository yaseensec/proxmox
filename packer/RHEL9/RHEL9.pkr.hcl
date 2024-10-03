# RHEL9 Template
# ---
# Packer Template to create an RHEL9 Template on Proxmox
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = ">= 1.0.5"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

# Resource Definiation for the VM Template
source "proxmox-iso" "RHEL9" {
 
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "proxmox"
    vm_id = "100"
    vm_name = "RHEL9-Template"
    template_description = "RHEL9 Template"

    # VM OS Settings
    # (Option 1) Local ISO File
    iso_file = "local:iso/rhel-9.4-x86_64-dvd.iso"
    iso_storage_pool = "local"
    unmount_iso = true

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "10G"
        #format = "qcow2"
        format = "raw"
        storage_pool = "local-lvm"
        #storage_pool_type = "lvm"
        type = "scsi"
    }

    # VM CPU Settings
    cores = "1"
    cpu_type = "Nehalem"
    os = "l26"
    
    # VM Memory Settings
    memory = "2048" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    # PACKER Boot Commands
    #boot_command = ["<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/inst.ks<enter><wait>"]
    boot_command     = [
      "<tab><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
      "inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/inst.ks",
      "<enter><wait>"
    ]
    boot_wait    = "10s"

    # PACKER Autoinstall Settings
    http_directory = "http"

    ssh_username = "root"
    ssh_private_key_file = "~/Documents/ssh-keys/id_ed25519"
    ssh_port = 22

    # Raise the timeout, when installation takes longer
    ssh_timeout = "30m"
}

# Build Definition to create the VM Template
build {

    name = "RHEL9"
    sources = ["source.proxmox-iso.RHEL9"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "ansible" {
      playbook_file = "ansible/playbook.yml"
      user = "darkrose"
      extra_arguments = [ "--scp-extra-args", "'-O'" ]
    }

    provisioner "shell" {
      inline = [
        "shred -u /etc/ssh/*_key /etc/ssh/*_key.pub",
        "truncate -s 0 /etc/machine-id",
        "rm -f /var/run/utmp", 
        ">/var/log/lastlog", 
        ">/var/log/wtmp", 
        ">/var/log/btmp", 
        "rm -rf /tmp/* /var/tmp/*", 
        "unset HISTFILE; rm -rf /home/*/.*history /root/.*history", 
        "cloud-init clean",
        "rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
        "rm -f /root/*ks",
        "subscription-manager unregister"
      ]
    }

    provisioner "shell" {
      scripts = [
          "scripts/prep.sh"
      ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    # Add additional provisioning scripts here
    # ...
}
