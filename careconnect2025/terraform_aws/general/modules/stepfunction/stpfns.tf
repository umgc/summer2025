
resource "aws_sfn_state_machine" "cc_deploy_sfn_state_machine" {
  name     = "cc-deployment-stm"
  role_arn = var.cc_app_role_arn

  definition = jsonencode({
    Comment = "State machine for Care Connect deployment"
    StartAt = "CheckObjectKey"
    States = {
      CheckObjectKey = {
        Type = "Choice",
        Choices = [
          {
            Next = "WrongKeyOrNoMatchingFlow",
            And = [
              {
                "Not" : {
                  "Variable" : "$.key",
                  "IsPresent" : true
                }
              },
              {
                "Not" : {
                  "Variable" : "$.key",
                  "StringMatches" : "*.zip"
                }
              }
            ]
          }
        ],
        Default = "ChooseFlow"
      },
      ChooseFlow = {
        Type = "Choice"
        Choices = [
          {
            Variable     = "$.flow"
            StringEquals = "lambda"
            Next         = "UpdateFunctionCode"
          },
          {
            Variable     = "$.flow"
            StringEquals = "ui"
            Next         = "StartAmplifyDeployment"
          },
          {
            Variable     = "$.flow"
            StringEquals = "apigw"
            Next         = "UpdateAPIGWIntegration"
          }
        ]
        Default = "WrongKeyOrNoMatchingFlow"
      },
      WrongKeyOrNoMatchingFlow = {
        Type = "Pass",
        End  = true
      },
      StartAmplifyDeployment = {
        Type = "Task"
        Parameters = {
          "AppId.$" : "$.amplifyAppId",
          "BranchName.$" : "$.branchName",
          "SourceUrl.$" : "States.Format('s3://{}/{}', $.bucket, $.key)"
        },
        Resource = "arn:aws:states:::aws-sdk:amplify:startDeployment",
        End      = true,
        Catch = [
          {
            "ErrorEquals" : [
              "States.ALL"
            ],
            "Next" : "Fail"
          }
        ]
      },
      UpdateFunctionCode = {
        Type = "Task",
        Parameters = {
          "FunctionName.$" : "$.lambda",
          "S3Bucket.$" : "$.bucket",
          "S3Key.$" : "$.key"
        },
        Resource = "arn:aws:states:::aws-sdk:lambda:updateFunctionCode",
        Next     = "Wait5sec",
        Catch = [
          {
            ErrorEquals = [
              "States.ALL"
            ],
            Next = "Fail"
          }
        ]
      },
      Wait5sec = {
        Type    = "Wait",
        Seconds = 5,
        Next    = "PublishVersion"
      },
      PublishVersion = {
        Type = "Task",
        Parameters = {
          "FunctionName.$" : "$$.Execution.Input.lambda",
          "CodeSha256.$" : "$.CodeSha256",
          "Description.$" : "$$.Execution.Input.key"
        },
        Resource = "arn:aws:states:::aws-sdk:lambda:publishVersion",
        Retry = [
          {
            ErrorEquals = [
              "States.TaskFailed"
            ],
            BackoffRate     = 2,
            IntervalSeconds = 5,
            MaxAttempts     = 3,
            Comment         = "On Lambda in progress",
            MaxDelaySeconds = 5
          }
        ],
        Catch = [
          {
            ErrorEquals = [
              "States.ALL"
            ],
            Next = "Fail"
          }
        ],
        End = true
      },
      UpdateAPIGWIntegration = {
        Type = "Task",
        Parameters = {
          "ApiId.$" : "$$.Execution.Input.apigwid",
          "IntegrationId.$" : "$$.Execution.Input.integrationId",
          "CredentialsArn.$" : "$.appRole",
          "Description" : "CC APP",
          "IntegrationMethod" : "ANY",
          "IntegrationType" : "AWS_PROXY",
          "PayloadFormatVersion" : "1.0"
        },
        Resource = "arn:aws:states:::aws-sdk:apigatewayv2:updateIntegration",
        End      = true,
        Catch = [
          {
            ErrorEquals = [
              "States.ALL"
            ],
            Next = "Fail"
          }
        ]
      },
      Fail = {
        Type = "Fail"
      }
      # ,
      # NotifyDeploymentSuccess = {
      #   Type     = "Task"
      #   Resource = "arn:aws:states:::sns:publish"
      #   Parameters = {
      #     TopicArn = var.sns_topic_arn
      #     Subject  = "✅ Deployment done"
      #     "Message.$" = "States.JsonToString({
      #       \"functionName\": $.processedEvent.functionName,
      #       \"version\": $.processedEvent.newVersion,
      #       \"functionArn\": $.processedEvent.functionArn,
      #       \"apiId\": var.http_api_id,
      #       \"deploymentTime\": $.processedEvent.eventTime
      #       \"finalState\": $.functionStatus.Configuration.State
      #     })"
      #   }
      #   End = true
      # }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.log_group_for_sfn.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
  tags = merge(var.default_tags, {
    "Name" = "cc-deploy-lambda-stm"
  })
}

resource "aws_cloudwatch_log_group" "log_group_for_sfn" {
  name = "/aws/sfn/states/cc-deploy-lambda-stm"
  lifecycle {
    prevent_destroy = false
  }
  retention_in_days = 90
  tags = merge(var.default_tags, {
    "Name" = "log-group-sfn-cc-deploy-lambda-stm"
  })
}
