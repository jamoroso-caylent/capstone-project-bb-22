name     = "capstone-project"
vpc_cidr = "172.16.0.0/16"
tags = {
  "capstone-project" = "true"
}
env = "build"
instance_types = ["m5.large"]
desired_size   = 2
max_size       = 3
min_size       = 1

argocd_hostname = ""
cluster_hostname = ""