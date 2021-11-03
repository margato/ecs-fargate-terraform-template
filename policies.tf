###########################
# ECS Task Execution Role #
###########################
resource "aws_iam_role" "ecs-task-execution-role" {
  name = "${var.ecs-task-name}-taskExecutionRole"

  assume_role_policy = jsonencode(
  {
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow"
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ecs-tasks.amazonaws.com"
        },
      }
    ]
  })
}

##############
# ECS Policy #
##############
resource "aws_iam_role_policy" "ecs-policy" {
  name = "${var.ecs-task-name}-policy"
  role = aws_iam_role.ecs-task-execution-role.id

  policy = jsonencode(
  {
    Version : "2012-10-17",
    Statement : [
      {
        "Sid" : "AllowLogs",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowGetSecrets"
        "Action" : [
          "secretsmanager:GetSecret",
          "secretsmanager:GetSecretValue"
        ],
        "Effect" : "Allow",
        "Resource" : [
          var.secrets-manager
        ]
      },
      {
        "Sid" : "AllowImagePullFromECR",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        "Resource" : "arn:aws:ecr:${var.tools-ecr-region}:${var.tools-account-id}:repository/${var.ecr-repository-name}"
      }
    ]
  })
}

#################
# ECS Task Role #
#################
resource "aws_iam_role" "ecs-task-role" {
  name = "${var.ecs-task-name}-taskRole"

  assume_role_policy = jsonencode(
  {
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ecs-tasks.amazonaws.com"
        },
        Effect : "Allow"
      }
    ]
  })
}

#############################################
# ECS Task Execution Role Policy Attachment #
#############################################
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}