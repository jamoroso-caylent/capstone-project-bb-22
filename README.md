# Capstone Project (Blackbelt-containers-2022)
The Capstone Project is a way to showcase all the learnings from the Containers track in a working example. 

This project focuses on a POC for a real scenario, where multiple EKS clusters are needed to deploy approx. 50 microservices following the AWS Well-Architected Framework (WAF) and industry best practices. In this case, we use Terraform to manage all AWS infrastructure; for this reason, we used [terraform-aws-eks-blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints) to accelerate the process of integrating different features as **cluster multi-tenancy, add-ons management, fast scaling up and deployment of EKS clusters following the AWS WAF**.

This repository deploys all the AWS resources needed, but the following repositories are also used for applications, workloads, and add-ons management:

 - https://github.com/jamoroso-caylent/eks-blueprints-add-ons (Addons)
 - https://github.com/jamoroso-caylent/eks-blueprints-workloads (Workloads)
 - https://github.com/jamoroso-caylent/spring-boot-angular-14-mysql-example (Applications)
 - https://github.com/jamoroso-caylent/terraform-aws-eks-blueprints (EKS-blueprints **fork**)

We used ArgoCD and Atlantis to follow the GitOps practices. Changes on the code for workloads or infraestrcuture have the following flows:
# Workloads GitOps
![Alt text](./assets/gitops-workloads.png?raw=true "Title")
# Infrastructure GitOps
![Alt text](./assets/gitops-infra.png?raw=true "Title")

## Project structure
```
capstone-project-bb-22
│   README.md
│   atlantis.yaml				#Atlantis settings for terraform operations.    
│
└───build-clusters				#EKS cluster with Argocd and Atlantis to manage all workloads clusters.
│   └───helm_values				#Additional settings for helm charts.
│       │   argocd.yml		
│   |  *.tfvars					#Custom file values passed on variables.
│   |  ...
│   
└───workload-clusters			#EKS clusters used to deploy applications in dev and prod.
│   └───modules
│   └───environments
│   │   └───dev
|	|	|	| *.tfvars			#Custom file values passed on variables.
|	|	|	| ...
│   │   └───prod
|	|	|	|	...

```
Next images illustrates the stack used on each EKS-blueprints deployments:
# Dev/Prod clusters
![Workload Cluster EKS blueprints-Stack](./assets/workload-cluster.png?raw=true "Title")

# Build cluster
![Build Cluster EKS blueprints-Stack](./assets/build-cluster.png?raw=true "Title")

## Prerequisites
To create all resources defined in this repository, we need to consider the following prerequisites:

 - An S3 bucket and set the corresponding values in the files `backend.tfvars` for each cluster.
 - Create a Host Zone for the domain to be used as the hostname for public access in Route 53.
 - Create/import the SSL certificates used for Argocd, Atlantis, and workloads on the AWS certificate manager.
 - Create User/Roles to be used for cluster multi-tenancy. 
 - Set the variables to be used on `<environment>.tfvars` for each cluster.
 - To use Atlantis add-on:
	 -   Generate a Github access token -> https://www.runatlantis.io/docs/access-credentials.html#generating-an-access-token
	 - Create a secret on AWS Secrets Manager with the following structure:
		  ```
		{ 
			github_token: <github_token>,
			github_secret: <github_secret> #Used to trigger the PR webhook
		}
		```
	 - Create a webhook token -> https://www.runatlantis.io/docs/configuring-webhooks.html#github-github-enterprise
	 - Replace the values as needed on the [atlantis addon values path](https://github.com/jamoroso-caylent/eks-blueprints-add-ons/blob/main/add-ons/atlantis/values.yaml) :
		```
		atlantis:
			image:
			repository: jamorosocaylent/atlantis-aws-cli #This image contains Atlantis and AWS CLI
			tag: latest
			github:
			user: "<github-user>"
			vcsSecretName: atlantis-github-secrets
			ingress:
			annotations: {
			alb.ingress.kubernetes.io/scheme: internet-facing,
			alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443},{"HTTP":80}]',
			alb.ingress.kubernetes.io/ssl-redirect: '443',
			external-dns.alpha.kubernetes.io/hostname: "<atlantis-hostname>" # E.g.,subdomain.example.com
			alb.ingress.kubernetes.io/group.name: ci-cd-ingress,
			kubernetes.io/ingress.class: alb
			}
			host: "<atlantis-hostname>"
			tls:
			- hosts:
			- "<atlantis-hostname>"
			repoConfig: |
				---
				repos:
				- id: /.*/
					apply_requirements: [approved, mergeable]
					allowed_overrides: [apply_requirements, workflow]
					allow_custom_workflows: true
			orgAllowlist: "<orgAllowlist>" #E.g., github.com/jamoroso-caylent/*
			storageClassName: gp2
		env: dev
		awsSecretName: "<awsSecretName>" #AWS secrets created on the previous step
		```

## Usage
The infrastructure should be created with the following commands at the beginning; for future changes and deployments, we will use the Atlantis add-on to follow the GitOps practice.

**EKS-build-cluster**

```
cd build-clusters
terraform init --backend-config=backend.tfvars
terraform apply --var-file=build.tfvars			#Accept with "yes" the plan showed in the output.
```
***Note:*** The default username for Argocd is "admin" and the password could be obtained from a secret in the build-cluster:
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
**EKS-dev-workload**
```
cd workload-clusters/environments/dev
terraform init --backend-config=backend.tfvars
terraform apply --var-file=dev.tfvars			#Accept with "yes" the plan showed in the output.
```
**EKS-prod-workload**
```
cd workload-clusters/environments/prod
terraform init --backend-config=backend.tfvars
terraform apply --var-file=prod.tfvars			#Accept with "yes" the plan showed in the output.
```
After the **dev** and **prod** clusters are created we need to add them to ArgoCD with the [argocd-cli](https://argo-cd.readthedocs.io/en/stable/cli_installation/).
```
argocd login <argocd-hostname>
aws eks --region <region> update-kubeconfig --name <cluster-name>
argocd cluster add <cluster-arn> --name <envrionment>-workload
```
These commands are applied twice; for dev and prod clusters. 

Unlike the build-cluster, the workloads clusters do not receive the add-ons helm parameters to create the Argocd Application; then we need to pass these directly on the [add-ons repository](https://github.com/jamoroso-caylent/eks-blueprints-add-ons/tree/main/chart). These should be given depending on the environment in the file `values-<env>.yaml`. The flags defined on the Terraform code are also required as they will create resources such as namespaces, permissions, or roles.

**Application secrets**
For this application example, the "team-backend" needs to use AWS secrets manager to get the credentials to access the MySQL database. Then as a first step, we need to add these secrets with the following structure:
```
{
"RDS_DB_HOST":"jdbc:mysql://<rds-hostname>:3306/complete_postgresql?useSSL=false",
"RDS_DB_USERNAME":"complete_postgresql",
"RDS_DB_PASSWORD":"<rds-password>"			#If not set on Terraform code, it could be find on the terraform.state in the s3 for the corresponding workload.
} 
```
Finally, the name of the secret should be passed on `awsBackendSecret` in each environment for the [team-backend](https://github.com/jamoroso-caylent/eks-blueprints-workloads/tree/main/teams/team-backend).


## Useful resources
 - [terraform-aws-eks-blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints)
 - [Amazon EKS Blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints/v4.4.0/#amazon-eks-blueprints-for-terraform "Permanent link")
 - [Argocd CD](https://argo-cd.readthedocs.io/en/stable/)
 - [Atlantis](https://www.runatlantis.io/)