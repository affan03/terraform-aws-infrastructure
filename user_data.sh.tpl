#!/bin/bash
yum update -y
yum install -y ruby wget

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

# Install your application dependencies here
# For example, if it's a Node.js app:
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
# source ~/.bashrc
# nvm install node

# Start your application service
# systemctl enable your-app
# systemctl start your-app