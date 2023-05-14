# make ECR repository named "fluentbit_dev_my_firelens"
data "aws_ecr_repository" "fluentbit_dev_my_firelens" {
  name = "fluentbit-dev-my-firelens"
}

# make ECR repository named "fluentbit_dev_app"
data "aws_ecr_repository" "fluentbit_dev_app" {
  name = "fluentbit-dev-app"
}

##########################
# Worker
##########################
data "aws_ecr_repository" "sqs_worker_test" {
  name = "sqs-worker-test"
}