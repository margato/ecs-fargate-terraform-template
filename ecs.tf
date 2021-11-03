provider "aws" {
  profile = "mytemplate"
  region  = var.aws-region
}

###############
# ECS Cluster #
###############
resource "aws_ecs_cluster" "mytemplate-ecs-cluster" {
  name = var.ecs-cluster-name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

######################
# ECS Task Log Group #
######################
resource "aws_cloudwatch_log_group" "task-log-group" {
  name              = "${var.ecs-task-name}-log-group"
  retention_in_days = 1

  tags = {
    Name        = "${var.ecs-task-name}-log-group",
    Application = var.ecs-task-name
  }
}

#######################
# ECS Task Definition #
#######################
resource "aws_ecs_task_definition" "mytemplate-task-definition" {
  family                   = var.ecs-task-name
  task_role_arn            = aws_iam_role.ecs-task-role.arn
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  network_mode             = "awsvpc"
  cpu                      = var.cpu-limit
  memory                   = var.memory-limit
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode(
  [
    {
      image            = "${var.tools-account-id}.dkr.ecr.${var.tools-ecr-region}.amazonaws.com/${var.ecr-repository-name}:${var.image-tag}",
      name             = "${var.ecs-task-name}-container-definition",
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          awslogs-region        = var.aws-region,
          awslogs-group         = "${var.ecs-task-name}-log-group",
          awslogs-stream-prefix = "${var.ecs-task-name}-log-group"
        }
      },
      secrets          = [
        {
          "name" : "MYSQL_USERNAME",
          "valueFrom" : "${var.secrets-manager}:MYSQL_USERNAME::"
        },
        {
          "name" : "MYSQL_PASSWORD",
          "valueFrom" : "${var.secrets-manager}:MYSQL_PASSWORD::"
        },
        {
          "name" : "JWT_SECRET",
          "valueFrom" : "${var.secrets-manager}:JWT_SECRET::"
        }
      ],
      environment      = [
        {
          name  = "SPRING_PROFILES_ACTIVE",
          value = var.environment
        },
        {
          name  = "MYSQL_IP",
          value = var.mysql-ip
        }
      ],
      portMappings     = [
        {
          "containerPort" = var.container-port,
          "hostPort"      = var.container-port
        }
      ]
    }
  ])
}

###############
# ECS Service #
###############
resource "aws_ecs_service" "mytemplate-ecs-service" {
  name                               = var.ecs-service-name
  cluster                            = aws_ecs_cluster.mytemplate-ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.mytemplate-task-definition.arn
  launch_type                        = "FARGATE"
  desired_count                      = var.task-desired-count
  deployment_minimum_healthy_percent = "100"
  deployment_maximum_percent         = "200"
  force_new_deployment               = false
  health_check_grace_period_seconds  = 60

  network_configuration {
    security_groups  = [aws_security_group.ecs-task-securitygroup.id]
    subnets          = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
    assign_public_ip = true
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mytemplate-target-group.id
    container_name   = "${var.ecs-task-name}-container-definition"
    container_port   = var.container-port
  }
}