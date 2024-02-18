# Mandatory variable
variable "cluster_name" {
  type        = string
  description = "Name of the Kubernetes cluster"
}

variable "master_instance_type" {
  type        = string
  description = "Instance type for Kubernetes master node"
  default     = "t2.medium"
}

variable "worker_instance_type" {
  type        = string
  description = "Instance type for Kubernetes worker nodes"
  default     = "t2.small"
}

# Define a variable for the number of Kubernetes worker nodes
variable "workers-count" {
  type        = number
  default     = 1
  description = "Number of Kubernetes worker nodes"
}

variable "volume_size" {
  type    = number
  default = 30
}

variable "tags" {
  type        = map(string)
  description = "A set of tags to assign to the created AWS resources"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC id"
}

variable "subnet_id" {
  type        = string
  description = "AWS Subnet id"
}

variable "sg_ids" {
  type        = list(string)
  description = "AWS Security group ids"
}