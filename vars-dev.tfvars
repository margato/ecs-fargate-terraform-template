# Main
aws-region  = "us-east-1"
environment = "dev"

# ECS
container-port      = 8080
ecs-cluster-name    = "mytemplate-ecs-cluster"
ecs-task-name       = "mytemplate-family"
ecs-service-name    = "mytemplate-service"
cpu-limit           = "256"
memory-limit        = "512"
task-desired-count  = 1
health-check-path   = "/actuator/health"
tools-account-id    = 000000000000
tools-ecr-region    = "sa-east-1"
ecr-repository-name = "mytemplate-repository"
image-tag           = "latest"

# Application environment
secrets-manager = "arn:aws:secretsmanager:sa-east-1:000000000000:secret:mytemplate-secrets-ABC"
mysql-ip        = "127.0.0.1"

# VPC
vpc-name            = "mytemplate-vpc"
vpc-cidr-block      = "10.0.0.0/16"
subnet-1-cidr-block = "10.0.0.0/17"
subnet-2-cidr-block = "10.0.128.0/17"

# Load Balancer
load-balancer-timeout-seconds = 14