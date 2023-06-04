# make AppConfig application
resource "aws_appconfig_application" "appconfig_application" {
  name        = "my-appconfig-ecs-application"
  description = "my-appconfig-ecs-application"
}

# make AppConfig environment
resource "aws_appconfig_environment" "appconfig_environment" {
  name           = "Beta"
  application_id = aws_appconfig_application.appconfig_application.id
  description    = "Beta environment"
}

# make AppConfig configuration profile for FeatureFlag
resource "aws_appconfig_configuration_profile" "appconfig_featureflag_configuration_profile" {
  name           = "my-appconfig-featureflag-configuration-profile"
  application_id = aws_appconfig_application.appconfig_application.id
  description    = "my-appconfig-featureflag-configuration-profile"
  location_uri   = "hosted"
  type           = "AWS.AppConfig.FeatureFlags"
}

# make AppConfig hosted configuration version for FeatureFlag

resource "aws_appconfig_hosted_configuration_version" "appconfig_featureflag_hosted_configuration_version" {
  application_id           = aws_appconfig_application.appconfig_application.id
  configuration_profile_id = aws_appconfig_configuration_profile.appconfig_featureflag_configuration_profile.configuration_profile_id
  content_type             = "application/json"
  description              = "my-appconfig-featureflag-hosted-configuration-version"
  content = jsonencode({
    flags : {
      feature1 : {
        name : "feature1",
        attributes: {
          data: {
            constraints: {
              type: "array",
              required: true
            }
          }
        }
      },
      feature2 : {
        name : "feature2",
        attributes: {
          data: {
            constraints: {
              type: "array",
              required: true
            }
          }
        }
      },
    }
    values: {
      feature1: {
        enabled: true,
        data: [1,2,3]
      }
      feature2: {
        enabled: true,
        data: [1,2,3,4,5]
      }
    }
    version: "1"
  })
}

# make AppConfig deployment strategy
resource "aws_appconfig_deployment_strategy" "appconfig_featureflag_deployment_strategy" {
  name                           = "example-deployment-strategy-tf"
  description                    = "Example Deployment Strategy"
  deployment_duration_in_minutes = 1
  final_bake_time_in_minutes     = 1
  growth_factor                  = 1
  growth_type                    = "LINEAR"
  replicate_to                   = "NONE"
}


# make AppConfig deployment
resource "aws_appconfig_deployment" "appconfig_deployment" {
  application_id           = aws_appconfig_application.appconfig_application.id
  configuration_profile_id = aws_appconfig_configuration_profile.appconfig_featureflag_configuration_profile.configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.appconfig_featureflag_hosted_configuration_version.version_number
  deployment_strategy_id   = aws_appconfig_deployment_strategy.appconfig_featureflag_deployment_strategy.id
  description              = "my-appconfig-deployment"
  environment_id           = aws_appconfig_environment.appconfig_environment.environment_id
}
