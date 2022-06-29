module "app1-backend-cicd" {
  source                  = "./modules/codepipeline"
  name_prefix             = "simple-crud-backend-app"
  repository_id           = "jamoroso-caylent/spring-boot-angular-14-mysql-example"
  repository_branch       = "master"
  buildspec_path          = "spring-boot-server/buildspec.yml"
  codestar_connection_arn = aws_codestarconnections_connection.codestar_connection.arn
  tags                    = local.tags
}

resource "aws_codestarconnections_connection" "codestar_connection" {
  name          = "bb-2022-connection"
  provider_type = "GitHub"
}
