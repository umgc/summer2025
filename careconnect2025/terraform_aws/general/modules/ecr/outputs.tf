output "core_repository_url" {
  value = aws_ecr_repository.cc_core_ecr_repo.repository_url
}
output "core_repository_name" {
  value = aws_ecr_repository.cc_core_ecr_repo.name
}