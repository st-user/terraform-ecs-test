# make CloudWatch log group named "fluentbit-dev-ecs-group"
resource "aws_cloudwatch_log_group" "fluentbit-dev-ecs-group" {
  name = "/ecs/logs/fluentbit-dev-ecs-group"
}

# make CloudWatch log group named "fluentbit-dev-ecs-group"
resource "aws_cloudwatch_log_group" "fluentbit-dev-ecs-appconfig-sidecar-group" {
  name = "/ecs/logs/fluentbit-dev-ecs-appconfig-sidecar-group"
}

# make CloudWatch log stream named "from-fluentbit"
resource "aws_cloudwatch_log_stream" "from-fluentbit" {
  name           = "from-fluentbit"
  log_group_name = aws_cloudwatch_log_group.fluentbit-dev-ecs-group.name
}

# make CloudWatch log stream named "from-fluentbit"
resource "aws_cloudwatch_log_stream" "from_appconfig_sidecar" {
  name           = "from-appconfig-sidecar"
  log_group_name = aws_cloudwatch_log_group.fluentbit-dev-ecs-appconfig-sidecar-group.name
}

# make CloudWatch log group named "/ecs/firelens"
resource "aws_cloudwatch_log_group" "ecs-firelens" {
  name = "/ecs/firelens"
}


########
# Alerm
########
# make metric filter for "fluentbit-dev-ecs-appconfig-sidecar-group"
resource "aws_cloudwatch_log_metric_filter" "sidecar_metric_filter" {
  name = "sidecar_metric_filter"
  pattern = " ERROR "
  log_group_name = aws_cloudwatch_log_group.fluentbit-dev-ecs-appconfig-sidecar-group.name

  metric_transformation {
    name = "ErrorCount"
    namespace = "SideCarErrorCount"
    value = "1"
  }
}

# make CloudWatch Alerm for "fluentbit-dev-ecs-appconfig-sidecar-group"
resource "aws_cloudwatch_metric_alarm" "sidecar_metric_alarm" {
  alarm_name = "sidecar_metric_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "ErrorCount"
  namespace = "SideCarErrorCount"
  period = "60"
  statistic = "Sum"
  threshold = "1"
  alarm_description = "This metric monitors SideCarErrorCount"
  alarm_actions = [aws_sns_topic.fluentbit_dev_sns_topic.arn]
  treat_missing_data= "notBreaching"
}