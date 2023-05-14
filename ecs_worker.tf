# make ECS task definition named "sqs_worker"
resource "aws_ecs_task_definition" "sqs_worker_definition" {
  family                   = "sqs_worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_worker_task.arn
  container_definitions = templatefile("./worker_task_definitions.json", {
    workerImageURL       = "${data.aws_ecr_repository.sqs_worker_test.repository_url}:latest",
    sqsQueueURL = "https://sqs.${var.aws_region}.amazonaws.com/${var.aws_account_id}/${var.sqs_worker_queue_name}"
  })
}

# make ecs service named "sqs_worker_service"
resource "aws_ecs_service" "sqs_worker_service" {
  name            = "sqs_worker_service"
  cluster         = aws_ecs_cluster.fluentbit_dev_cluster.id
  task_definition = aws_ecs_task_definition.sqs_worker_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.fluentbit_dev_subnet_1.id, aws_subnet.fluentbit_dev_subnet_2.id]
    security_groups  = [aws_security_group.sqs_worker_sg.id]
    assign_public_ip = true
  }
}