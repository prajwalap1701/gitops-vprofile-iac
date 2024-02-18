output "vpc-id" {
  value = aws_vpc.main.id
}

output "subnet-id" {
  value = aws_subnet.main.id
}

output "sg-ids" {
  value = [for sg in [aws_security_group.egress.id, aws_security_group.ingress_internal.id, aws_security_group.ingress_k8s.id, aws_security_group.ingress_ssh.id] : sg]
}