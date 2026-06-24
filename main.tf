terraform {

  required_version = ">= 1.6"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

}

# Configure the AWS Provider. Credentials come from the environment
# (AWS_PROFILE / AWS_ACCESS_KEY_ID etc.); region stays a variable.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Repo = "https://github.com/gordonmurray/singlelog"
    }
  }
}
