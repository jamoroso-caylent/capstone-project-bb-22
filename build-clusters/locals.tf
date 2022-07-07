locals {
  name           = var.name
  env            = var.env
  vpc_cidr       = var.vpc_cidr
  azs            = slice(data.aws_availability_zones.available.names, 0, 3)
  tags           = var.tags
  instance_types = var.instance_types
}
