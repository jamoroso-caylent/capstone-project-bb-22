name     = "workload"
vpc_cidr = "172.18.0.0/16"
tags = {
  "capstone-project" = "true"
}
env            = "prod"
instance_types = ["m5.large"]
desired_size   = 2
max_size       = 3
min_size       = 1

cluster_hostname         = ""
create_irsa_team_backend = true

application_teams = {
  team-backend = {
    "labels" = {
      "app" = "backend"
    }
    "quota" = {
      "requests.cpu"    = "1000m",
      "requests.memory" = "4Gi",
      "limits.cpu"      = "2000m",
      "limits.memory"   = "8Gi",
      "pods"            = "10",
      "secrets"         = "10",
      "services"        = "10"
    }
    # Belows are examples of IAM users and roles
    users = [
      "",
    ]
  }
  team-frontend = {
    "labels" = {
      "app" = "frontend"
    }
    "quota" = {
      "requests.cpu"    = "1000m",
      "requests.memory" = "4Gi",
      "limits.cpu"      = "2000m",
      "limits.memory"   = "8Gi",
      "pods"            = "10",
      "secrets"         = "10",
      "services"        = "10"
    }
    # Belows are examples of IAM users and roles
    users = [
      "",
    ]
  }
}
