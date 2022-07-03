provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "git::https://github.com/jamoroso-caylent/terraform-aws-eks-blueprints.git"

  #                 var.cluster_name is for Terratest
  cluster_name    = coalesce(var.cluster_name, local.name)
  cluster_version = "1.21"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.large"]
      min_size        = 2
      subnet_ids      = module.vpc.private_subnets
    }
  }

  # Teams
  application_teams = {
    # First Team
    team-jose = {
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
        "arn:aws:iam::321852949023:user/team-jose",
      ]
    }
  }


  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "git::https://github.com/jamoroso-caylent/terraform-aws-eks-blueprints.git//modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version
  eks_cluster_domain   = var.cluster_hostname #Used by external dns

  argocd_manage_add_ons = true

  # EKS Managed Add-ons
  enable_amazon_eks_aws_ebs_csi_driver = true


  # Add-ons
  enable_external_dns                 = true
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  enable_cluster_autoscaler           = true
  enable_aws_cloudwatch_metrics       = true
  enable_csi_secrets_store_provider   = true

  tags = local.tags
  depends_on = [
    module.eks_blueprints
  ]
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
# module "documentdb" {
#   source     = "./modules/documentdb"
#   name       = local.name
#   subnet_ids = module.vpc.private_subnets
#   vpc_id     = module.vpc.vpc_id
# }
