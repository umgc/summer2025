
/* 
       These resources are commented out as they are not currently in use.
       We will use them in the future for CI/CD processes, specifically to trigger Amplify deployments
       when build artifacts are uploaded to S3.
 */



# resource "aws_cloudwatch_event_rule" "cc_ui_artifact_uploaded" {
#   name        = "s3-build-artifact-uploaded"
#   description = "Trigger Amplify deployment when build artifact is uploaded to S3"

#   event_pattern = jsonencode({
#     source = ["aws.s3"]
#     detail = {
#       bucket = {
#         name = ["cc-iac-us-east-1-641592448579"]
#       }
#       object = {
#         key = [{
#           prefix = "cc-ui-builds/"
#           suffix = ".zip"
#         }]
#       }
#       reason = ["PutObject"]
#     }
#   })
# }

# resource "aws_cloudwatch_event_target" "trigger_amplify_deployment" {
#   rule      = aws_cloudwatch_event_rule.cc_ui_artifact_uploaded.name
#   target_id = "TriggerAmplifyDeployment"
#   arn       = var.amplify_deployment_flow.arn
#   role_arn  = var.cc_app_role_arn
# }