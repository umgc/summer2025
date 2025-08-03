
data "aws_caller_identity" "caller" {}

resource "aws_sfn_state_machine" "cc_deploy_sfn_state_machine" {
  name     = "cc-deployment-stm"
  role_arn = var.cc_app_role_arn

  definition = jsonencode({
    Comment = "State machine for Care Connect deployment"
    StartAt = "CheckObjectKeyAndFlow"
    States = {
      CheckObjectKeyAndFlow = {
        Type = "Choice",
        Choices = [
          {
            Next = "UpdateFunctionCode",
            And = [
              {
                "Variable" : "$.key",
                "IsPresent" : true
              },
              {
                "Variable" : "$.key",
                "StringMatches" : "*.zip"
              },
              {
                "Variable" : "$.flow",
                "StringEquals" : "lambda"
              }
            ]
          },
          {
            Next = "StartAmplifyDeployment",
            And = [
              {
                "Variable" : "$.key",
                "IsPresent" : true
              },
              {
                "Variable" : "$.key",
                "StringMatches" : "*.zip"
              },
              {
                "Variable" : "$.flow",
                "StringEquals" : "ui"
              }
            ]
          }
        ],
        Default = "WrongKeyOrNoMatchingFlow"
      },
      WrongKeyOrNoMatchingFlow = {
        Type = "Pass",
        Next = "SNSPublish",
        Parameters = {
          Reason = "Either the S3 key is not correct of the flow is not found in the process."
        }
      },
      StartAmplifyDeployment = {
        Type = "Task"
        Parameters = {
          "AppId.$" : "$.amplifyAppId",
          "BranchName.$" : "$.branchName",
          "SourceUrl.$" : "States.Format('s3://{}/{}', $.bucket, $.key)"
        },
        Resource = "arn:aws:states:::aws-sdk:amplify:startDeployment",
        Next     = "SNSPublish",
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
          "CodeSha256.$" : "$.CodeSha256",
          "Description.$" : "$$.Execution.Input.key"
          "FunctionName.$" : "$$.Execution.Input.lambda",
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
        Next = "LoopPass"
      },
      LoopPass = {
        Type = "Pass",
        Parameters = {
          "counter" : 0
        },
        ResultPath = "$.loopPass",
        Next       = "GetFunction"
      },
      GetFunction = {
        Type = "Task",
        Parameters = {
          "FunctionName.$" : "$.FunctionName",
          "Qualifier.$" : "$.Version"
        },
        Resource   = "arn:aws:states:::aws-sdk:lambda:getFunction",
        Next       = "LoopChoice",
        ResultPath = "$.functionStatus",
        Retry = [
          {
            ErrorEquals = [
              "States.TaskFailed"
            ],
            "BackoffRate" : 2,
            "IntervalSeconds" : 1,
            "MaxAttempts" : 3,
            "Comment" : "RetryOnFailed"
          }
        ]
      },
      LoopChoice = {
        Type = "Choice",
        Choices = [
          {
            "Next" : "UpdateAPIGWIntegration",
            "Variable" : "$.functionStatus.Configuration.State",
            "StringEquals" : "Active"
          },
          {
            "Next" : "WaitToLoop",
            "Variable" : "$.loopPass.counter",
            "NumericLessThan" : 25
          }
        ],
        Default = "TerminateLoop"
      },
      WaitToLoop = {
        Type    = "Wait",
        Seconds = 15,
        Next    = "IncrementCounter"
      },
      IncrementCounter = {
        Type = "Pass",
        Next = "GetFunction",
        Parameters = {
          "counter.$" : "States.MathAdd($.loopPass.counter, 1)"
        },
        ResultPath = "$.loopPass"
      },
      TerminateLoop = {
        Type = "Pass",
        Next = "SNSPublish"
      },
      SNSPublish = {
        Type     = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          TopicArn = "arn:aws:sns:us-east-1:${data.aws_caller_identity.caller.account_id}:main_admin_email"

          "Subject.$" = "States.Format('Updates on recent Deployment for {} flow', $$.Execution.Input.flow)",
          "Message.$" = "States.Format('Deployment output received on: {}\n{}\n\nFor this original Input:\n{}', $$.State.EnteredTime, States.JsonToString($), States.JsonToString($$.Execution.Input))"
        },
        End = true
      },
      UpdateAPIGWIntegration = {
        Type = "Task",
        Parameters = {
          "ApiId.$" : "$$.Execution.Input.apigwId",
          "CredentialsArn.$" : "$$.Execution.Input.apigwRole",
          "Description" : "CC APP Lambda Integration",
          "IntegrationId.$" : "$$.Execution.Input.integrationId",
          "IntegrationMethod" : "POST",
          "IntegrationType" : "AWS_PROXY",
          "IntegrationUri.$" : "$.FunctionArn",
          "PayloadFormatVersion" : "1.0"
        },
        Resource = "arn:aws:states:::aws-sdk:apigatewayv2:updateIntegration",
        Next     = "SNSPublish",
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
