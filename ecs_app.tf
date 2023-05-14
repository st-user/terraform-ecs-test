# make ECS cluster named "fluentbit_dev_cluster"
resource "aws_ecs_cluster" "fluentbit_dev_cluster" {
  name = "fluentbit_dev_cluster"
}

# make ECS task definition named "fluentbit_dev_my_firelens"
resource "aws_ecs_task_definition" "fluentbit_dev_definition" {
  family                   = "fluentbit_dev"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  container_definitions = templatefile("./task_definitions.json", {
    appImageURL       = "${data.aws_ecr_repository.fluentbit_dev_app.repository_url}:latest",
    fluentBitImageURL = "${data.aws_ecr_repository.fluentbit_dev_my_firelens.repository_url}:latest",
  })
}

# make ecs service named "fluentbit_dev_service"
resource "aws_ecs_service" "fluentbit_dev_service" {
  name            = "fluentbit_dev_service"
  cluster         = aws_ecs_cluster.fluentbit_dev_cluster.id
  task_definition = aws_ecs_task_definition.fluentbit_dev_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.fluentbit_dev_subnet_1.id, aws_subnet.fluentbit_dev_subnet_2.id]
    security_groups  = [aws_security_group.fluentbit_dev_internal_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.fluentbit_dev_target_group.arn
    container_name   = "app"
    container_port   = 8081
  }
}