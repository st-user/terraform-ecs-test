# make aws codebuild project named "fluentbit-dev-codebuild-project"
resource "aws_codebuild_project" "fluentbit_dev_codebuild_project" {
  name          = "fluentbit-dev-codebuild-project"
  description   = "CodeBuild project for fluentbit-dev"
  service_role  = aws_iam_role.codebuild_iam_role.arn
  build_timeout = "5"

  source {
    # type            = "GITHUB"
    # location        = "https://github.com/st-user/terraform-ecs-test-app.git"
    # git_clone_depth = 1

    # git_submodules_config {
    # fetch_submodules = true 
    # }
    type = "CODEPIPELINE"
  }

  # source_version = "main"

  artifacts {
    # type = "S3"
    # location = aws_s3_bucket.st_user_fluentbit_dev_build_artifacts.bucket
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = true
  }
  tags = {
    Name = "fluentbit_dev_codebuild_project"
  }
}


# make aws codepipeline resource named "fluentbit-dev-codepipeline"
resource "aws_codepipeline" "fluentbit_dev_codepipeline" {
  name     = "fluentbit-dev-codepipeline"
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
        Repo                 = "terraform-ecs-test-app"
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
        ProjectName = aws_codebuild_project.fluentbit_dev_codebuild_project.name
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
        ServiceName = aws_ecs_service.fluentbit_dev_service.name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.st_user_fluentbit_dev_build_artifacts.bucket
    type     = "S3"
  }
}

# make aws codepipeline webhook resource named "fluentbit-dev-codepipeline-webhook"
resource "aws_codepipeline_webhook" "fluentbit_dev_codepipeline_webhook" {
  name = "fluentbit-dev-codepipeline-webhook"

  authentication = "GITHUB_HMAC"
  authentication_configuration {
    secret_token = var.github_webhook_secret_token
  }

  target_pipeline = aws_codepipeline.fluentbit_dev_codepipeline.name

  target_action = "Source"

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

# make github repository webhook resource named "fluentbit-dev-github-repository-webhook"
resource "github_repository_webhook" "fluentbit_dev_github_repository_webhook" {
  repository = "terraform-ecs-test-app"
  configuration {
    url          = aws_codepipeline_webhook.fluentbit_dev_codepipeline_webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = var.github_webhook_secret_token
  }
  events = ["push"]
}
