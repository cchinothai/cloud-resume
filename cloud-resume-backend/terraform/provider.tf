terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  cloud {
    organization = "team-cody"
    workspaces {
      name = "cloud-resume-backend"
    }
  }

  required_version = ">= 1.14.0"
}

provider "aws" {
  region = "us-east-1"
}