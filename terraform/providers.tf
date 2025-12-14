terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.6.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["C:\\Users\\rahul\\.aws\\credentials"]
  profile                  = "terraform-vc-demo"
}

provider "local" {    
}