variable "ami_id" {
  type = string
}

# variable "type" {
#   type = string
# }

variable "vpc_id" {
  type = string
  default = ""
}

variable "cidr_block" {
  type = string
  default = ""
}