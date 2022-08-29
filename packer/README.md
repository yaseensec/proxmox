Add Proxmox Server url,API token and Token ID in creds.pkr.hcl

packer validate --var-file="../creds.pkr.hcl" ubuntu-server-jammy.pkr.hcl #To validtae from inside ubuntu-server-jammy folder 

packer build --var-file="../creds.pkr.hcl" ubuntu-server-jammy.pkr.hcl #To build from inside ubuntu-server-jammy folder


