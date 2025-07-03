resource "aws_amplify_app" "careconnect_frontend" {
  name       = "careconnect-frontend"
  region     = var.aws_region
  repository = var.github_repo
  oauth_token = var.github_token

  build_spec = file("${path.module}/buildspec.yml")

  environment_variables = {
    ENV = "dev"
  }

  enable_branch_auto_build    = false
  enable_branch_auto_deletion = false
}

resource "aws_amplify_branch" "frontend_branch" {
  app_id      = aws_amplify_app.careconnect_frontend.id
  branch_name = var.github_branch
}