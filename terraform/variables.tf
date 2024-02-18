variable "cluster_names" {
  type        = list(string)
  description = "Names for the individual clusters."
  default     = ["dev"]
}
