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


#################################
# Configurations for autoscaling
#################################

data "aws_iam_role" "ecs_autoscaling_role" {
  name = "AWSServiceRoleForAutoScaling"
}

# make autoscaling target form "sqs_worker_service"
resource "aws_appautoscaling_target" "sqs_worker_target" {
  max_capacity       = 5
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.fluentbit_dev_cluster.name}/${aws_ecs_service.sqs_worker_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn = "${data.aws_iam_role.ecs_autoscaling_role.arn}"
}

# make autoscaling policy for "sqs_worker_service"
resource "aws_appautoscaling_policy" "sqs_worker_scaling_up_policy" {
  name               = "sqs_worker_scaling_up_policy"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.sqs_worker_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.sqs_worker_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.sqs_worker_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ExactCapacity"
    cooldown                = 3
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 5
      scaling_adjustment          = 1
    }

    step_adjustment {
      metric_interval_lower_bound = 5
      metric_interval_upper_bound = 10
      scaling_adjustment          = 2
    }

    step_adjustment {
      metric_interval_lower_bound = 10
      metric_interval_upper_bound = 15
      scaling_adjustment          = 3
    }

    step_adjustment {
      metric_interval_lower_bound = 15
      metric_interval_upper_bound = 20
      scaling_adjustment          = 4
    }

    step_adjustment {
      metric_interval_lower_bound = 20
      scaling_adjustment          = 5
    }
  }
}

resource "aws_appautoscaling_policy" "sqs_worker_scaling_down_policy" {
  name               = "sqs_worker_scaling_down_policy"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.sqs_worker_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.sqs_worker_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.sqs_worker_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ExactCapacity"
    cooldown                = 3
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 0
    }

  }
}

# make cloudwatch metric alerm for "sqs_worker_service" to scale up
resource "aws_cloudwatch_metric_alarm" "sqs_worker_scaling_up_alarm" {
  alarm_name          = "sqs_worker_scaling_up_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "10"
  threshold           = "1"
  statistic           = "Sum"
  alarm_description   = "This metric monitors sqs_worker_service"
  alarm_actions       = ["${aws_appautoscaling_policy.sqs_worker_scaling_up_policy.arn}"] 
  dimensions = {
    QueueName = "${var.sqs_worker_queue_name}"
  }
}

# make cloudwatch metric alerm for "sqs_worker_service" to scale down
resource "aws_cloudwatch_metric_alarm" "sqs_worker_scaling_down_alarm" {
  alarm_name          = "sqs_worker_scaling_down_alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "10"
  threshold           = "1"
  statistic           = "Sum"
  alarm_description   = "This metric monitors sqs_worker_service"
  alarm_actions       = ["${aws_appautoscaling_policy.sqs_worker_scaling_down_policy.arn}"] 
  dimensions = {
    QueueName = "${var.sqs_worker_queue_name}"
  }
}
