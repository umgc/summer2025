resource "aws_ecr_repository" "cc_core_ecr_repo" {
  name = "cc_core_ecr"
  tags = merge(var.default_tags, { Name : "cc_core_ecr_repo" })
}
