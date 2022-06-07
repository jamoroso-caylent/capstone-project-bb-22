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

