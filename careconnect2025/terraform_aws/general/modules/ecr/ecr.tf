resource "aws_ecr_repository" "cc_billing_ecr_repo" {
  name = "cc_billing_ecr"
  tags = merge(var.default_tags, { Name : "cc_billing_ecr_repo" })
}
