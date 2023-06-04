# make chatbot for slack channel
resource "awscc_chatbot_slack_channel_configuration" "fluentbit_dev_slack_channel" {
  configuration_name = "fluentbit_dev_slack_channel"
  sns_topic_arns     = [aws_sns_topic.fluentbit_dev_sns_topic.arn]
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  iam_role_arn       = aws_iam_role.chatbot_role.arn
}
