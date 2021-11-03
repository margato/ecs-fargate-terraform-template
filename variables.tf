variable "aws-region" {
  default     = "us-east-1"
  description = "AWS Region where resources will be deployed"
  type        = string
}

variable "vpc-name" {
  description = "VPC name"
  type        = string
}

variable "ecs-cluster-name" {
  description = "ECS Cluster name"
  type        = string
}

variable "ecs-service-name" {
  description = "ECS service name"
  type        = string
}

variable "ecs-task-name" {
  description = "ECS task name"
  type        = string
}

variable "container-port" {
  default     = 8080
  description = "Container port"
  type        = number
}

variable "environment" {
  default     = "dev"
  description = "Environment name"
  type        = string
  validation {
    condition     = can(regex("^(dev|homolog|prod)$", var.environment))
    error_message = "Available environments: dev, homolog, prod."
  }
}

variable "secrets-manager" {
  description = "Secrets Manager ARN"
  type        = string
}

variable "image-tag" {
  description = "Docker image tag"
  type        = string
}

variable "tools-account-id" {
  description = "AWS Account ID where docker image is stored in ECR"
  type        = string
}

variable "tools-ecr-region" {
  description = "AWS region where the ECR Repository is"
  type        = string
}

variable "ecr-repository-name" {
  description = "ECR Repository name"
  type        = string
}

variable "mysql-ip" {
  description = "MySQL IP"
  type        = string
}

variable "health-check-path" {
  description = "Application path to health check"
  type        = string
}

variable "cpu-limit" {
  description = "Task CPU limit"
  type        = string
}

variable "memory-limit" {
  description = "Task memory limit"
  type        = string
}

variable "task-desired-count" {
  default     = 0
  description = "Task desired count"
  type        = number
}

variable "vpc-cidr-block" {
  description = "VPC CIDR Block"
  type        = string
}

variable "subnet-1-cidr-block" {
  description = "Subnet 1 CIDR Block"
  type        = string
}

variable "subnet-2-cidr-block" {
  description = "Subnet 1 CIDR Block"
  type        = string
}

variable "load-balancer-timeout-seconds" {
  description = "Load Balancer timeout in seconds"
  type        = number
}