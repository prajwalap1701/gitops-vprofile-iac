provider "aws" {
}

terraform {
  required_providers {
    aws = {
      version = "~> 3"
    }
  }
  backend "s3" {
    bucket = "tf-bucket-17"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

module "network" {
  source = "./modules/network"
}

module "cluster" {
  source       = "./modules/cluster"
  for_each     = toset(var.cluster_names)
  cluster_name = each.key
  vpc_id       = module.network.vpc-id
  subnet_id    = module.network.subnet-id
  sg_ids       = module.network.sg-ids
}

resource "null_resource" "configure_kubeconfig" {
  provisioner "local-exec" {
    command = <<-EOF
    export KUBECONFIG=$(find ./kubeconfigs -type f | tr '\n' ':')
    kubectl config view --flatten > ./kubeconfigs/kubeconfig.yaml
    rm ./kubeconfigs/*.conf
    EOF
  }
  depends_on = [module.cluster]
}

resource "aws_s3_object" "object" {
  bucket = var.bucket_name
  key    = "kubeconfig.yaml"
  source = "./kubeconfigs/kubeconfig.yaml"

  depends_on = [null_resource.configure_kubeconfig]
}

