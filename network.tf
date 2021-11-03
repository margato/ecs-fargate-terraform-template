#######
# VPC #
#######
resource "aws_vpc" "mytemplate-vpc" {
  cidr_block = var.vpc-cidr-block
  tags       = {
    Name = var.vpc-name
  }
}

###########
# Subnets #
###########
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.mytemplate-vpc.id
  cidr_block        = var.subnet-1-cidr-block
  availability_zone = "${var.aws-region}a"
  tags              = {
    Name = "subnet-1-a"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.mytemplate-vpc.id
  cidr_block        = var.subnet-2-cidr-block
  availability_zone = "${var.aws-region}b"

  tags = {
    Name = "subnet-2-b"
  }
}


####################
# Internet Gateway #
####################
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.mytemplate-vpc.id

  tags = {
    Name = "mytemplate-Internet-Gateway"
  }
}

#########
# Route #
#########
resource "aws_route" "internet-access" {
  route_table_id         = aws_vpc.mytemplate-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gateway.id
}

##############
# Elastic IP #
##############
resource "aws_eip" "elastic-ip" {
  count      = 1
  vpc        = true
  depends_on = [aws_internet_gateway.internet-gateway]

  tags = {
    Name = "mytemplate-ElasticIP"
  }
}

######################
# ECS Security Group #
######################
resource "aws_security_group" "ecs-task-securitygroup" {
  name   = "${var.ecs-task-name}-task-sg"
  vpc_id = aws_vpc.mytemplate-vpc.id

  tags = {
    Name = "${var.ecs-task-name}-task-sg"
  }

  ingress {
    protocol  = "tcp"
    from_port = var.container-port
    to_port   = var.container-port

    security_groups = aws_lb.load-balancer.security_groups
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

######################
# Task Load Balancer #
######################
resource "aws_lb" "load-balancer" {
  name               = "${var.ecs-service-name}-lb"
  subnets            = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
  security_groups    = [aws_security_group.allow-web-sg.id]
  load_balancer_type = "application"
  idle_timeout       = var.load-balancer-timeout-seconds

  tags = {
    Name = "${var.ecs-service-name}-lb"
  }
}

################
# Target group #
################
resource "aws_lb_target_group" "mytemplate-target-group" {
  name        = "${var.ecs-service-name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.mytemplate-vpc.id
  target_type = "ip"

  health_check {
    path                = var.health-check-path
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 10
    port                = var.container-port
  }

  tags = {
    Name = "${var.ecs-service-name}-tg"
  }
}

##########################
# Load Balancer Listener #
##########################
resource "aws_lb_listener" "load-balancer-listener" {
  load_balancer_arn = aws_lb.load-balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.mytemplate-target-group.id
    type             = "forward"
  }

  tags = {
    Name = "${var.ecs-service-name}-loadbalancer-listener"
  }
}

############################
## Internet Security Group #
############################
resource "aws_security_group" "allow-web-sg" {
  name   = "allow-web-sg"
  vpc_id = aws_vpc.mytemplate-vpc.id

  tags = {
    Name = "allow-web-sg"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}