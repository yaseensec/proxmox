Add Proxmox Server url,API token and Token ID in creds.tfvars

terraform init

terraform plan --var-file='creds.tfvars'

terraform apply --var-file='creds.tfvars'


