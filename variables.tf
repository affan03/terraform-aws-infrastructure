# General
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# VPC
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "ai-video-vpc"
}

# Subnets
variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
  default     = 2
}

# Internet Gateway & NAT
variable "igw_name" {
  description = "Name tag for the internet gateway"
  type        = string
  default     = "ai-video-igw"
}

variable "nat_gateway_name" {
  description = "Name tag for the NAT gateway"
  type        = string
  default     = "ai-video-nat-gw"
}

# Route Tables
variable "public_route_table_name" {
  description = "Name tag for the public route table"
  type        = string
  default     = "public-rt"
}

variable "private_route_table_name" {
  description = "Name tag for the private route table"
  type        = string
  default     = "private-rt"
}

# Security Groups
variable "alb_sg_name" {
  description = "Name of the ALB security group"
  type        = string
  default     = "alb-sg"
}

variable "ec2_sg_name" {
  description = "Name of the EC2 instance security group"
  type        = string
  default     = "ec2-sg"
}

variable "vpce_sg_name" {
  description = "Name of the VPC endpoint security group"
  type        = string
  default     = "vpce-sg"
}

# EC2 / Launch Template
variable "launch_template_prefix" {
  description = "Prefix for the EC2 launch template"
  type        = string
  default     = "ai-video-lt"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "SSH key pair name for EC2 instances"
  type        = string
}

variable "ec2_instance_name" {
  description = "Name tag for EC2 instances"
  type        = string
  default     = "ai-video-ec2"
}

variable "ec2_role_name" {
  description = "IAM role name for EC2 instance"
  type        = string
  default     = "ec2-cloudwatch-role"
}

variable "ec2_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
  default     = "ec2-instance-profile"
}

# ALB / Target Group / Listeners
variable "alb_name" {
  description = "Name of the ALB"
  type        = string
  default     = "ai-video-alb"
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
  default     = "ai-video-tg"
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS listener"
  type        = string
}

# Auto Scaling Group
variable "asg_desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 1
}

variable "asg_min_size" {
  description = "ASG minimum size"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "ASG maximum size"
  type        = number
  default     = 3
}

# S3
variable "s3_bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "ai-video-generation"
}

variable "s3_bucket_name_tag" {
  description = "Name tag for the S3 bucket"
  type        = string
  default     = "video-bucket"
}

# SQS
variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "video-generation-queue"
}

variable "sqs_queue_name_tag" {
  description = "Tag name for the SQS queue"
  type        = string
  default     = "video-queue"
}

# IAM Users for Devs
variable "developer_user_count" {
  description = "Number of developer IAM users"
  type        = number
  default     = 2
}

# CodeDeploy
variable "codedeploy_role_name" {
  description = "IAM role name for CodeDeploy"
  type        = string
  default     = "CodeDeployServiceRole"
}

variable "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  type        = string
  default     = "ai-video-app"
}

variable "codedeploy_group_name" {
  description = "Name of the CodeDeploy deployment group"
  type        = string
  default     = "ai-video-dg"
}

# CodePipeline
variable "codepipeline_role_name" {
  description = "IAM role name for CodePipeline"
  type        = string
  default     = "codepipeline-role"
}

variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
  default     = "ai-video-pipeline"
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "github_repo_owner" {
  description = "GitHub username or organization"
  type        = string
}

variable "github_repo_name" {
  description = "Name of the GitHub repository"
  type        = string
}

variable "github_repo_branch" {
  description = "Branch of the GitHub repository to deploy from"
  type        = string
  default     = "main"
}
