terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "weave-server"
  }
}
