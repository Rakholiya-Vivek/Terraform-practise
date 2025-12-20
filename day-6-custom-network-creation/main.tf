provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc1"
  }
}

resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "ig1"
  }
}

resource "aws_subnet" "subnet1_public" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet1_public"
  }
}

resource "aws_subnet" "subnet2_public" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet2_public"
  }
}

resource "aws_subnet" "subnet3_private" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet3_private"
  }
}

resource "aws_subnet" "subnet4_private" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet4_private"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "rt1"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig1.id
  }
}
resource "aws_route_table_association" "name1" {
  subnet_id = aws_subnet.subnet1_public.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_route_table_association" "name2" {
  subnet_id = aws_subnet.subnet2_public.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "rt2"
  }
   route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natg1.id
  }
}
resource "aws_route_table_association" "name3" {
  subnet_id = aws_subnet.subnet3_private.id
  route_table_id = aws_route_table.rt2.id
}
resource "aws_route_table_association" "name4" {
  subnet_id = aws_subnet.subnet4_private.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_security_group" "cust_sg" {
  name = "cust_sg"
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "cust_sg"
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
}

resource "aws_eip" "eip1" {
  
}
resource "aws_nat_gateway" "natg1" {
  allocation_id = aws_eip.eip1.id
  subnet_id = aws_subnet.subnet1_public.id
}

resource "aws_instance" "ec2_public1" {
  ami = "ami-05ffe3c48a9991133"
  instance_type = "t2.micro"
  key_name = "mykey2"
  associate_public_ip_address = true
  subnet_id = aws_subnet.subnet1_public.id
  vpc_security_group_ids = [aws_security_group.cust_sg.id]
   user_data = file("test.sh")
  tags = {
    Name = "ec2_public1"
  }
}

resource "aws_instance" "ec2_private1" {
  ami = "ami-05ffe3c48a9991133"
  instance_type = "t2.micro"
  key_name = "mykey2"
  associate_public_ip_address = false
  subnet_id = aws_subnet.subnet3_private.id
  vpc_security_group_ids = [aws_security_group.cust_sg.id]
   user_data = file("test.sh")
  tags = {
    Name = "ec2_private1"
  }
}

resource "aws_lb_target_group" "tg1" {
  name     = "tg1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc1.id

  # Health check configuration
  health_check {
    path                = "/"
    interval            = 30  
    timeout             = 5   
    healthy_threshold   = 3  
    unhealthy_threshold = 3 
    protocol            = "HTTP"
  }


 // target_type = "instance"  
}