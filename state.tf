terraform {
    backend "s3" {
        bucket = "sabdulla-aws-cicd-workshops"
        encrypt = true
        key = "terraform.tfstate"
        region = "eu-west-1"
    }
}

provider "aws" {
    region = "eu-west-1"
}