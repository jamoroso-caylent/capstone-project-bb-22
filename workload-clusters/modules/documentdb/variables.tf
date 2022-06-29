variable "name" {
  type = string
  description = "Name os subnet group"
}

variable "subnet_ids" {
  type = list(string)
  description = "List of subnet ids for db subnet group"
}

variable "vpc_id" {
  type = string
  description = "VPC id for db subnet security group" 
}