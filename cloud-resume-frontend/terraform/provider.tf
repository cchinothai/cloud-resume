terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.23.0"
    }
  }

  cloud {
    organization = "team-cody"
    workspaces {
      name = "cloud-resume-frontend"
    }
  }

  required_version = ">= 1.14.0"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}