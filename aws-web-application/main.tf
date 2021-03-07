provider "aws" {
  region = var.region
}

data "aws_availability_zones" "all" {}

/*==== The VPC ======*/

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "vpc"
    Environment = var.environment
  }
}

/*==== Subnets ======*/

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "igw"
    Environment = var.environment
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet1.id
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
    Environment = var.environment
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets_cidr1
  availability_zone       = var.availability_zonesa
  map_public_ip_on_launch = true
  tags = {
    Name        = "public-subnet-1"
    Environment = "var.environment"
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets_cidr2
  availability_zone       = var.availability_zonesb
  map_public_ip_on_launch = true
  tags = {
    Name        = "public-subnet-2"
    Environment = "var.environment"
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets_cidr
  availability_zone       = var.availability_zonesa
  map_public_ip_on_launch = false
  tags = {
    Name        = "private-subnet"
    Environment = var.environment
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "route-table"
    Environment = var.environment
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "public-route-table"
    Environment = var.environment
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

/* Route table associations */
resource "aws_route_table_association" "public1" {
  subnet_id     = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id     = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

/*==== VPC's Default Security Group ======*/

resource "aws_security_group" "default" {
  name        = "default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.environment
  }
}

/*==== AutoScaling Group ======*/

/* Launch Configuration */
resource "aws_launch_configuration" "as_conf" {
  name          = "web_config"
  image_id      = var.ami_id
  instance_type = var.ec2_type
  security_groups = [aws_security_group.default.id]
  
  ebs_block_device{
    device_name = "/dev/sdb"
	volume_size = var.block_volume
	encrypted   = "true"
 }
  
  user_data = <<-EOF
              #!/bin/bash
			  sudo mkfs -t xfs /dev/xvdb 
			  sudo mount /dev/xvdb /var/log
              sudo amazon-linux-extras install nginx1.12
			  sudo service nginx start
              EOF
  
  lifecycle {
    create_before_destroy = true
  }
}

/* Autoscaling Group */
resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.as_conf.id
  desired_capacity   = 1
  min_size = 1
  max_size = 2
  vpc_zone_identifier = [aws_subnet.private_subnet.id]

  health_check_type = "ELB"

  lifecycle {
    create_before_destroy = true
    ignore_changes = [load_balancers, target_group_arns]
  }
  
  tag {
    key                 = "Name"
    value               = "web-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "asg_policy" {
  name                   = "asg-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

/*==== Target Group ======*/

/* Create a target group */ 
resource "aws_lb_target_group" "target_group" {
  name     = "tg"
  port     = var.alb_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  
  health_check {
    port     = var.alb_port
    protocol = "HTTP"
  }
  
  tags = {
    Environment = var.environment
  }
}

/* Create a new ALB Target Group attachment */ 
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  alb_target_group_arn   = aws_lb_target_group.target_group.arn
}

/*==== Application Load Balancer ======*/

/* Create an application load balancer */ 
resource "aws_lb" "alb" {
  name               = "master-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.default.id]
  subnets	     	 = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  tags = {
    Environment = var.environment
  }
}

/* Creating listerner attched to ALB */
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.alb.id
  port = var.alb_port
  default_action {
    target_group_arn = aws_lb_target_group.target_group.id
    type             = "forward"
  }
}

