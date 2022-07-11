module "team-backend-cicd" {
  source                  = "../../modules/codepipeline"
  env                     = local.env
  name_prefix             = "crud-backend-app-${local.env}"
  repository_id           = "jamoroso-caylent/spring-boot-angular-14-mysql-example"
  repository_branch       = local.env == "prod" ? "master" : local.env
  buildspec_path          = "spring-boot-server/buildspec.yml"
  buildspec_path_test     = "spring-boot-server/buildspec-test.yml"
  codestar_connection_arn = aws_codestarconnections_connection.codestar_connection.arn
  tags                    = local.tags
}

module "team-frontend-cicd" {
  source                  = "../../modules/codepipeline"
  env                     = local.env
  name_prefix             = "crud-frontend-app-${local.env}"
  repository_id           = "jamoroso-caylent/spring-boot-angular-14-mysql-example"
  repository_branch       = local.env == "prod" ? "master" : local.env
  buildspec_path          = "angular-14-client/buildspec.yml"
  buildspec_path_test     = "spring-boot-server/buildspec-test.yml"
  codestar_connection_arn = aws_codestarconnections_connection.codestar_connection.arn
  tags                    = local.tags
}

resource "aws_codestarconnections_connection" "codestar_connection" {
  name          = "bb-2022-connection"
  provider_type = "GitHub"
}
