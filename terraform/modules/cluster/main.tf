terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.36.0"
    }
  }
}

locals {
  tags = merge(var.tags, { "terraform-kubeadm:cluster" = var.cluster_name })
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to local .ssh directory so it can be used by SSH clients
resource "local_sensitive_file" "pem_file" {
  filename        = pathexpand("~/.ssh/eks-aws.pem")
  file_permission = "600"
  content         = tls_private_key.key_pair.private_key_pem
}

# Upload the public key of the key pair to AWS so it can be added to the instances
resource "aws_key_pair" "aws-key" {
  key_name   = "aws-key-${var.cluster_name}"
  public_key = trimspace(tls_private_key.key_pair.public_key_openssh)
  tags       = local.tags
}


resource "aws_eip" "master" {
  domain = "vpc"
  tags   = local.tags
}

resource "aws_eip_association" "master" {
  allocation_id = aws_eip.master.id
  instance_id   = aws_instance.k8s_master.id
}

resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
}

locals {
  token = "${random_string.token_id.result}.${random_string.token_secret.result}"
}

resource "null_resource" "wait_for_bootstrap_to_finish" {
  provisioner "local-exec" {
    command = <<-EOF
    alias ssh='ssh -q -i ${local_sensitive_file.pem_file.filename} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    while true; do
      sleep 2
      ! ssh ubuntu@${aws_eip.master.public_ip} [[ -f /home/ubuntu/done ]] >/dev/null && continue
      %{for worker_public_ip in aws_instance.k8s_worker[*].public_ip~}
      ! ssh ubuntu@${worker_public_ip} [[ -f /home/ubuntu/done ]] >/dev/null && continue
      %{endfor~}
      break
    done
    EOF
  }
  triggers = {
    instance_ids = join(",", concat([aws_instance.k8s_master.id], aws_instance.k8s_worker[*].id))
  }
}

resource "null_resource" "download_kubeconfig_file" {
  provisioner "local-exec" {
    command = <<-EOF
    alias scp='scp -q -i ${local_sensitive_file.pem_file.filename} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    mkdir -p kubeconfigs
    scp ubuntu@${aws_eip.master.public_ip}:/home/ubuntu/admin.conf ./kubeconfigs/"${var.cluster_name}.conf"
    sed -i 's/kubernetes/${var.cluster_name}/g' ./kubeconfigs/${var.cluster_name}.conf
    EOF
  }
  triggers = {
    wait_for_bootstrap_to_finish = null_resource.wait_for_bootstrap_to_finish.id
  }
}
