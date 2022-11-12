
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.37.0"
    }
  }

  backend "s3" {
    bucket = "november12-terraform"
    key = "terraformstate-nov12/state.tfstate"
    region = "ap-southeast-3"
    profile = "sandbox"
    dynamodb_table = "terraform-table-november12"

  }

}

provider "aws" {

  region =  "ap-southeast-3"
  profile = "sandbox"

}



data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
/*
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:Component"
    values = ["app"]
  }

  filter {
    name   = "tag:Environment"
    values = ["staging"]
  }
*/
  owners = ["amazon"]
}

resource "aws_instance" "casts_web" {

  ami = data.aws_ami.amazon-2.id
  #ami = "ami-02553a322e00d1ef5"
  instance_type = "t3.micro"

  tags = {

    Name = "cloudcasts-web"
    Environment = "staging"
    ManagedBy = "Terraform"
    Month = "November"

  }

}

resource "aws_eip" "eip-castweb1" {

  instance = aws_instance.casts_web.id
  #instance = "ami-02553a322e00d1ef5"
  vpc = true


}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.casts_web.id
  allocation_id = aws_eip.eip-castweb1.id
}

output "publicip" {
  value = aws_instance.casts_web.public_ip
}