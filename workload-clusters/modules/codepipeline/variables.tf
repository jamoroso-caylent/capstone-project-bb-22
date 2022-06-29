variable "name_prefix" {
 type = string
 description = "App/Serive orefix name to be used on all resources"
}

variable "repository_id" {
  type = string
  description = "Github repository ID"
}

variable "repository_branch" {
  type = string
  default = "master"
  description = "Repository branch name to be used on the pipeline"
}
variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
variable "codestar_connection_arn" {
  description = "Codestar connection ARN to be used by the pipeline"
  type        = string
}

variable "buildspec_path" {
  description = "Path in the repository where buildspec.yml is located"
  type        = string
}