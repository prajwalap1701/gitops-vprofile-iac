variable "vpc_cidr" {
  type        = string
  description = "AWS VPC CIDR"
  default     = "10.0.0.0/16"
}
variable "vpc_azs" {
  type        = list(string)
  description = "AWS VPC availability zones"
  default     = ["10.0.0.0/16"]
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets"
  default     = ["10.0.101.0/24"]
}

variable "allowed_ssh_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks from which it is allowed to make SSH connections to the EC2 instances"
  default     = ["0.0.0.0/0"]
}

variable "allowed_k8s_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks from which it is allowed to make Kubernetes API request"
  default     = ["0.0.0.0/0"]
}

variable "pod_network_cidr_block" {
  type        = string
  description = "CIDR block for the Pod network of the cluster"
  default     = null
}