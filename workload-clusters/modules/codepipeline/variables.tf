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