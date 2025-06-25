resource "aws_ecs_cluster" "cc_main_cluster" {
  name = "cc-main-cluster"
  tags = merge(var.default_tags, { Name : "cc-main-cluster" })
}

resource "aws_ecs_task_definition" "cc_billing_task_def" {
  family                   = "cc-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "4096"
  execution_role_arn       = var.cc_ecs_exe_role_arn

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
    registry_arn = var.cloudmap_billing_service.arn
  }
  tags = merge(var.default_tags, { Name : "cc-billing-service" })
}

resource "aws_lb" "cc_main_lb" {
  name               = "cc-main-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.cc_ecs_lb_sg_id]
  subnets            = var.subnet_ids
  tags               = merge(var.default_tags, { Name : "cc-main-alb" })
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
  tags = merge(var.default_tags, { Name : "cc-main-tg" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.cc_main_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cc_main_tg.arn
  }
  tags = merge(var.default_tags, { Name : "cc-main-http-listener" })
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