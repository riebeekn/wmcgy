# General vars
variable "aws_region" {
  description = "The AWS region (AWS is used for S3 terraform state bucket)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment to deploy, i.e. qa, staging, prod"
  type        = string
}

variable "github_repository" {
  description = "The Github repository"
  type        = string
}

variable "initial_branch_to_deploy" {
  description = "The initial branch to deploy"
  type        = string
}

variable "render_api_key" {
  description = "Render API Key"
  type        = string
  sensitive   = true
}

variable "render_owner_id" {
  description = "Render Owner ID"
  type        = string
  sensitive   = true
}

variable "render_region" {
  description = "The Render region to deploy to"
  type        = string
}

variable "render_postgres_plan" {
  description = "The Render postgres plan"
  type        = string
}

variable "render_postgres_disk_size" {
  description = "The Render postgres disk size in GB"
  type        = number
}
