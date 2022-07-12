name     = "capstone-project"
vpc_cidr = "172.16.0.0/16"
tags = {
  "created-on" = "07-11-22"
  "capstone-project" = "true"
}
env = "build"
instance_types = ["m5.large"]
desired_size   = 2
max_size       = 3
min_size       = 1

argocd_hostname = "argocd.jamoroso.com"
cluster_hostname = "jamoroso.com"