output "cloudmap_billing_service_arn" {
  description = "The ARN of AWS Cloud Map Billing service"
  value       = aws_service_discovery_service.cloudmap_billing_service.arn
}