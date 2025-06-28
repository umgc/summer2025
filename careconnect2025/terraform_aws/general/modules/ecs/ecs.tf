resource "aws_ecs_cluster" "cc_main_cluster" {
  name = "cc-main-cluster"
  tags = merge(var.default_tags, { Name : "cc-main-cluster" })
}

resource "aws_ecs_task_definition" "cc_billing_task_def" {
  family                   = "cc-billing-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "4096"
  execution_role_arn       = var.cc_ecs_exe_role_arn

  container_definitions = jsonencode([
    {
      name      = "cc-billing-backend"
      image     = "${var.cc_ecr_repo_url}"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      logConfiguration : {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/cc_billing_task_logs"
          mode                  = "non-blocking"
          awslogs-create-group  = "true"
          max-buffer-size       = "25m"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        },
        secretOptions : []
      },
      environment = var.billing_task_env_vars

    }
  ])
  tags = merge(var.default_tags, { Name : "cc-billing-task-def" })
}

resource "aws_ecs_service" "cc_billing_service" {
  name            = "cc-billing-service"
  cluster         = aws_ecs_cluster.cc_main_cluster.id
  task_definition = aws_ecs_task_definition.cc_billing_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.cc_ecs_sg_id]
  }

  service_registries {
    registry_arn = var.cloudmap_billing_service_arn
  }
  tags = merge(var.default_tags, { Name : "cc-billing-service" })
}