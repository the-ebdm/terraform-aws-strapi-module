variable "id" {
    type = string
}

variable "ingress_ip" {
    type = string
    default = "91.110.247.229"
}

variable "domain" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "aws_account" {
  type = string
  description = "AWS Account ID number"
}