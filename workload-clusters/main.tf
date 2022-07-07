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

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "git::https://github.com/jamoroso-caylent/terraform-aws-eks-blueprints.git"

  #                 var.cluster_name is for Terratest
  cluster_name    = "${local.name}-${local.env}"
  cluster_version = "1.21"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

 managed_node_groups = {
    mg_5 = {
      node_group_name = "${local.name}-mang-ng-${local.env}"
      instance_types  = local.instance_types
      subnet_ids      = module.vpc.private_subnets

      desired_size = var.desired_size
      max_size     = var.max_size
      min_size     = var.min_size
    }
  }

  # Teams
  application_teams = local.application_teams

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
  enable_csi_secrets_store_provider   = true

  tags = local.tags
  depends_on = [
    module.eks_blueprints
  ]
}