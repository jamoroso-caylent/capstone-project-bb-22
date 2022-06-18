variable "name" {
  type        = string
  description = "Name prefix to be used on all resources"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC block cidr"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to add to resources."
}

variable "instance_types" {
  type        = list(string)
  description = "List of instances types to be used on managed groups"
}

variable "desired_size" {
  type        = number
  description = ""
  default     = 5
}

variable "max_size" {
  type        = number
  description = ""
  default     = 10
}


variable "min_size" {
  type        = number
  description = ""
  default     = 3
}

variable "atlantis_github_user" {
  type        = string
  description = "Github user to be used if the atlantis plugin is enabled"
  default     = "" 
}

variable "atlantis_github_token" {
  type        = string
  description = "Github token to be used if the atlantis plugin is enabled"
  default     = "" 
}

variable "atlantis_github_secret" {
  type        = string
  description = "Github secret to be used if the atlantis plugin is enabled"
  default     = "" 
}

variable "atlantis_github_orgAllowlist" {
  type        = string
  description = "Github organization allow list to be used if the atlantis plugin is enabled"
  default     = "" 
}

variable "atlantis_hostname" {
  type        = string
  description = "Atlantis hostname to be used if the atlantis plugin is enabled"
  default     = "" 
}

variable "argocd_hostname" {
  type        = string
  description = "Argocd hostname to be used if the atlantis plugin is enabled"
  default     = "" 
}

variable "cluster_hostname" {
  type        = string
  description = "Domain name used on external dns plugin if enabled"
  default     = ""  
}