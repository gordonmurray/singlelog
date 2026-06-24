terraform {

  required_version = ">= 1.6"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    tigris = {
      source  = "tigrisdata/tigris"
      version = "~> 1.1"
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

# Tigris is where the logs live. Its credentials are passed explicitly so they
# don't clash with the AWS provider, which reads creds from the same environment.
provider "tigris" {
  access_key = var.tigris_access_key
  secret_key = var.tigris_secret_key
}
