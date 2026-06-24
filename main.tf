terraform {

  required_version = ">= 1.6"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

}

# Configure the AWS Provider
provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "singlelog"

  default_tags {
    tags = {
      Repo = "https://github.com/gordonmurray/singlelog"
    }
  }
}
