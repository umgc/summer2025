# Amplify app
resource "aws_amplify_app" "amplify" {
  name     = "careconnect"
  platform = "WEB"
  # Disable for now to test deploying Amplify without GitHub account
  # repository          = var.github_repo
  iam_service_role_arn = var.cc_app_role_arn

  # Add rewrite rule - ensure that any request to a URL not containing a dot will be rewritten to /index.html
  custom_rule {
    source = "</^((?!\\.).)*$/>"
    target = "/index.html"
    status = "200"
  }

  environment_variables = {
    ENV = "dev"
  }
}

# Amplify branch (if using GitHub repo)
resource "aws_amplify_branch" "care_connect_develop" {
  app_id      = aws_amplify_app.amplify.id
  branch_name = var.github_branch
  stage       = "DEVELOPMENT"
}


//resource "aws_amplify_branch" "amplify" {
//  app_id      = aws_amplify_app.careconnect_frontend.id
//  branch_name = var.github_branch
//}