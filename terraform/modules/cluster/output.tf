output "Kubernetes-Master-Node-Public-IP" {
  value = aws_eip.master.public_ip
}

