variable "region" {
  description = "AWS Deployment region"
  default = "us-west-2"
}

variable "environment" {
    description = "Environment Name"
    default = "terraform"
}

variable "vpc_cidr" {
    description = "VPC CIDR block"
    default = "20.0.0.0/16"
}

variable "public_subnets_cidr1" {
    description = "Public Subnet 1 CIDR block"
    default = "20.0.10.0/24"
}

variable "public_subnets_cidr2" {
    description = "Public Subnet 2 CIDR block"
    default = "20.0.20.0/24"
}

variable "availability_zonesa" {
    description = "Availability Zone A"
    default = "us-west-2a"
}

variable "availability_zonesb" {
    description = "Availability Zone B"
    default = "us-west-2b"
}

variable "private_subnets_cidr" {
    description = "Private Subnet CIDR block"
    default = "20.0.11.0/24"
}

variable "alb_port" {
    description = "The port the ELB will use for HTTP requests"
    type        = number
    default     = 80
}

variable "block_volume" {
    description = "The ebs block volume size"
    type        = number
    default     = 8
}

variable "ami_id" {
    description = "EC2 ami id"
    default     = "ami-0873b46c45c11058d"
}

variable "ec2_type" {
    description = "Instance type"
    default     = "t2.micro"
}