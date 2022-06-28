module "app1-backend-cicd" {
  source = "./modules/codepipeline"
  name_prefix = "simple-crud-backend-app"
  repository_id = "jamoroso-caylent/spring-boot-angular-14-mysql-example"
  repository_branch = "master"
  tags = local.tags
}