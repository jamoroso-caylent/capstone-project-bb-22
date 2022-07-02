# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}

variable "cluster_hostname" {
  type        = string
  description = "Domain name used on external dns plugin if enabled"
  default     = ""  
}