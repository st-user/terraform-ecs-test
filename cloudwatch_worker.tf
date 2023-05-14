# make CloudWatch log group named "sqs-worker-ecs-group"
resource "aws_cloudwatch_log_group" "sqs-worker-ecs-group" {
  name = "/ecs/logs/sqs-worker-ecs-group"
}

