variable "env" {
  type = list(string)
  default = [ "dev1", "dev2","dev3" ]
}

resource "aws_instance" "name" {
    # count = 2
    # count = length(var.env)

    # tags = {
    #     Name = var.env[count.index]
    # }

    # tags = {
    #     Name = "dev${count.index}"
    # }

    for_each = toset(var.env)
    
    ami = "ami-0f88e80871fd81e91"
    instance_type = "t2.micro"

    tags = {
        Name = each.value
    }
}



# ------------------------------------------------------------------------------------------------

variable "sandboxes" {
  type    = set(string)
  default = ["sandbox_one", "sandbox_two", "sandbox_three"]
}

# main.tf
resource "aws_instance" "sandbox" {
  ami           = var.ami
  instance_type = var.instance_type
  for_each      = var.sandboxes
  tags = {
    Name = each.value # for a set, each.value and each.key is the same
  }
}

# ------------------------------------------------------------------------------------------------
variable "allowed_ports" {
  type = map(string)
  default = {
    22    = "203.0.113.0/24"    # SSH (Restrict to office IP)
    80    = "0.0.0.0/0"         # HTTP (Public)
    443   = "0.0.0.0/0"         # HTTPS (Public)
    8080  = "10.0.0.0/16"       # Internal App (Restrict to VPC)
    9000  = "192.168.1.0/24"    # SonarQube/Jenkins (Restrict to VPN)
  }
}

resource "aws_security_group" "devops_project_veera" {
  name        = "devops-project-veera"
  description = "Allow restricted inbound traffic"

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allow access to port ${ingress.key}"
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }
# ------------------------------------------------------------------------------------------------
variable "env" {
  type    = list(string)
  default = ["one","three"]
}

resource "aws_instance" "sandbox" {
  ami           = var.ami
  instance_type = var.instance_type
  for_each      = toset(var.env)
#   count = length(var.env)  

  tags = {
    Name = each.value # for a set, each.value and each.key is the same
  }
}
# ------------------------------------------------------------------------------------------------
