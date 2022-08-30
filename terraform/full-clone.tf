# Proxmox Full-Clone
# ---
# Create a new VM from a clone

resource "proxmox_vm_qemu" "Node2-Ubuntu" {
    
    # VM General Settings
    target_node = "darkrose"
    vmid = "102"
    name = "Node2-Ubuntu"
    desc = "Ubuntu-Server-Jammy Node2 for K8's"

    # VM Advanced General Settings
    onboot = true 

    # VM OS Settings
    clone = "ubuntu-server-jammy"

    # VM System Settings
    agent = 1
    
    # VM CPU Settings
    cores = 1
    sockets = 1
    cpu = "host"    
    
    # VM Memory Settings
    memory = 3096

    # VM Network Settings
    network {
        bridge = "vmbr0"
        model  = "virtio"
    }

    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # (Optional) IP Address and Gateway
    ipconfig0 = "ip=192.168.0.111/24,gw=192.168.0.1"
    nameserver = "192.168.0.1"
    
    # (Optional) Default User
    ciuser = "yaseen"
    
    # (Optional) Add your SSH KEY
    sshkeys = <<EOF
     ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0Mrz/2CXLoD3i5oHsLCEdVQrfGzKUDAgJumLLUKmnx yaseen@Entropy
    EOF
}
