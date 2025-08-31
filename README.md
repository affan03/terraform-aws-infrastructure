# AWS Web Application Infrastructure with CI/CD Pipeline

## 🚀 Overview

This Terraform project creates a **complete, production-ready web application infrastructure** on AWS with automated CI/CD deployment. It's designed for hosting scalable web applications with high availability, security, and automated deployments from GitHub.

### What This Creates

- **Scalable Web Infrastructure**: Auto-scaling EC2 instances behind a load balancer
- **High Availability**: Multi-AZ deployment with fault tolerance
- **Secure Network**: VPC with public/private subnets and proper security groups
- **Automated CI/CD**: GitHub → CodePipeline → CodeDeploy → Your Servers
- **Monitoring & Management**: CloudWatch integration and SSM access
- **Storage**: S3 bucket for assets and SQS queue for messaging

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     Internet                            │
└─────────────────────┬───────────────────────────────────┘
                      │
              ┌───────▼────────┐
              │ Application    │
              │ Load Balancer  │ (HTTPS/HTTP)
              │ (Public)       │
              └───────┬────────┘
                      │
    ┌─────────────────┼─────────────────┐
    │                VPC                 │
    │  ┌─────────────┐   ┌─────────────┐ │
    │  │   Public    │   │   Private   │ │
    │  │   Subnet    │   │   Subnet    │ │
    │  │    AZ-1     │   │    AZ-1     │ │
    │  │             │   │ ┌─────────┐ │ │
    │  │ NAT Gateway │   │ │  EC2    │ │ │
    │  │             │   │ │Instance │ │ │
    │  └─────────────┘   │ └─────────┘ │ │
    │  ┌─────────────┐   │ ┌─────────┐ │ │
    │  │   Public    │   │ │  EC2    │ │ │
    │  │   Subnet    │   │ │Instance │ │ │
    │  │    AZ-2     │   │ └─────────┘ │ │
    │  │             │   │   Private   │ │
    │  └─────────────┘   │   Subnet    │ │
    └─────────────────────│    AZ-2     │ │
                         └─────────────┘ │
                                         │
    ┌────────────────────────────────────┼─────────┐
    │           CI/CD Pipeline           │         │
    │                                    │         │
    │  GitHub ──▶ CodePipeline ──▶ CodeDeploy ────┘
    │                │                             
    │                ▼                             
    │            S3 Bucket                        
    └──────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

