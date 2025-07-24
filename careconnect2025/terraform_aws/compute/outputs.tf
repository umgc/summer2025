output "cc_main_backend_lambda_qualified_arn" {
  description = "ARN of the latest published version of the main backend Lambda function"
  value       = aws_lambda_function.cc_main_backend_lambda.qualified_arn
}
output "cc_main_backend_lambda_arn" {
  description = "ARN of the main backend Lambda function"
  value       = aws_lambda_function.cc_main_backend_lambda.arn
}