provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "medusa_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "medusa_subnet" {
  vpc_id                  = aws_vpc.medusa_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
}

# Internet Gateway
resource "aws_internet_gateway" "medusa_igw" {
  vpc_id = aws_vpc.medusa_vpc.id
}

# Route Table
resource "aws_route_table" "medusa_route_table" {
  vpc_id = aws_vpc.medusa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.medusa_igw.id
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "medusa_rta" {
  subnet_id      = aws_subnet.medusa_subnet.id
  route_table_id = aws_route_table.medusa_route_table.id
}

# Security Group
resource "aws_security_group" "medusa_sg" {
  vpc_id = aws_vpc.medusa_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Attach AmazonECSTaskExecutionRolePolicy
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster
resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "medusa_task" {
  family                   = "medusa-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "medusa-backend"
      image     = "public.ecr.aws/medusajs/medusa:latest"
      memory    = 1024
      cpu       = 512
      essential = true
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/medusa-service"
          "awslogs-region"        = "ap-south-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "medusa_service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.medusa_subnet.id]
    security_groups  = [aws_security_group.medusa_sg.id]
    assign_public_ip = true
  }
}

# Terraform Outputs
output "vpc_id" {
  value = aws_vpc.medusa_vpc.id
}

output "subnet_id" {
  value = aws_subnet.medusa_subnet.id
}

output "security_group_id" {
  value = aws_security_group.medusa_sg.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.medusa_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.medusa_service.name
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.medusa_task.arn
}

output "log_group_name" {
  value = "/ecs/medusa-service"
}
