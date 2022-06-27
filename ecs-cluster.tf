resource "aws_lb" "default" {
  name            = "ecs-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "nginx" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.nginx.id
    type             = "forward"
  }
}

resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = "arn:aws:iam::514141280285:role/terraform-jenkins-role"

  container_definitions = <<DEFINITION
[
  {
    "image": "514141280285.dkr.ecr.us-east-2.amazonaws.com/terraform-task:latest",
    "cpu": 1024,
    "memory": 2048,
    "name": "nginx-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}

resource "aws_security_group" "nginx" {
  name        = "ecs-task-security-group"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "Dev-cluster"
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.nginx.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.id
    container_name   = "nginx-app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.nginx]
}

output "load_balancer_ip" {
  value = aws_lb.default.dns_name
}

resource "aws_ecs_cluster" "two" {
  name = "Prod-cluster"
}
