resource "aws_ecs_cluster" "cc_main_cluster" {
  name = "cc-main-cluster"
  tags = var.default_tags
}

resource "aws_ecs_task_definition" "cc_main_task_def" {
  family                   = "cc-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"
  execution_role_arn       = var.cc_ecs_exe_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name      = "cc-backend"
      image     = "${var.cc_ecr_repo_url}:latest"
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
          awslogs-group         = "/ecs/cc_task_logs"
          mode                  = "non-blocking"
          awslogs-create-group  = "true"
          max-buffer-size       = "25m"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        },
        secretOptions : []
      },
      environment = [
        # {
        #   name  = "SPRING_DATASOURCE_URL"
        #   value = "jdbc:postgresql://${var.rds_endpoint}"
        # }
      ]
    }
  ])
  tags = var.default_tags
}

resource "aws_ecs_service" "cc_main_service" {
  name            = "cc-main-service"
  cluster         = aws_ecs_cluster.cc_main_cluster.id
  task_definition = aws_ecs_task_definition.cc_main_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.cc_ecs_sg_id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.cc_main_tg.arn
    container_name   = "cc-backend"
    container_port   = 8080
  }
  tags = var.default_tags
}

resource "aws_lb" "cc_main_lb" {
  name               = "cc-main-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.cc_ecs_lb_sg_id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "cc_main_tg" {
  name        = "cc-main-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/api/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.cc_main_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cc_main_tg.arn
  }
}

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.cc_main_lb.arn
#   port              = "443"
#   protocol          = "HTTPS"

#   default_action {
#     # type             = "forward"
#     # target_group_arn = aws_lb_target_group.cc_main_tg.arn
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "arrived at the container facing https"
#       status_code = 200
#     }
#   }
# }