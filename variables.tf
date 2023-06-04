variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "aws_account_id" {
  type    = string
}

variable "github_webhook_secret_token" {
  type    = string
}

variable "github_oauth_token" {
  type    = string
}

variable "slack_workspace_id" {
  type    = string
}

variable "slack_channel_id" {
  type    = string
}

variable "sqs_worker_queue_name" {
  type    = string
  default = "HelloQueue"
}
