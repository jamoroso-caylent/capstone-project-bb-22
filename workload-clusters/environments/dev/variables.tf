variable "name" {
  type        = string
  description = "Name prefix to be used on all resources"
}
variable "env" {
  type        = string
  description = "Environnment to be used on all resources"
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

variable "cluster_hostname" {
  type        = string
  description = "Domain name used on external dns plugin if enabled"
  default     = ""  
}

variable "application_teams" {
  description = "Map of maps of teams to create"
  type        = any
  default     = {}
}

variable "platform_teams" {
  description = "Map of maps of teams to create"
  type        = any
  default     = {}
}

variable "create_irsa_team_backend" {
  description = "Create IRSA for backend deployments"
  type        = bool
  default     = false
}