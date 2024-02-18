resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.vpc_cidr
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  route_table_id = aws_route_table.main.id
  subnet_id      = aws_subnet.main.id
}

resource "aws_security_group" "egress" {
  name        = "k8s-egress"
  description = "Allow all outgoing traffic to everywhere"
  vpc_id      = aws_vpc.main.id
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress_internal" {
  name        = "k8s-ingress-internal"
  description = "Allow all incoming traffic from nodes and Pods in the cluster"
  vpc_id      = aws_vpc.main.id
  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    self        = true

  }
  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.pod_network_cidr_block != null ? [var.pod_network_cidr_block] : null
  }
}

resource "aws_security_group" "ingress_k8s" {
  name        = "k8s-ingress-k8s"
  description = "Allow incoming Kubernetes API requests (TCP/6443) from outside the cluster"
  vpc_id      = aws_vpc.main.id
  ingress {
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = var.allowed_k8s_cidr_blocks
  }
  ingress {
    protocol    = "tcp"
    from_port   = 30000
    to_port     = 32768
    cidr_blocks = var.allowed_k8s_cidr_blocks
  }
}

resource "aws_security_group" "ingress_ssh" {
  name        = "k8s-ingress-ssh"
  description = "Allow incoming SSH traffic (TCP/22) from outside the cluster"
  vpc_id      = aws_vpc.main.id
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }
}
