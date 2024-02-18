variable "cluster_names" {
  type        = list(string)
  description = "Names for the individual clusters."
  default     = ["dev"]
}

variable "bucket_name" {
  type        = string
  description = "Names of the s3 bucket to upload kubeconfig.yaml"
  default     = "tf-bucket-17"
}

#