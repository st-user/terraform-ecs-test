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