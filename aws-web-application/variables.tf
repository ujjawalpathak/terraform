variable "region" {
  description = "AWS Deployment region"
  default = "us-west-2"
}

variable "environment" {
    description = "Environment Name"
    default = "imc"
}

variable "vpc_cidr" {
    description = "VPC CIDR block"
    default = "20.0.0.0/16"
}

variable "public_subnets_cidr1" {
    description = "Public Sunbnet CIDR block"
    default = "20.0.10.0/24"
}

variable "public_subnets_cidr2" {
    description = "Public Sunbnet CIDR block"
    default = "20.0.30.0/24"
}

variable "availability_zonesa" {
    description = "Public Sunbnet CIDR block"
    default = "us-west-2a"
}

variable "availability_zonesb" {
    description = "Public Sunbnet CIDR block"
    default = "us-west-2b"
}

variable "private_subnets_cidr" {
    description = "Private Sunbnet CIDR block"
    default = "20.0.20.0/24"
}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type        = number
    default     = 8080
}

variable "alb_port" {
    description = "The port the ELB will use for HTTP requests"
    type        = number
    default     = 80
}
