# Project Architecture
![image](https://github.com/prajwalap1701/gitops-vprofile-iac/assets/82358791/6f4c3f52-08fc-4e54-b8eb-2c33913fa81d)


# Terraform code 

## Maintain kubernetes cluster with terraform for vprofile project

## Tools required
Terraform version 1.6.6

### Steps
* terraform init
* terraform fmt -check
* terraform validate
* terraform plan -out planfile
* terraform apply -auto-approve -input=false -parallelism=1 planfile
####
#####
