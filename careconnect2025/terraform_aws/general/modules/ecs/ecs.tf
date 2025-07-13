resource "aws_ecs_cluster" "cc_main_cluster" {
  name = "cc-main-cluster"
  tags = merge(var.default_tags, { Name : "cc-main-cluster" })
}

resource "aws_ecs_task_definition" "cc_core_task_def" {
  family                   = "cc-core-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "4096"
  execution_role_arn       = var.cc_ecs_exe_role_arn
  task_role_arn            = var.cc_app_role_arn


  container_definitions = jsonencode([
    {
      name      = "cc-core-backend"
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
          awslogs-group         = "/ecs/cc_core_task_logs"
          mode                  = "non-blocking"
          awslogs-create-group  = "true"
          max-buffer-size       = "25m"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        },
        secretOptions : []
      },
      environment = var.core_task_env_vars

    }
  ])
  tags = merge(var.default_tags, { Name : "cc-core-task-def" })
}

resource "aws_ecs_service" "cc_core_service" {
  name            = "cc-core-service"
  cluster         = aws_ecs_cluster.cc_main_cluster.id
  task_definition = aws_ecs_task_definition.cc_core_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.cc_ecs_sg_id]
  }

  service_registries {
    registry_arn = var.cloudmap_core_service_arn
    port         = 8080
  }
  tags = merge(var.default_tags, { Name : "cc-core-service" })
}