terraform {
  backend "s3" {
    bucket = "terraform-render-wmcgy-state"
    key    = "deployments/terraform.tfstate"
    region = "us-east-1"
  }
}
