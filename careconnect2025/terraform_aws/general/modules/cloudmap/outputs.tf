output "cloudmap_core_service_arn" {
  description = "The ARN of AWS Cloud Map Core service"
  value       = aws_service_discovery_service.cloudmap_core_service.arn
}