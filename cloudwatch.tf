# make CloudWatch log group named "fluentbit-dev-ecs-group"
resource "aws_cloudwatch_log_group" "fluentbit-dev-ecs-group" {
  name = "/ecs/logs/fluentbit-dev-ecs-group"
}

# make CloudWatch log stream named "from-fluentbit"
resource "aws_cloudwatch_log_stream" "from-fluentbit" {
  name           = "from-fluentbit"
  log_group_name = aws_cloudwatch_log_group.fluentbit-dev-ecs-group.name
}

# make CloudWatch log group named "/ecs/firelens"
resource "aws_cloudwatch_log_group" "ecs-firelens" {
  name = "/ecs/firelens"
}
