# make aws codebuild project named "sqs-worker-codebuild-project"
resource "aws_codebuild_project" "sqs_worker_codebuild_project" {
  name          = "sqs-worker-codebuild-project"
  description   = "CodeBuild project for sqs-worker"
  service_role  = aws_iam_role.codebuild_iam_role.arn
  build_timeout = "5"

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = true
  }
  tags = {
    Name = "sqs_worker_codebuild_project"
  }
}


# make aws codepipeline resource named "sqs-worker-codepipeline"
resource "aws_codepipeline" "sqs_worker_codepipeline" {
  name     = "sqs-worker-codepipeline"
  role_arn = aws_iam_role.codepipeline_iam_role.arn
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["Source"]
      configuration = {
        Owner                = "st-user"
        Repo                 = "sqs-worker-test"
        Branch               = "main"
        PollForSourceChanges = "true"
        OAuthToken           = var.github_oauth_token
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.sqs_worker_codebuild_project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = 1
      input_artifacts = ["Build"]
      configuration = {
        ClusterName = aws_ecs_cluster.fluentbit_dev_cluster.name
        ServiceName = aws_ecs_service.sqs_worker_service.name
        FileName    = "imagedefinitions-worker.json"
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.st_user_fluentbit_dev_build_artifacts.bucket
    type     = "S3"
  }
}

# make aws codepipeline webhook resource named "sqs-worker-codepipeline-webhook"
resource "aws_codepipeline_webhook" "sqs_worker_codepipeline_webhook" {
  name = "sqs-worker-codepipeline-webhook"

  authentication = "GITHUB_HMAC"
  authentication_configuration {
    secret_token = var.github_webhook_secret_token
  }

  target_pipeline = aws_codepipeline.sqs_worker_codepipeline.name

  target_action = "Source"

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

# make github repository webhook resource named "sqs-worker-github-repository-webhook"
resource "github_repository_webhook" "sqs_worker_github_repository_webhook" {
  repository = "sqs-worker-test"
  configuration {
    url          = aws_codepipeline_webhook.sqs_worker_codepipeline_webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = var.github_webhook_secret_token
  }
  events = ["push"]
}
