# make SNS topic resource named "fluentbit_dev_sns_topic"
resource "aws_sns_topic" "fluentbit_dev_sns_topic" {
	  name = "fluentbit_dev_sns_topic"
}