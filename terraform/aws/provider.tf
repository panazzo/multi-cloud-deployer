terraform {
  backend "s3" {
    bucket = "terraform-state-multicloud-poc-aws"
    key    = "network/terraform.tfstate"
    region = "sa-east-1"
  }
}