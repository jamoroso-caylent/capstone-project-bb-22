name     = "capstone-project"
vpc_cidr = "172.16.0.0/16"
tags = {
  "created-on" = "23-06-10PM"
  "capstone-project" = "true"
}
env = "build"
instance_types = ["m5.large"]
desired_size   = 2
max_size       = 3
min_size       = 1

atlantis_github_user = "jamoroso-caylent"
atlantis_github_orgAllowlist = "github.com/jamoroso-caylent/*"
atlantis_hostname = "atlantis.jamoroso.com"
argocd_hostname = "argocd.jamoroso.com"
cluster_hostname = "jamoroso.com"