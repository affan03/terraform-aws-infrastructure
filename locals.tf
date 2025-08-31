locals {
  interface_services = [
    "com.amazonaws.${var.aws_region}.ssm",
    "com.amazonaws.${var.aws_region}.ssmmessages",
    "com.amazonaws.${var.aws_region}.ec2messages",
    "com.amazonaws.${var.aws_region}.logs",
    "com.amazonaws.${var.aws_region}.codedeploy"
  ]
}