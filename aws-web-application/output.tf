output "vpc_id" {
  value = ["${aws_vpc.vpc.id}"]
}

output "public_subnet1_id" {
  value = ["${aws_subnet.public_subnet1.*.id}"]
}

output "public_subnet2_id" {
  value = ["${aws_subnet.public_subnet2.*.id}"]
}
output "private_subnets_id" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}

output "security_groups_ids" {
  value = ["${aws_security_group.default.id}"]
}

output "launch_configuration_id" {
  value = ["${aws_launch_configuration.as_conf.id}"]
}

output "autoscaling_group_id" {
  value = ["${aws_autoscaling_group.asg.id}"]
}

output "target_group_arn" {
  value = ["${aws_lb_target_group.target_group.arn}"]
}

output "load_balancer_arn" {
  value = ["${aws_lb.alb.id}"]
}
