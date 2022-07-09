name     = "workload"
vpc_cidr = "172.17.0.0/16"
tags = {
  "created-on"       = "23-06-10PM"
  "capstone-project" = "true"
}
env            = "dev"
instance_types = ["m5.large"]
desired_size   = 2
max_size       = 3
min_size       = 1

cluster_hostname             = "jamoroso.com"
create_irsa_team_backend            = true
application_teams = {
  # First Team
  team-backend = {
    "labels" = {
      "app" = "backend"
    }
    "quota" = {
      "requests.cpu"    = "4000m",
      "requests.memory" = "4Gi",
      "limits.cpu"      = "6000m",
      "limits.memory"   = "8Gi",
      "pods"            = "10",
      "secrets"         = "10",
      "services"        = "10"
    }
    # Belows are examples of IAM users and roles
    users = [
      "arn:aws:iam::321852949023:user/team-backend",
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
      "arn:aws:iam::321852949023:user/team-frontend",
    ]
  }
}