### Required Software
- [Terraform](https://www.terraform.io/downloads.html) >= 1.4.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- Git

### Required AWS Resources
- **AWS Account** with appropriate permissions
- **Domain name** and **SSL certificate** in AWS Certificate Manager (ACM)
- **SSH Key Pair** in AWS EC2 for server access
- **GitHub Personal Access Token** with repo and webhook permissions

### Required GitHub Setup
- **GitHub repository** containing your web application
- **appspec.yml** file in your repository root (deployment instructions)

---

## ⚙️ Configuration

### Step 1: Clone and Setup

```bash
# Clone your infrastructure repository
git clone <your-terraform-repo>
cd <your-terraform-repo>

# Initialize Terraform
terraform init
```

### Step 2: Create Variables File

Create `terraform.tfvars` with your specific values:

```hcl
# AWS Configuration
aws_region = "us-east-1"

# Network Configuration  
vpc_cidr_block        = "10.0.0.0/16"
vpc_name              = "my-web-app-vpc"
public_subnet_count   = 2
private_subnet_count  = 2

# Load Balancer Configuration
alb_name                 = "my-web-app-alb"
target_group_name        = "my-web-app-tg"
acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/your-cert-id"

# Auto Scaling Configuration
asg_desired_capacity = 2
asg_max_size        = 4
asg_min_size        = 1
instance_type       = "t3.micro"
ssh_key_name        = "your-ec2-key-pair"

# GitHub Integration
github_repo_owner  = "your-github-username"
github_repo_name   = "your-repository-name"
github_repo_branch = "main"
github_token       = "ghp_your-github-token"

# Application Names
codedeploy_app_name   = "my-web-app"
pipeline_name         = "my-web-app-pipeline"
s3_bucket_prefix      = "my-web-app"
sqs_queue_name        = "video-processing-queue"

# Developer Access
developer_user_count = 2

# Naming
igw_name                    = "my-web-app-igw"
nat_gateway_name            = "my-web-app-nat"
public_route_table_name     = "my-web-app-public-rt"
private_route_table_name    = "my-web-app-private-rt"
alb_sg_name                 = "my-web-app-alb-sg"
ec2_sg_name                 = "my-web-app-ec2-sg"
vpce_sg_name                = "my-web-app-vpce-sg"
launch_template_prefix      = "my-web-app-lt"
ec2_instance_name           = "my-web-app-instance"
s3_bucket_name_tag          = "Video Storage Bucket"
sqs_queue_name_tag          = "Video Processing Queue"
ec2_role_name               = "my-web-app-ec2-role"
ec2_instance_profile_name   = "my-web-app-ec2-profile"
codedeploy_role_name        = "my-web-app-codedeploy-role"
codedeploy_group_name       = "my-web-app-deployment-group"
codepipeline_role_name      = "my-web-app-codepipeline-role"
```

### Step 3: Prepare Your Application Repository

Your GitHub repository must contain:

#### Required Files Structure
```
your-github-repo/
├── appspec.yml              # CodeDeploy deployment instructions
├── index.html               # Your web application entry point
├── scripts/                 # Deployment scripts directory
│   ├── install_dependencies.sh
│   ├── start_application.sh
│   └── stop_application.sh
├── assets/                  # Static assets
│   ├── css/
│   ├── js/
│   └── images/
└── README.md
```

#### Sample appspec.yml
```yaml
version: 0.0
os: linux

files:
  - source: /
    destination: /var/www/html
    overwrite: yes

permissions:
  - object: /var/www/html
    pattern: "**"
    owner: apache
    group: apache
    mode: 755

hooks:
  BeforeInstall:
    - location: scripts/install_dependencies.sh
      timeout: 300
      runas: root
  
  ApplicationStart:
    - location: scripts/start_application.sh
      timeout: 300
      runas: root
  
  ApplicationStop:
    - location: scripts/stop_application.sh
      timeout: 300
      runas: root
```

#### Sample Deployment Scripts

**scripts/install_dependencies.sh**
```bash
#!/bin/bash
yum update -y
yum install -y httpd
```

**scripts/start_application.sh**
```bash
#!/bin/bash
service httpd start
chkconfig httpd on
```

**scripts/stop_application.sh**
```bash
#!/bin/bash
service httpd stop
```

### Step 4: Create User Data Template

Create `user_data.sh.tpl` in your Terraform directory:

```bash
#!/bin/bash
yum update -y
yum install -y ruby wget httpd

# Install CodeDeploy agent
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# Start services
sudo service codedeploy-agent start
sudo systemctl enable codedeploy-agent
sudo service httpd start
sudo systemctl enable httpd

# Set permissions
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
```

---

## 🚀 Deployment

### Step 1: Plan Infrastructure
```bash
terraform plan
```
Review the planned changes to ensure everything looks correct.

### Step 2: Deploy Infrastructure
```bash
terraform apply
```
Type `yes` when prompted. This will take 10-15 minutes to complete.

### Step 3: Get Load Balancer URL
```bash
terraform output alb_dns_name
```
This gives you the URL where your application will be accessible.

### Step 4: Test Your Application
Visit the Load Balancer URL in your browser. Initially, you'll see a default page until you make your first deployment.

---

## 🔄 How CI/CD Works

### Automatic Deployment Flow

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐
│ Developer   │    │ CodePipeline │    │ CodeDeploy  │    │EC2 Instances│
│             │    │              │    │             │    │             │
│ git push    │───▶│ 1. Detect    │───▶│ 1. Download │───▶│ 1. Stop App │
│             │    │    Change    │    │    Code     │    │ 2. Install  │
│             │    │ 2. Download  │    │ 2. Extract  │    │ 3. Start App│
│             │    │    from      │    │ 3. Deploy   │    │ 4. Health   │
│             │    │    GitHub    │    │    to All   │    │    Check    │
│             │    │ 3. Store S3  │    │    Servers  │    │             │
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘
```

### Step-by-Step Process

1. **Trigger**: Developer pushes code to GitHub
2. **Source**: CodePipeline detects change via webhook
3. **Download**: CodePipeline downloads repository as ZIP
4. **Store**: ZIP stored in S3 bucket as artifact
5. **Deploy**: CodeDeploy downloads artifact and deploys to all EC2 instances
6. **Execute**: Each server runs your deployment scripts
7. **Health Check**: Load balancer verifies instances are healthy
8. **Complete**: New code is live and serving traffic

### Making Your First Deployment

```bash
# In your application repository
git add .
git commit -m "Initial deployment"
git push origin main

# Watch the deployment in AWS Console:
# CodePipeline → Pipelines → your-pipeline-name
```

---

## 📊 What Gets Created

### Networking Infrastructure
- **1 VPC** with DNS support
- **2 Public Subnets** (for load balancer) across 2 AZs
- **2 Private Subnets** (for application servers) across 2 AZs
- **1 Internet Gateway** for public internet access
- **1 NAT Gateway** for private subnet internet access
- **Route Tables** with appropriate routing rules

### Security
- **3 Security Groups**:
  - ALB Security Group: Allow HTTP/HTTPS from internet
  - EC2 Security Group: Allow traffic from ALB only
  - VPC Endpoint Security Group: Allow HTTPS from EC2
- **IAM Roles & Policies**:
  - EC2 Role: CloudWatch and S3 access
  - CodeDeploy Role: Deployment permissions
  - CodePipeline Role: Pipeline orchestration
  - Developer Users: S3 and EC2 describe access

### Compute Infrastructure
- **Application Load Balancer** with SSL termination
- **Target Group** with health checks
- **Launch Template** with your configuration
- **Auto Scaling Group** (min 1, desired 2, max 4 instances)
- **EC2 Instances** in private subnets

### Storage & Messaging
- **S3 Bucket** for artifacts and storage
- **SQS Queue** for message processing

### CI/CD Pipeline
- **CodeDeploy Application** and Deployment Group
- **CodePipeline** with GitHub integration
- **Webhook** for automatic deployments

### Network Optimization
- **VPC Endpoints** for private AWS service access:
  - S3 Gateway Endpoint
  - SSM, EC2, CloudWatch Interface Endpoints

---

## 🔧 Management & Operations

### Scaling Your Application

#### Manual Scaling
```bash
# Update desired capacity in terraform.tfvars
asg_desired_capacity = 4

# Apply changes
terraform apply
```

#### Auto Scaling
The Auto Scaling Group automatically:
- **Scales Up**: When CPU/memory usage is high
- **Scales Down**: When usage is low
- **Replaces Failed Instances**: Automatically

### Monitoring

#### AWS Console Locations
- **EC2 Instances**: EC2 → Instances
- **Load Balancer**: EC2 → Load Balancers
- **Deployments**: CodeDeploy → Applications
- **Pipeline Status**: CodePipeline → Pipelines
- **Logs**: CloudWatch → Log Groups

#### Health Checks
The system performs multiple health checks:
1. **EC2 Health**: Auto Scaling monitors instance health
2. **Application Health**: Load balancer checks your app endpoint
3. **Deployment Health**: CodeDeploy verifies successful deployments

### Accessing Your Servers

#### SSH Access (Emergency Only)
```bash
# Get instance IP from AWS Console
ssh -i your-key.pem ec2-user@private-ip

# Note: You'll need a bastion host or VPN for private subnet access
```

#### Systems Manager (Recommended)
```bash
# Connect via AWS Systems Manager (no SSH key needed)
aws ssm start-session --target i-1234567890abcdef0
```

### Viewing Logs
```bash
# Application logs on EC2 instances
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log

# CodeDeploy logs
sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
```

---

## 🔒 Security Features

### Network Security
- **Private Subnets**: Application servers have no direct internet access
- **Security Groups**: Restrictive firewall rules
- **VPC Endpoints**: Private communication with AWS services
- **SSL/TLS**: HTTPS termination at load balancer

### Access Control
- **IAM Roles**: Principle of least privilege
- **No Hardcoded Credentials**: Uses IAM roles and policies
- **Developer Access**: Limited S3 and EC2 describe permissions

### Data Protection
- **S3 Encryption**: Server-side encryption for stored data
- **VPC Isolation**: Network isolation from other AWS accounts
- **Security Groups**: Application-level firewall

---

## 💰 Cost Optimization

### Current Configuration Costs (Approximate Monthly)
- **EC2 Instances (2 × t3.micro)**: ~$15-20
- **Application Load Balancer**: ~$20-25
- **NAT Gateway**: ~$45-50
- **Data Transfer**: ~$5-10
- **Other Services**: ~$5-10
- **Total**: ~$90-115/month

### Cost Reduction Options

#### Development Environment
```hcl
# In terraform.tfvars for dev environment
instance_type = "t2.micro"        # Use free tier eligible
asg_desired_capacity = 1          # Single instance
asg_max_size = 1
asg_min_size = 1
```

#### Remove NAT Gateway for Dev
Comment out NAT Gateway resources and use public subnets for development.

#### Spot Instances (Advanced)
```hcl
# In launch template
spot_options {
  max_price = "0.01"
}
```

---

## 🚨 Troubleshooting

### Common Issues

#### Deployment Fails
```bash
# Check CodeDeploy logs
aws deploy get-deployment --deployment-id d-1234567890

# Common causes:
# 1. Missing appspec.yml in repository root
# 2. Incorrect file permissions in scripts
# 3. Application not stopping gracefully
# 4. Health check endpoint returning non-200 status
```

#### Pipeline Not Triggering
```bash
# Check webhook exists in GitHub
# Repository → Settings → Webhooks

# Verify GitHub token permissions:
# - repo (full control)
# - admin:repo_hook (manage webhooks)
```

#### Load Balancer 503 Errors
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Common causes:
# 1. Application not running on port 80
# 2. Security group blocking ALB → EC2 communication
# 3. Health check endpoint not responding
```

#### EC2 Instances Not Launching
```bash
# Check Auto Scaling Group events
aws autoscaling describe-scaling-activities --auto-scaling-group-name <asg-name>

# Common causes:
# 1. Invalid AMI ID
# 2. Instance type not available in AZ
# 3. Insufficient capacity
```

### Getting Help

#### AWS Console Locations for Debugging
- **CodePipeline**: View pipeline execution history
- **CodeDeploy**: Check deployment details and logs
- **CloudWatch**: Monitor metrics and logs
- **EC2**: Instance status and system logs
- **Auto Scaling**: Scaling activities and events

#### Log Locations on EC2
```bash
# CodeDeploy agent logs
/var/log/aws/codedeploy-agent/

# Application logs  
/var/log/httpd/

# System logs
/var/log/messages
/var/log/cloud-init.log
```

---

## 🔄 Making Changes

### Application Updates
```bash
# Simply push to GitHub - automatic deployment
git add .
git commit -m "Update application"
git push origin main
```

### Infrastructure Updates
```bash
# Modify terraform.tfvars or main.tf
terraform plan    # Review changes
terraform apply   # Apply changes
```

### Adding New Features

#### Add Build Stage
```hcl
# Add between Source and Deploy stages
stage {
  name = "Build"
  action {
    name             = "Build"
    category         = "Build"
    owner            = "AWS"
    provider         = "CodeBuild"
    input_artifacts  = ["source_output"]
    output_artifacts = ["build_output"]
    
    configuration = {
      ProjectName = aws_codebuild_project.build.name
    }
  }
}
```

#### Add Database
```hcl
# RDS instance in private subnets
resource "aws_db_instance" "app_db" {
  identifier     = "app-database"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  # ... additional configuration
}
```

---

## 🧹 Cleanup

### Destroy Infrastructure
```bash
# This will delete ALL resources and is irreversible
terraform destroy
```

### Partial Cleanup
```bash
# Remove specific resources
terraform destroy -target=aws_autoscaling_group.asg
terraform destroy -target=aws_lb.app_alb
```

### Before Destroying
1. **Backup any data** from S3 buckets
2. **Export any important configurations**
3. **Notify team members** if shared infrastructure

---

## 📚 Additional Resources

### Learning Resources
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CodePipeline User Guide](https://docs.aws.amazon.com/codepipeline/)
- [AWS CodeDeploy User Guide](https://docs.aws.amazon.com/codedeploy/)
- [AWS Auto Scaling User Guide](https://docs.aws.amazon.com/autoscaling/)

### Best Practices
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

---

## 🤝 Support

### Getting Help
1. **Check AWS CloudWatch Logs** for detailed error messages
2. **Review AWS Console** for service-specific issues  
3. **Validate Terraform Configuration** with `terraform validate`
4. **Check GitHub Issues** in your repository

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**🎉 Congratulations!** You now have a production-ready, auto-scaling, self-healing web application infrastructure with automated CI/CD deployments. Your application will automatically deploy whenever you push code to GitHub, scale based on demand, and maintain high availability across multiple AWS availability zones.