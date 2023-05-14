# make IAM policy document enabling ECS task to write to CloudWatch log group named "fluentbit-dev-ecs-group"
data "aws_iam_policy_document" "ecs_task_cloudwatch_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/ecs/logs/fluentbit-dev-ecs-group:*",
    ]
  }
}

# make IAM policy resource with "ecs_task_cloudwatch_logs" policy document
resource "aws_iam_policy" "ecs_task_cloudwatch_logs" {
  name        = "terraform-test-ecs-task-cloudwatch-logs"
  description = "IAM policy for ECS task to write to CloudWatch log group named fluentbit-dev-ecs-group"
  policy      = data.aws_iam_policy_document.ecs_task_cloudwatch_logs.json
}

# make IAM policy document enabling ECS task to write s3 bucket named "st-user-fluentbit-dev-directs3"
data "aws_iam_policy_document" "ecs_task_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::st-user-fluentbit-dev-directs3/*",
    ]
  }
}

# make IAM policy resource with "ecs_task_s3" policy document
resource "aws_iam_policy" "ecs_task_s3" {
  name        = "terraform-test-ecs-task-s3"
  description = "IAM policy for ECS task to write to s3 bucket named st-user-fluentbit-dev-directs3"
  policy      = data.aws_iam_policy_document.ecs_task_s3.json
}

# make IAM AssumeRole policy document for ECS task
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# make IAM role for ECS task
resource "aws_iam_role" "ecs_task" {
  name               = "terraform-test-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# attach IAM policy "ecs_task_cloudwatch_logs" to IAM role "ecs_task"
resource "aws_iam_role_policy_attachment" "attach_ecs_task_cloudwatch_logs" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_cloudwatch_logs.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecs_task_s3" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_s3.arn
}

# make IAM role for ECS task
resource "aws_iam_role" "ecs_task_execution" {
  name               = "terraform-test-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# attach IAM policy AWS ECS task execution role to IAM role "ecs_task_execution"
resource "aws_iam_role_policy_attachment" "attach_ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##############
# Worker ECS task role
##############

# make IAM policy document enabling ECS task to write to CloudWatch log group named "sqs-worker-ecs-group"
data "aws_iam_policy_document" "ecs_worker_task_cloudwatch_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/ecs/logs/sqs-worker-ecs-group:*",
    ]
  }
}

# make IAM policy document enabling ECS task to pull messages from SQS quene named "fluentbit-dev-ecs-queue"
data "aws_iam_policy_document" "ecs_worker_task_sqs" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
    ]
    resources = [
      "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:${var.sqs_worker_queue_name}",
    ]
  }
}

# make IAM policy resource with "ecs_worker_task_cloudwatch_logs" policy document
resource "aws_iam_policy" "ecs_worker_task_cloudwatch_logs" {
  name        = "sqs-worker-ecs-task-cloudwatch-logs"
  description = "IAM policy for ECS task to write to CloudWatch log group named sqs-worker-ecs-group"
  policy      = data.aws_iam_policy_document.ecs_worker_task_cloudwatch_logs.json
}

# make IAM policy resource with "ecs_worker_task_sqs" policy document
resource "aws_iam_policy" "ecs_worker_task_sqs" {
  name        = "sqs-worker-ecs-task-sqs"
  description = "IAM policy for ECS task to pull messages from SQS quene"
  policy      = data.aws_iam_policy_document.ecs_worker_task_sqs.json
}

# make IAM role for ECS task
resource "aws_iam_role" "ecs_worker_task" {
  name               = "sqs-worker-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# attach IAM policy "ecs_worker_task_cloudwatch_logs" to IAM role "ecs_worker_task"
resource "aws_iam_role_policy_attachment" "attach_ecs_worker_task_cloudwatch_logs" {
  role       = aws_iam_role.ecs_worker_task.name
  policy_arn = aws_iam_policy.ecs_worker_task_cloudwatch_logs.arn
}

# attach IAM policy "ecs_worker_task_sqs" to IAM role "ecs_worker_task"
resource "aws_iam_role_policy_attachment" "attach_ecs_worker_task_sqs" {
  role       = aws_iam_role.ecs_worker_task.name
  policy_arn = aws_iam_policy.ecs_worker_task_sqs.arn
}




##############

# CodeBuild

##############

# make aws iam policy document for codebuild assume role
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_iam_policy_document" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetObjectVersion",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]

  }
}

# make aws iam role for codebuild
resource "aws_iam_role" "codebuild_iam_role" {
  name               = "codebuild"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

# attach "codebuild_iam_policy_document" to "codebuild_iam_role"
resource "aws_iam_role_policy" "codebuild_iam_policy" {
  name   = "fluentbit-dev-codebuild-iam-policy"
  role   = aws_iam_role.codebuild_iam_role.id
  policy = data.aws_iam_policy_document.codebuild_iam_policy_document.json
}


##################

# Codepipeline

##################

# make aws iam policy document for codepipeline assume role
data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

# make aws iam policy document for codepipeline
data "aws_iam_policy_document" "codepipeline_iam_policy_document" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "iam:PassRole",
    ]
  }
}

# make aws iam role for codepipeline
resource "aws_iam_role" "codepipeline_iam_role" {
  name               = "fluentbit-dev-codepipeline"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

# attach "fluentbit_dev_codepipeline" to "fluentbit_dev_codepipeline"
resource "aws_iam_role_policy" "codepipeline_iam_policy" {
  name   = "fluentbit-dev-codepipeline"
  role   = aws_iam_role.codepipeline_iam_role.id
  policy = data.aws_iam_policy_document.codepipeline_iam_policy_document.json
}