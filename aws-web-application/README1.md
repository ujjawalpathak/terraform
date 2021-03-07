#**README.md**

This directory contains the terraform project which creates AWS stack for running a scalable web application.
To run this project, use below commands: 
_terraform init_
_terraform plan_
_terraform apply_
Once the stack formation is complete, we can directly use the ALB arn displayed as output to access the web server. 

**Assumption:**
We have made several assumptions while creating this project.
1.	This template is just for understanding and should not be used for production.
2.	To keep this template generic, we have provided all the values in the variables.tf file.
3.	We have added tags to all resources.
4.	This template creates 1 VPC with 3 subnets (2 public and 1 private).
5.	This template creates only 1 Security group which is attached to both ALB and Launch configuration to keep resource cost minimal, although there should be different Security groups for each resource. The security group has ingress port open to all traffic. 
6.	Key-pair is not provided in the create launch configuration block to keep this template generic, but key-pair is very important to keep resources secure.
7.	User-data is added in the create launch configuration block, which will mount the EBS block volume at /var/log and will also download and launch Nginx server.
8.	Health check is added to Autoscaling group.
9.	Application Load Balancer is created with a rule attached to it, forwarding request over to Target Group.

**Variables:**
Input variables and their values set inside variables.tf file.
**|Name|	Default Value|	Description|**
**|----|---------------|-------------|** 
|region|	us-west-2|	AWS Deployment region|
|environment|	terraform|	Environment Name to be added in tag|
|vpc_cidr|	20.0.0.0/16|	VPC CIDR block|
|public_subnets_cidr1|	20.0.10.0/24|	Public Subnet 1 CIDR block|
|public_subnets_cidr2|	20.0.20.0/24|	Public Subnet 2 CIDR block|
|private_subnets_cidr|	20.0.11.0/24|	Private Subnet CIDR block|
|availability_zonesA|	us-west-2a|	Availability Zone A|
|availability_zonesB|	us-west-2b|	Availability Zone B|
|alb_port|	80|	The port the ELB will use for HTTP requests|
|ami_id|	ami-0873b46c45c11058d|	EC2 ami id|
|ec2_type|	t2.micro|	Instance type|
|block_volume|	8|	The ebs block volume size|

