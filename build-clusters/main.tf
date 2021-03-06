provider "aws" {
  #   region = "data.aws_region.current"
  region = "us-east-1"
  # shared_credentials_file = "./.credentials"
  # profile                 = "local"
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

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "git::https://github.com/jamoroso-caylent/terraform-aws-eks-blueprints.git"

  cluster_name    = local.name
  cluster_version = "1.21"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    mg_5 = {
      node_group_name = "${local.name}-managed-ondemand"
      instance_types  = local.instance_types
      subnet_ids      = module.vpc.private_subnets
      desired_size = var.desired_size
      max_size     = var.max_size
      min_size     = var.min_size

    }
    # Launch template configuration
  }

  #Added atlantis role to manage resources with the atlantis service account
  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/capstone-project-atlantis-irsa"
      username = "system:serviceaccount:atlantis:atlantis"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "git::https://github.com/jamoroso-caylent/terraform-aws-eks-blueprints.git//modules/kubernetes-addons"

  eks_cluster_id                      = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint                = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider                   = module.eks_blueprints.oidc_provider
  eks_cluster_version                 = module.eks_blueprints.eks_cluster_version
  eks_cluster_domain                  = var.cluster_hostname #Used by external dns

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying add-ons
  argocd_applications = {
    addons = {
      path               = "chart"
      repo_url           = "https://github.com/jamoroso-caylent/eks-blueprints-add-ons.git"
      add_on_application = true
    }
    dev-workload = {
      path               = "envs/dev"
      repo_url           = "https://github.com/jamoroso-caylent/eks-blueprints-workloads.git"
      add_on_application = false
    }
    prod-workload = {
      path               = "envs/prod"
      repo_url           = "https://github.com/jamoroso-caylent/eks-blueprints-workloads.git"
      add_on_application = false
    }
  }
  argocd_helm_config = {
    values = [templatefile("${path.module}/helm_values/argocd.yml", {
      hostname = var.argocd_hostname
  })] }

  # Add-ons
  enable_external_dns                  = true
  enable_metrics_server                = true
  enable_aws_load_balancer_controller  = true
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_atlantis                      = true
  enable_csi_secrets_store_provider    = true
  tags                                 = local.tags
  depends_on = [
    module.eks_blueprints
  ]
}


#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}
