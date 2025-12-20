provider "aws" {
  
}

resource "aws_instance" "name" {
  ami = var.ami_id
  #instance_type = var.type
}

# resource "aws_subnet" "name2" {
#   vpc_id = var.vpc_id
#   cidr_block = var.cidr_block
# }

  # ami_id = "ami-0f88e80871fd81e91"
  # type = "t2.micro"

  # vpc_id = "vpc-085711b82cae8cf09"
  # cidr_block = "172.31.96.0/20"